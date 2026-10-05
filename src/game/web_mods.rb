#==============================================================================
# ■ 地图扩展层（构建时插在 117 - Main 之前，晚于原版脚本和武功注册表载入）
#------------------------------------------------------------------------------
#  在游戏读取 Data/*.rxdata 时动态加入新地图、新事件，原版数据文件不做任何改动。
#  接入点：src/ruby/rgss_kernel.rb 的 load_data
#    - Map052.rxdata 等新地图：文件不存在，由 WebMod.generate 现场生成；
#    - 已有地图、MapInfos.rxdata：读入后由 WebMod.patch 追加事件、改地形、登记地图名。
#  内容写在 src/game/mods/*.rb，构建时按文件名顺序紧接本文件载入。写法：
#
#    WebMod.map 52, name: '城隍庙', parent: 21, base: 6 do |m|   # 复制地图 6 的地形和设置
#      m.npc  9, 6,  name: '庙祝', tile: 850, talk: ['施主请留步……'],
#                    look: { age: 6, text: '一个须发皆白的老庙祝。' }
#      m.door 9, 13, to: [21, 9, 5], dir: 2
#    end
#    WebMod.edit 21 do |m|
#      m.door 9, 4, to: [52, 9, 12], dir: 8
#    end
#
#  编号规则（详见 docs/地图扩展指南.md）：
#    - 新地图从 52 开始；
#    - 新地图里的事件从 1 开始编号，追加到原版地图的事件从 1001 开始，
#      避免和原版事件共用自开关（自开关按 [地图, 事件, A～D] 存）；
#    - 剧情开关用 102 号以后，变量用 161～200（见 docs/内容设计思路.md 的分配表）。
#
#  回归测试：node tools/mod-maps-test.mjs；查看坐标：node tools/mapview.mjs 地图编号
#==============================================================================
module WebMod
  FIRST_MAP_ID   = 52
  FIRST_EDIT_EVENT_ID = 1001
  ORIGINAL_MAPS  = 1..51

  FIRST_ENEMY_ID = 144                           # 原版敌人 / 敌群用到 143
  # 不能当模板的原版敌人：125 恶人（随机生成）、129～135 舞林大会（数值随玩家变化）、
  # 143 没有数值表，37、38、41、90 的敌群成员与编号不对应
  BAD_TEMPLATES = [125, 143, 37, 38, 41, 90] + (129..135).to_a
  # get_npc_data 数值表各字段（见 013 - Data_NPC.rb 开头的说明）
  NPC_FIELDS = {
    膂力: 0, 敏捷: 1, 悟性: 2, 根骨: 3,
    拳脚: 4, 兵刃: 5, 轻功: 6, 内功: 7, 招架: 8,     # 当前启用的武功编号
    武器: 9, 装备1: 10, 装备2: 11,                   # 武器 / 防具编号
    命中: 24, 闪避: 25, 经验: 26, 门派: 27, 防御: 28, 附加膂力: 29, 附加敏捷: 30,
  }

  @maps    = {}                                  # 新地图编号 => 定义
  @edits   = Hash.new { |h, k| h[k] = [] }       # 原版地图编号 => [定义块, ...]
  @enemies = {}                                  # 新敌人编号 => 定义
  @weapons = {}                                  # 新武器编号 => 定义
  @armors  = {}                                  # 新防具编号 => 定义
  @skills  = {}                                  # 新绝招编号 => 定义
  @items   = {}                                  # 新物品编号 => 定义
  @variable_names = {}                           # 变量编号 => 名字（新武功的名字就是它的变量名）
  @common_events = {}                            # 新公共事件编号 => 定义
  @auto_events = {}                              # 不指定编号的公共事件：键 => 定义（排在有编号的后面）
  @auto_event_ids = {}                           # 键 => 读取 CommonEvents.rxdata 时分到的编号

  # ---- 剧情奖励（事件里用 c.reward）
  def self.gain_exp(n)
    $game_variables[152] = Zlib.crc32(($game_variables[19] + n).to_s, 51)
    $game_variables[19] += n
  end

  def self.gain_pot(n)
    $game_variables[20] += n
    $game_variables[153] += n
  end

  # 对话框里一段文字自动换行后占几行（与 Window_Message#refresh 的换行规则相同：内容宽 448）
  def self.message_rows(text)
    @measure ||= Bitmap.new(32, 32)
    text = text.to_s.gsub(/\\[Vv]\[([0-9]+)\]/) { $game_variables[$1.to_i].to_s }
                    .gsub(/\\[Nn]\[([0-9]+)\]/) { ($game_actors[$1.to_i]&.name).to_s }
                    .gsub(/\\[Cc]\[[0-9]+\]|\\[Gg]/, '')
    text.chomp.split("\n", -1).sum do |line|
      rows, x = 1, 0
      line.each_char do |c|
        w = @measure.text_size(c).width
        if x + 4 + w > 448
          rows += 1
          x = 0
        end
        x += w
      end
      rows
    end
  end

  # 战利品：开打前掷好，名字写进 $trea1～4 给战斗结算窗口显示
  def self.data_of(kind)
    { item: $data_items, weapon: $data_weapons, armor: $data_armors }.fetch(kind)
  end

  #   [:missing, [[:armor, 78], [:armor, 86]], 1, 几率]：从列表里挑一件身上还没有的（都有了就随便一件）
  def self.roll_loot(loot)
    loot = loot.map do |e|
      next e unless e[0] == :missing
      list = e[1]
      pick = list.find { |k, i| owned(k, i) == 0 } || list.sample
      [pick[0], pick[1], e[2], e[3]]
    end
    @loot = loot.select { |_, _, _, chance| chance.nil? || rand(100) < chance }
    names = (0...4).map { |i| (k = @loot[i]) ? data_of(k[0])[k[1]].name : '' }
    $trea1, $trea2, $trea3, $trea4 = names
  end

  def self.owned(kind, id)
    case kind
    when :item then $game_party.item_number(id)
    when :weapon then $game_party.weapon_number(id)
    when :armor then $game_party.armor_number(id)
    end
  end

  # 运行时决定货单的商店（江湖货郎等）：goods 为 [[:weapon, 48], [:armor, 80]]
  def self.open_shop(goods)
    $game_temp.shop_type = 1
    $game_temp.battle_abort = true
    $game_temp.shop_goods = goods.map { |kind, id| [Commands::SHOP_KINDS.fetch(kind), id] }
    $game_temp.shop_calling = true
  end

  def self.give_loot
    (@loot || []).each do |kind, id, n|
      case kind
      when :item then $game_party.gain_item(id, n || 1)
      when :weapon then $game_party.gain_weapon(id, n || 1)
      when :armor then $game_party.gain_armor(id, n || 1)
      end
    end
    @loot = nil
  end

  def self.gain_morality(n)
    $game_variables[160] = [[$game_variables[160] + n, 0].max, 255].min
  end

  class << self
    attr_reader :maps, :edits, :enemies, :weapons, :armors, :skills, :items, :variable_names, :common_events

    # 新公共事件（编号接着原版连续，从 26 起）。物品的 common_event_id 指向它时，使用物品就执行它。
    #   WebMod.common_event 26, '使用-无相残卷' do |c| ... end
    def common_event(id, name, &block)
      raise ArgumentError, "WebMod.common_event #{id}：新编号要从 26 开始" if id < 26
      raise ArgumentError, "WebMod.common_event #{id}：重复定义" if @common_events[id]
      @common_events[id] = { name: name, block: block }
    end

    # 不需要固定编号的公共事件（江湖奇遇等由程序启动的事件），编号在读取时接着排。
    #   WebMod.auto_common_event(:奇遇_1, '奇遇-山贼劫道') { |c| ... }
    #   WebMod.auto_common_event_id(:奇遇_1)  # => 读取后分到的编号
    def auto_common_event(key, name, &block)
      raise ArgumentError, "WebMod.auto_common_event #{key}：重复定义" if @auto_events[key]
      @auto_events[key] = { name: name, block: block }
    end

    def auto_common_event_id(key)
      @auto_event_ids[key]
    end

    # 给变量起名。新武功（武功编号就是变量编号）在技能窗口、练功、师傅列表里显示的就是这个名字
    def variable_name(id, name)
      @variable_names[id] = name
    end

    # 定义一个能战斗的 NPC 的数据（敌人、敌群、数值表），在地图里用 npc(..., fight: 编号) 摆放。
    #   like：以哪个原版 NPC 为模板（敌人编号），复制它的全部数据后再改
    #   tile：人物头像 824～887，战斗画面自动用对应的 NPC_Tile 图
    #   maxhp / maxsp / gold：气血、内力上限、掉落金钱
    #   stats：数值表字段，键见 NPC_FIELDS，例如 { 膂力: 30, 闪避: 20, 经验: 50000 }
    #   skills：{ 武功编号 => 等级 }，最多 12 门，给出时整体替换模板的武功
    #   elite：true 时像原版 126 号以后的强敌一样不会被流星飞掷击中
    #   battler：战斗图文件名（Graphics/Battlers），不写时用头像对应的 NPC_Tile 图
    def enemy(id, name:, tile:, like:, maxhp: nil, maxsp: nil, gold: nil, stats: {}, skills: nil, elite: false, battler: nil)
      raise ArgumentError, "WebMod.enemy #{id}：新敌人编号要从 #{FIRST_ENEMY_ID} 开始" if id < FIRST_ENEMY_ID
      raise ArgumentError, "WebMod.enemy #{id}：重复定义" if @enemies[id]
      raise ArgumentError, "WebMod.enemy #{id}：模板 #{like} 不能用（随机、舞林大会或数据不全）" if !like.between?(1, FIRST_ENEMY_ID - 1) || BAD_TEMPLATES.include?(like)
      raise ArgumentError, "WebMod.enemy #{id}：tile 应是人物头像 824～887" unless (824..887).include?(tile)
      raise ArgumentError, "WebMod.enemy #{id}：名字“恶人”被原版留作随机恶人" if name == '恶人'
      bad = stats.keys - NPC_FIELDS.keys
      raise ArgumentError, "WebMod.enemy #{id}：未知的数值字段 #{bad.join('、')}，可用：#{NPC_FIELDS.keys.join('、')}" unless bad.empty?
      raise ArgumentError, "WebMod.enemy #{id}：武功最多 12 门" if skills && skills.size > 12
      @enemies[id] = { name: name, tile: tile, like: like, maxhp: maxhp, maxsp: maxsp, gold: gold,
                       stats: stats, skills: skills, elite: elite, battler: battler }
    end

    # 新武器 / 新绝招：复制一件原版条目后改字段，读取 Weapons.rxdata / Skills.rxdata 时追加。
    #   WebMod.weapon 31, like: 25, name: '齐眉棍', atk: 22, price: 500, description: '……'
    #   WebMod.skill  28, like: 22, name: '天下无狗', sp_cost: 450, description: '……'
    # 编号要接着原版连续编号（武器 31 起、绝招 28 起）。武器还要在武功注册表登记类型
    # （WebSkill.weapon_type），绝招要登记由哪门武功学会（WebSkill.perform）和效果。
    def weapon(id, like:, **attrs)
      define_record(@weapons, 'Weapons', 31, id, like, attrs)
    end

    def skill(id, like:, **attrs)
      define_record(@skills, 'Skills', 28, id, like, attrs)
    end

    # 新防具，编号从 32 起。kind（部位）：0 鞋 1 头饰 2 外衣 3 盔甲 4 披风 5 腰带 6 钓竿。
    # 用 19 披风、30 牛皮束带、31 钓竿当模板时一定要写 kind：原版按编号认定它们的部位
    # （012 Data_String 重写了 Armor#kind），数据里存的是 0，复制过来会变成鞋
    #   WebMod.armor 32, like: 4, name: '斗笠', kind: 1, pdef: 4, price: 120, description: '……'
    def armor(id, like:, **attrs)
      define_record(@armors, 'Armors', 32, id, like, attrs)
    end

    # 新物品，编号从 23 起：WebMod.item 23, like: 19, name: '……', description: '……'
    def item(id, like:, **attrs)
      define_record(@items, 'Items', 23, id, like, attrs)
    end

    def define_record(table, what, first, id, like, attrs)
      raise ArgumentError, "WebMod #{what} #{id}：新编号要从 #{first} 开始" if id < first
      raise ArgumentError, "WebMod #{what} #{id}：重复定义" if table[id]
      raise ArgumentError, "WebMod #{what} #{id}：缺少 name" unless attrs[:name]
      table[id] = { like: like, attrs: attrs }
    end

    def append_records(list, table, what)
      table.keys.sort.each do |id|
        d = table[id]
        base = list[d[:like]]
        raise ArgumentError, "WebMod #{what} #{id}：模板 #{d[:like]} 不存在" unless base && d[:like] < list.size
        r = Marshal.load(Marshal.dump(base))
        r.id = id
        d[:attrs].each do |k, v|
          raise ArgumentError, "WebMod #{what} #{id}：没有字段 #{k}" unless r.respond_to?("#{k}=")
          r.send("#{k}=", v)
        end
        list[id] = r
      end
      raise ArgumentError, "WebMod #{what}：编号要连续，现在中间有空位" if (1...list.size).any? { |i| list[i].nil? }
    end

    # 流星飞掷对原版 126 号以后的敌人无效；新敌人默认可以被击中，elite 的除外
    def finisher_immune?(enemy_id)
      d = @enemies[enemy_id]
      d ? d[:elite] : enemy_id > 125
    end

    # 新敌人的数值表：复制模板的一行再改
    def npc_row(id, original)
      d = @enemies[id]
      row = Marshal.load(Marshal.dump(original.call(d[:like])))
      d[:stats].each { |k, v| row[NPC_FIELDS[k]] = v }
      if d[:skills]
        pairs = d[:skills].map { |sk, lv| [sk, lv] }
        12.times { |i| row[12 + i] = pairs[i] || [0, 0] }
      end
      row
    end

    # 定义一张新地图。base：复制哪张地图的地形、尺寸、图块集和音乐（事件会被清空）。
    def map(id, name:, base:, parent: 0, &block)
      raise ArgumentError, "WebMod.map #{id}：新地图编号要从 #{FIRST_MAP_ID} 开始" if id < FIRST_MAP_ID
      raise ArgumentError, "WebMod.map #{id}：重复定义" if @maps[id]
      raise ArgumentError, "WebMod.map #{id}：base 必须是原版地图 1～51" unless ORIGINAL_MAPS.include?(base)
      @maps[id] = { name: name, base: base, parent: parent, block: block }
    end

    # 修改一张原版地图：追加事件、改地形
    def edit(id, &block)
      raise ArgumentError, "WebMod.edit #{id}：只能修改原版地图 1～51，新地图请写在 WebMod.map 里" unless ORIGINAL_MAPS.include?(id)
      @edits[id] << block
    end

    def map_id_of(fn)
      fn.to_s =~ /Map(\d{3})\.rxdata\z/i ? $1.to_i : nil
    end

    # load_data 在读文件前调用：是新地图就返回生成的 RPG::Map，否则返回 nil
    def generate(fn)
      id = map_id_of(fn)
      d = id && @maps[id]
      return nil unless d
      map = raw_load(fn.sub(/Map\d{3}\.rxdata\z/i, format('Map%03d.rxdata', d[:base])))
      map.events = {}
      b = Builder.new(map, id, 1)
      d[:block].call(b) if d[:block]
      map
    end

    # load_data 读入原版文件后调用
    def patch(fn, obj)
      if fn.to_s =~ /MapInfos\.rxdata\z/i
        patch_mapinfos(obj)
      elsif fn.to_s =~ /Enemies\.rxdata\z/i
        patch_enemies(obj)
      elsif fn.to_s =~ /Troops\.rxdata\z/i
        patch_troops(obj)
      elsif fn.to_s =~ /Weapons\.rxdata\z/i
        append_records(obj, @weapons, 'Weapons')
      elsif fn.to_s =~ /Skills\.rxdata\z/i
        append_records(obj, @skills, 'Skills')
      elsif fn.to_s =~ /Armors\.rxdata\z/i
        append_records(obj, @armors, 'Armors')
      elsif fn.to_s =~ /Items\.rxdata\z/i
        append_records(obj, @items, 'Items')
      elsif fn.to_s =~ /CommonEvents\.rxdata\z/i
        build = lambda do |id, d|
          ce = RPG::CommonEvent.new
          ce.id = id
          ce.name = d[:name]
          c = Commands.new
          d[:block].call(c)
          ce.list = c.finish
          obj[id] = ce
        end
        @common_events.keys.sort.each { |id| build.call(id, @common_events[id]) }
        raise ArgumentError, 'WebMod.common_event：编号要连续，现在中间有空位' if (1...obj.size).any? { |i| obj[i].nil? }
        @auto_events.each do |key, d|
          @auto_event_ids[key] = obj.size
          build.call(obj.size, d)
        end
      elsif fn.to_s =~ /System\.rxdata\z/i
        @variable_names.each do |id, name|
          raise ArgumentError, "WebMod.variable_name #{id}：原版已有名字“#{obj.variables[id]}”" unless obj.variables[id].to_s.empty?
          obj.variables[id] = name
        end
      elsif (id = map_id_of(fn)) && @edits.key?(id)
        b = Builder.new(obj, id, FIRST_EDIT_EVENT_ID)
        @edits[id].each { |blk| blk.call(b) }
      end
      obj
    end

    # 不经过扩展层读取原版数据（复制模板地图、测试对比时用）
    def raw_load(fn)
      RGWeb.fix_enc(Marshal.load(File.open(RGWeb.utf8(fn.to_s), 'rb') { |f| f.read }))
    end

    # 敌人：复制模板后改名字、战斗图和气血等。编号按顺序追加，中间不留空位。
    def patch_enemies(list)
      @enemies.keys.sort.each do |id|
        d = @enemies[id]
        e = Marshal.load(Marshal.dump(list[d[:like]]))
        e.id = id
        e.name = d[:name]
        e.battler_name = d[:battler] || format('NPC_Tile_%02d', d[:tile] - 823)
        e.maxhp = d[:maxhp] if d[:maxhp]
        e.maxsp = d[:maxsp] if d[:maxsp]
        e.gold = d[:gold] if d[:gold]
        list[id] = e
      end
      raise ArgumentError, "WebMod.enemy：敌人编号要从 #{FIRST_ENEMY_ID} 起连续，现在中间有空位" if (1...list.size).any? { |i| list[i].nil? }
    end

    # 敌群：与敌人同编号（原版惯例），复制模板 NPC 的敌群后换成新敌人
    def patch_troops(list)
      @enemies.keys.sort.each do |id|
        d = @enemies[id]
        t = Marshal.load(Marshal.dump(list[d[:like]]))
        t.id = id
        t.name = d[:name]
        t.members[0].enemy_id = id
        list[id] = t
      end
      raise ArgumentError, "WebMod.enemy：敌群编号要从 #{FIRST_ENEMY_ID} 起连续，现在中间有空位" if (1...list.size).any? { |i| list[i].nil? }
    end

    def patch_mapinfos(infos)
      order = infos.values.map(&:order).max || 0
      @maps.keys.sort.each do |id|
        d = @maps[id]
        raise ArgumentError, "WebMod.map #{id}：父地图 #{d[:parent]} 不存在" if d[:parent] != 0 && !infos[d[:parent]] && !@maps[d[:parent]]
        info = RPG::MapInfo.new
        info.name = d[:name]
        info.parent_id = d[:parent]
        info.order = (order += 1)
        infos[id] = info
      end
    end
  end

  #--------------------------------------------------------------------------
  # 地图构建器：WebMod.map / WebMod.edit 的块参数
  #--------------------------------------------------------------------------
  class Builder
    attr_reader :map, :map_id, :tile_edits, :touched_events, :stocked_events, :rewritten_events

    def initialize(map, map_id, first_event_id)
      @map = map
      @map_id = map_id
      @next_id = [first_event_id, (map.events.keys.max || 0) + 1].max
      @tile_edits = []
      @touched_events = []
      @stocked_events = []
      @rewritten_events = []
    end

    # 给原版 NPC 换上新的交谈内容。who 是事件编号或 NPC 名字（地图上唯一）。
    #   默认只替换“一般交谈”（公共事件 3，那几句“今天天气真是，哈哈”）这一条，NPC 原有的任务判断全部保留；
    #   override: true 用于本来就有自己台词的 NPC：替换交谈分支的内容，但保留外层的平一指任务判断。
    #     注意 override 会去掉这个 NPC 交谈分支里原有的其他剧情逻辑，只用于台词固定、没有任务的 NPC。
    #   每一页里有“交谈”分支的都会替换（NPC 有多页时各页一致）。
    def talk(who, override: false, &block)
      raise ArgumentError, 'talk 需要块' unless block
      e = find_event(who)
      done = 0
      e.pages.each do |pg|
        list = pg.list
        i = list.index { |c| c.code == 402 && c.parameters[1] == '交谈' } or next
        base = list[i].indent
        j = i + 1
        j += 1 while j < list.size && list[j].indent > base
        generic = (i + 1...j).select { |k| list[k].code == 117 && list[k].parameters[0] == 3 }
        if !override
          raise ArgumentError, "地图 #{@map_id} 的 #{e.name}：交谈不是“一般交谈”，它有自己的台词或任务；确实要替换请加 override: true" unless generic.size == 1
          k = generic[0]
          list[k, 1] = Commands.new(list[k].indent).tap { |c| block.call(c) }.fragment
        else
          first = list[i + 1]
          if first && first.code == 111 && first.parameters[0] == 1 && first.parameters[1] == 2
            # 外层是平一指任务判断：替换它 else 部分的内容
            els = (i + 1...j).find { |k| list[k].code == 411 && list[k].indent == base + 1 }
            raise ArgumentError, "地图 #{@map_id} 的 #{e.name}：交谈分支结构不认识" unless els
            stop = els + 1
            stop += 1 while list[stop].indent > base + 1
            # list[stop - 1] 是 else 段末尾的结束标记（code 0），保留
            list[els + 1...stop - 1] = Commands.new(base + 2).tap { |c| block.call(c) }.fragment
          else
            list[i + 1...j - 1] = Commands.new(base + 1).tap { |c| block.call(c) }.fragment
          end
        end
        done += 1
      end
      raise ArgumentError, "地图 #{@map_id} 的 #{e.name}：没有“交谈”选项" if done == 0
      @touched_events << e.id
      e
    end

    def find_event(who)
      return @map.events[who] || raise(ArgumentError, "地图 #{@map_id} 没有事件 #{who}") if who.is_a?(Integer)
      found = @map.events.values.select { |e| e.name == who }
      raise ArgumentError, "地图 #{@map_id} 上没有叫“#{who}”的事件" if found.empty?
      raise ArgumentError, "地图 #{@map_id} 上有 #{found.size} 个“#{who}”，请改用事件编号" if found.size > 1
      found[0]
    end

    # 改地形：layer 0 最下层，图块编号见 docs/图块总览.png
    def tile(x, y, layer, tile_id)
      check_xy(x, y, 'tile')
      @map.data[x, y, layer] = tile_id
      @tile_edits << [x, y, layer]
      self
    end

    # 通用事件。块参数是 Commands，用来写指令；返回 RPG::Event。
    #   trigger：0 确定键  1 主角接触  2 事件接触  3 自动  4 并行
    #   sprite：自制外观（Graphics/Characters 里的行走图），代替 tile；行走图事件不可通行，站在旁边就能调查
    #   switch：这个开关打开时事件才出现（原版的事件页条件），可以写两个：[142, 146]
    #   variable：[变量, 最小值]，变量达到这个值时才出现
    #   once：事件里执行 c.done（打开自开关 A）以后，事件就消失（追加一个空白页）
    def event(x, y, name: '', tile: 0, sprite: nil, trigger: 0, through: false, switch: nil, variable: nil, once: false, &block)
      check_xy(x, y, name.empty? ? 'event' : name)
      e = RPG::Event.new(x, y)
      e.id = @next_id
      e.name = name.empty? ? format('EV%03d', @next_id) : name
      page = e.pages[0]
      page.graphic.tile_id = tile
      if sprite
        page.graphic.tile_id = 0
        page.graphic.character_name = sprite
        page.graphic.direction = 2
        page.graphic.pattern = 0
        page.direction_fix = true                   # 各帧相同，转向也没有意义
      end
      page.trigger = trigger
      page.through = through
      sw = Array(switch)
      raise ArgumentError, "event #{name}：switch 最多两个" if sw.size > 2
      if sw[0]
        page.condition.switch1_valid = true
        page.condition.switch1_id = sw[0]
      end
      if sw[1]
        page.condition.switch2_valid = true
        page.condition.switch2_id = sw[1]
      end
      if variable
        page.condition.variable_valid = true
        page.condition.variable_id, page.condition.variable_value = variable
      end
      c = Commands.new
      block.call(c) if block
      page.list = c.finish
      if once
        gone = RPG::Event::Page.new
        gone.condition = Marshal.load(Marshal.dump(page.condition))
        gone.condition.self_switch_valid = true
        gone.condition.self_switch_ch = 'A'
        gone.through = true
        e.pages << gone
      end
      @map.events[e.id] = e
      @next_id += 1
      e
    end

    # NPC：照原版模板生成（名牌 → 交谈 / 查看 [/ 战斗] → 取消），见 docs/地图扩展指南.md 3.1。
    #   tile：人物头像图块，824～887
    #   talk：交谈内容，每个字符串是一页对话，一次交谈按顺序全部说完；
    #         想每次随机说一句，或需要条件分支时，改用块（c.one_of / c.random / c.if_*）：
    #         m.npc(...) { |c| c.if_switch(102) { c.text '……' }.else { c.text '……' } }
    #   look：查看的描述。字符串，或 { age:, level:, attack:, items:, text: }。text 自动按 20 字一行拆开，最多 100 字
    #         age 是年龄的十位数（3 → “30多岁”），level / attack 是 $levels / $attacks 的下标
    #   fight：能战斗时给出敌人编号（WebMod.enemy 定义），或 { enemy:, loot:, morality:, switch:, lose:, corpse: }
    #         loot：战胜后得到的东西，[[:armor, 4], [:weapon, 15], [:item, 16, 2]]，最多 4 种
    #         morality：杀死后道德值（变量 160）的变化，[道德 ≥ 128 时, 道德 < 128 时]，例如 [-10, -5]
    #         switch：杀死后打开的开关（记录这个人已死，剧情判断用）
    #         lose：战败时，:death（默认，公共事件 25：道德低则死，否则“承让了。”）或一句台词（切磋）
    #         corpse：死后显示的图块，默认 508
    #         杀死后：自开关 A 打开（事件换成第 2 页的尸体），$live[编号] 记为 false。
    #         name、tile 不写时取敌人定义里的。
    #   shop：卖的东西，[[:weapon, 31], [:item, 2], [:armor, 4]]，加一个“交易”选项（与原版小商贩相同）；
    #         也可以是 lambda { |c| ... }，自己写“交易”分支（按条件 c.shop 不同的货，见 070_门派军需官.rb）
    #   sprite：自制外观（Graphics/Characters 里的行走图，用 tools/make_npc_sprite.py 从 32×32 素材生成），
    #         代替图块集里的头像。tile 仍要填一个头像编号：不写 battler 时战斗图按它取
    LOOK_LINE = 20
    NO_LINE_START = '，。、；：！？”’）》」』…'

    # 按 20 字拆行；标点不放在行首，挂到上一行末尾（多一个字会被略微压窄，不会被截掉）
    def split_look(text)
      lines = []
      text.each_char do |ch|
        if lines.empty? || (lines[-1].size >= LOOK_LINE && !NO_LINE_START.include?(ch))
          lines << +''
        end
        lines[-1] << ch
      end
      lines
    end

    def npc(x, y, name: nil, tile: nil, talk: [], look: nil, fight: nil, shop: nil, sprite: nil, switch: nil, variable: nil, once: false, &block)
      fight = { enemy: fight } if fight.is_a?(Integer)
      if fight
        d = WebMod.enemies[fight[:enemy]]
        raise ArgumentError, "npc：敌人 #{fight[:enemy]} 没有用 WebMod.enemy 定义" unless d
        name ||= d[:name]
        tile ||= d[:tile]
      end
      raise ArgumentError, 'npc：缺少 name' unless name
      raise ArgumentError, "npc #{name}：tile 应是人物头像 824～887" unless tile && (824..887).include?(tile)
      look = { text: look } if look.is_a?(String)
      look = { age: 3, level: 0, attack: 0, items: '布衣', text: '' }.merge(look || {})
      # 查看界面每行只画一次、宽约 20 个汉字，原版把描述拆成最多 5 行（str1～str5）
      lines = split_look(look[:text].to_s)
      raise ArgumentError, "npc #{name}：查看描述超过 #{LOOK_LINE * 5} 字" if lines.size > 5
      args = [name, look[:age].to_s].map(&:inspect).join(',') +
             ",$levels[#{look[:level].to_i}],$attacks[#{look[:attack].to_i}]," +
             [look[:items], *lines].map(&:inspect).join(',')
      labels = %w[交谈 查看]
      labels << '战斗' if fight
      labels << '交易' if shop
      raise ArgumentError, "npc #{name}：能战斗的 NPC 自带尸体页，不能再用 once" if once && fight
      e = event(x, y, name: name, tile: tile, sprite: sprite, switch: switch, variable: variable, once: once) do |c|
        c.script '@s=Draw_event_name.new'
        c.choices(labels) do |i|
          case labels[i]
          when '交谈' then block ? block.call(c) : Array(talk).each { |t| c.text t }
          when '查看' then c.script "$scene=Lookover.new(#{args})"
          when '战斗' then fight_commands(c, fight)
          when '交易' then shop.respond_to?(:call) ? shop.call(c) : c.shop(shop)
          end
        end
        c.script '@s.dispose'
      end
      add_corpse_page(e, fight[:corpse] || 508) if fight
      e
    end
    # 重写原版事件第 1 页的指令（外观、触发方式不变），用于原版的机关类事件（例如南郊的两个钓点）。
    # NPC 的台词请用 talk，不要用它
    def rewrite(who, &block)
      e = find_event(who)
      e.pages[0].list = Commands.new.tap { |c| block.call(c) }.finish
      @rewritten_events << e.id
      e
    end

    # 给原版商人加货：who 是事件编号或名字，goods 同 npc 的 shop
    #   m.goods '何铁手', [[:weapon, 37]]
    def goods(who, goods)
      e = find_event(who)
      done = 0
      e.pages.each do |pg|
        list = pg.list
        i = list.index { |c| c.code == 302 } or next
        j = i + 1
        j += 1 while list[j] && list[j].code == 605
        add = goods.map do |kind, id|
          raise ArgumentError, "goods 种类应是 :item / :weapon / :armor" unless Commands::SHOP_KINDS[kind]
          RPG::EventCommand.new(605, list[i].indent, [Commands::SHOP_KINDS[kind], id])
        end
        list.insert(j, *add)
        done += 1
      end
      raise ArgumentError, "地图 #{@map_id} 的 #{e.name}：不是商人" if done == 0
      @stocked_events << e.id
      e
    end

    # 传送点：主角踩上去时播放 Move 音效并传送（与原版 EV 事件相同）。
    #   to：[地图, x, y]；dir：传送后朝向，0 保持 2 下 4 左 6 右 8 上
    def door(x, y, to:, dir: 0)
      event(x, y, trigger: 1) do |c|
        c.se 'Move'
        c.transfer(*to, dir)
      end
    end

    private

    # 战斗分支，照原版 NPC（例如地图 3 道德和尚）的写法
    LOOT_CODES = { item: [126, '$data_items'], weapon: [127, '$data_weapons'], armor: [128, '$data_armors'] }

    def fight_commands(c, f)
      id = f[:enemy]
      loot = f[:loot] || []
      raise ArgumentError, "npc 敌人 #{id}：loot 最多 4 种" if loot.size > 4
      loot.each { |kind, *| raise ArgumentError, "npc 敌人 #{id}：loot 种类应是 :item / :weapon / :armor" unless LOOT_CODES[kind] }
      # $trea1..4 是战斗结果窗口显示的战利品名字
      names = (0...4).map { |i| loot[i] ? "#{LOOT_CODES[loot[i][0]][1]}[#{loot[i][1]}].name" : '""' }
      c.script(["@s.dispose", *names.each_with_index.map { |n, i| "$trea#{i + 1}=#{n}" }].join("\n"))
      c.battle(id,
        win: lambda {
          c.if_switch(95) do                                   # 战胜后选择了“杀”
            if (m = f[:morality])
              delta = lambda { |v| c.variable(160, v.abs, v < 0 ? 2 : 1) if v != 0 }
              c.if_variable(160, 128, 1) { delta.call(m[0]) }.else { delta.call(m[1]) }
            end
            c.cmd(123, 'A', 0)
            c.switch(f[:switch]) if f[:switch]
            c.script "$live[#{id}]=false\n$scene=Scene_Map.new"
          end
          loot.each { |kind, lid, n| c.cmd(LOOT_CODES[kind][0], lid, 0, 0, n || 1) }
          c.switch(95, false)
        },
        lose: lambda {
          lose = f[:lose] || :death
          lose == :death ? c.cmd(117, 25) : c.text(lose.to_s)
        })
    end

    # 第 2 页：自开关 A 打开后显示尸体，不能交互
    def add_corpse_page(e, tile)
      pg = RPG::Event::Page.new
      pg.condition.self_switch_valid = true
      pg.condition.self_switch_ch = 'A'
      pg.graphic.tile_id = tile
      e.pages << pg
    end

    def check_xy(x, y, what)
      return if x.between?(0, @map.width - 1) && y.between?(0, @map.height - 1)
      raise ArgumentError, "地图 #{@map_id} 的 #{what}：坐标 (#{x},#{y}) 超出地图范围 #{@map.width}×#{@map.height}"
    end
  end

  #--------------------------------------------------------------------------
  # 事件指令构建器：自动处理缩进和分支结束标记
  #--------------------------------------------------------------------------
  class Commands
    def initialize(indent = 0)
      @list = []
      @base = @indent = indent
    end

    def cmd(code, *params)
      @list << RPG::EventCommand.new(code, @indent, params)
      self
    end

    # 一页对话（消息窗口会自动换行）
    def text(s)
      cmd(101, s)
    end

    # 一页内容在运行时才决定的对话：expr 是一段 Ruby 表达式，结果是要显示的文字
    #   c.say 'WebLife.landed_text'
    def say(expr)
      script "web_say(#{expr})"
    end

    # 脚本：多行时第一行用 355，后续行用 655
    def script(code)
      lines = code.to_s.split("\n")
      cmd(355, lines.shift || '')
      lines.each { |l| cmd(655, l) }
      self
    end

    def se(name, volume = 100, pitch = 100)
      cmd(250, RPG::AudioFile.new(name, volume, pitch))
    end

    def transfer(map_id, x, y, dir = 0)
      cmd(201, 0, map_id, x, y, dir, 0)
    end

    def switch(id, on = true)
      cmd(121, id, id, on ? 0 : 1)
    end

    # 变量赋值 / 加减：op 0 赋值 1 加 2 减
    def variable(id, value, op = 0)
      cmd(122, id, id, op, 0, value)
    end

    # 打开本事件的自开关 A（配合 event / npc 的 once: true，事件办完后消失）
    def done
      cmd(123, 'A', 0)
    end

    def wait(frames)
      cmd(106, frames)
    end

    # 显示图片（Graphics/Pictures 里的文件）。center 为 true 时 x、y 是图片中心。
    # 游戏画面 640×480，底部对话框约占 160，所以对话时图片放在上方，例如 288×288 的图中心放在 (320, 168)
    def show_picture(number, name, x: 320, y: 168, center: true, opacity: 255)
      cmd(231, number, name, center ? 1 : 0, 0, x, y, 100, 100, opacity, 0)
    end

    def erase_picture(number)
      cmd(235, number)
    end

    # 物品增减：kind 为 :item / :weapon / :armor
    ITEM_CODES = { item: 126, weapon: 127, armor: 128 }

    def gain(kind, id, n = 1)
      cmd(ITEM_CODES.fetch(kind), id, 0, 0, n)
    end

    def lose(kind, id, n = 1)
      cmd(ITEM_CODES.fetch(kind), id, 1, 0, n)
    end

    # 金钱：负数为减少（不会扣成负数）。原版的金钱校验在 gain_gold 里同步
    def gold(n)
      n >= 0 ? cmd(125, 0, 0, n) : cmd(125, 1, 0, -n)
    end

    # 经验 / 潜能 / 道德 / 通缉值，同步原版的校验变量（152 经验、153 潜能），否则会被判作弊
    #   c.reward exp: 300, pot: 100, morality: -5, wanted: 1
    #   wanted 记在变量 164“通缉值”（官府对你的通缉）。注意原版的变量 159“追杀数”是杀死的恶人数，
    #   越多越好（结局“无情名捕”），不是通缉。
    def reward(exp: 0, pot: 0, morality: 0, wanted: 0)
      lines = []
      lines << "WebMod.gain_exp(#{exp.to_i})" if exp != 0
      lines << "WebMod.gain_pot(#{pot.to_i})" if pot != 0
      lines << "WebMod.gain_morality(#{morality.to_i})" if morality != 0
      lines << "$game_variables[164]=[$game_variables[164]+#{wanted.to_i},0].max" if wanted != 0
      script lines.join("\n") unless lines.empty?
      self
    end

    # 战斗：win / escape / lose 是各分支要执行的 lambda（可省略）
    def battle(troop_id, can_escape: true, can_lose: true, win: nil, escape: nil, lose: nil)
      cmd(301, troop_id, can_escape, can_lose)
      cmd(601); nested { win&.call }
      cmd(602); nested { escape&.call }
      cmd(603); nested { lose&.call }
      cmd(604)
    end

    # 打一场（江湖奇遇等事件里用）。敌人编号同敌群编号。
    #   loot：[[:armor, 32], [:weapon, 35, 1, 20]]，第 4 项是掉落几率（%，不写为 100），最多 4 种；
    #         [:missing, [[:armor, 78], [:armor, 86]], 1, 50] 掉一件身上还没有的；
    #         开打前就掷好，结算窗口显示实际掉落的东西
    #   win：打赢后（无论杀不杀），killed / spared：打赢后选了“劈” / “不劈”；lose：打输；escape：逃走
    def fight(enemy_id, loot: [], can_escape: true, win: nil, killed: nil, spared: nil, escape: nil, lose: nil)
      raise ArgumentError, "fight #{enemy_id}：loot 最多 4 种" if loot.size > 4
      loot.each { |kind, *| raise ArgumentError, "fight #{enemy_id}：loot 种类应是 :item / :weapon / :armor / :missing" unless ITEM_CODES[kind] || kind == :missing }
      script "WebMod.roll_loot(#{loot.inspect})"
      battle(enemy_id, can_escape: can_escape, can_lose: true,
        win: lambda {
          script 'WebMod.give_loot'
          if_switch(95) { killed&.call }.else { spared&.call }
          switch(95, false)
          win&.call
        },
        escape: escape, lose: lose)
    end

    # 商店（与原版小商贩相同）：goods 为 [[:weapon, 31], [:item, 2], [:armor, 4]]
    SHOP_KINDS = { item: 0, weapon: 1, armor: 2 }
    def shop(goods)
      raise ArgumentError, 'shop 至少要有一样东西' if goods.empty?
      goods.each { |kind, _| raise ArgumentError, 'shop 种类应是 :item / :weapon / :armor' unless SHOP_KINDS[kind] }
      script '$game_temp.shop_type=1'
      kind, id = goods[0]
      cmd(302, SHOP_KINDS[kind], id)
      goods[1..].each { |k, i| cmd(605, SHOP_KINDS[k], i) }
      self
    end

    # 选项。块对每个选项调用一次，参数是选项下标；取消键进入单独的取消分支（与原版 NPC 一致）
    def choices(labels, &block)
      cmd(102, labels, 5)
      labels.each_with_index do |label, i|
        cmd(402, i, label)
        nested { block.call(i) }
      end
      cmd(403)
      nested {}
      cmd(404)
    end

    # 条件分歧：开关。返回 Branch，可以接 .else { ... }
    def if_switch(id, on = true, &block)
      branch([0, id, on ? 0 : 1], &block)
    end

    # 条件分歧：变量。cmp 0 等于 1 以上 2 以下 3 大于 4 小于 5 不等于
    def if_variable(id, value, cmp = 0, &block)
      branch([1, id, 0, value, cmp], &block)
    end

    # 条件分歧：脚本（结果为真时执行）。
    # 原版的条件分歧只认严格的 true / false：结果是 31 这类“真值”时“是”和“否则”两段都会被跳过，
    # 所以这里一律转成布尔值
    def if_script(code, &block)
      branch([12, "!!(#{code})"], &block)
    end

    def finish
      raise '事件指令的分支没有闭合' unless @indent == 0
      @list << RPG::EventCommand.new(0, 0, [])
      @list
    end

    # 插入到现有事件中间的一段指令（不加结尾标记）
    def fragment
      raise '事件指令的分支没有闭合' unless @indent == @base
      @list
    end

    # 随机执行一个分支：块对每个下标调用一次。用变量 9 暂存随机数（原版“一般交谈”也这样用，读档时清零）
    def random(n, &block)
      script "$game_variables[9]=rand(#{n})"
      n.times { |i| if_variable(9, i) { block.call(i) } }
      self
    end

    # 随机说一句
    def one_of(*texts)
      texts = texts.flatten
      return text(texts[0]) if texts.size == 1
      random(texts.size) { |i| text texts[i] }
    end

    # 常用条件
    def if_dead(enemy_id, &block)          # 这个 NPC 已被杀（$live 按敌人编号记录）
      if_script("$live[#{enemy_id}]==false", &block)
    end

    def if_good(&block)                    # 道德值 ≥ 128（原版的正邪分界）
      if_variable(160, 128, 1, &block)
    end

    def if_gold(n, &block)                 # 身上银两 ≥ n
      if_script("$game_party.gold>=#{n.to_i}", &block)
    end

    def if_has(kind, id, n = 1, &block)    # 身上有某件东西（本作装备着的东西仍算在背包里）
      code = { item: 'item_number', weapon: 'weapon_number', armor: 'armor_number' }[kind] or
        raise(ArgumentError, 'if_has 种类应是 :item / :weapon / :armor')
      code = "$game_party.#{code}(#{id})>=#{n}"
      if_script(code, &block)
    end

    # 条件分歧的 else 部分。必须紧跟在 if_* 之后调用。
    class Branch
      def initialize(commands, end_index)
        @c = commands
        @end_index = end_index
      end

      def else(&block)
        @c.send(:insert_else, @end_index, &block)
        self
      end
    end

    private

    def nested
      @indent += 1
      yield
      cmd(0)
      @indent -= 1
    end

    def branch(params, &block)
      cmd(111, *params)
      nested(&block)
      cmd(412)
      Branch.new(self, @list.size - 1)
    end

    # 把 412（分支结束）替换成 411 else 段 + 412
    def insert_else(end_index, &block)
      raise 'else 必须紧跟在 if_switch / if_variable / if_script 之后' unless end_index == @list.size - 1 && @list[end_index].code == 412
      @list.pop
      cmd(411)
      nested(&block)
      cmd(412)
    end
  end
end

#--------------------------------------------------------------------------
# c.say 的执行：和 101 显示文章一样设置对话内容，并让解释器等玩家看完再往下走
#   （脚本返回 false 时原版会在下一帧重跑同一条指令，所以这里一定返回 true）
#--------------------------------------------------------------------------
class Interpreter
  def web_say(text)
    @message_waiting = true
    $game_temp.message_proc = Proc.new { @message_waiting = false }
    $game_temp.message_text = text.to_s + "\n"
    true
  end
end

#--------------------------------------------------------------------------
# 013 Data_NPC：新敌人的数值表（战斗开始时 Scene_Battle 按敌人编号调用）
#--------------------------------------------------------------------------
alias __webmod_get_npc_data get_npc_data
def get_npc_data(id)
  return $npc_data = WebMod.npc_row(id, method(:__webmod_get_npc_data)) if WebMod.enemies.key?(id)
  __webmod_get_npc_data(id)
end
