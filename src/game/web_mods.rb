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

  class << self
    attr_reader :maps, :edits, :enemies

    # 定义一个能战斗的 NPC 的数据（敌人、敌群、数值表），在地图里用 npc(..., fight: 编号) 摆放。
    #   like：以哪个原版 NPC 为模板（敌人编号），复制它的全部数据后再改
    #   tile：人物头像 824～887，战斗画面自动用对应的 NPC_Tile 图
    #   maxhp / maxsp / gold：气血、内力上限、掉落金钱
    #   stats：数值表字段，键见 NPC_FIELDS，例如 { 膂力: 30, 闪避: 20, 经验: 50000 }
    #   skills：{ 武功编号 => 等级 }，最多 12 门，给出时整体替换模板的武功
    #   elite：true 时像原版 126 号以后的强敌一样不会被流星飞掷击中
    def enemy(id, name:, tile:, like:, maxhp: nil, maxsp: nil, gold: nil, stats: {}, skills: nil, elite: false)
      raise ArgumentError, "WebMod.enemy #{id}：新敌人编号要从 #{FIRST_ENEMY_ID} 开始" if id < FIRST_ENEMY_ID
      raise ArgumentError, "WebMod.enemy #{id}：重复定义" if @enemies[id]
      raise ArgumentError, "WebMod.enemy #{id}：模板 #{like} 不能用（随机、舞林大会或数据不全）" if !like.between?(1, FIRST_ENEMY_ID - 1) || BAD_TEMPLATES.include?(like)
      raise ArgumentError, "WebMod.enemy #{id}：tile 应是人物头像 824～887" unless (824..887).include?(tile)
      raise ArgumentError, "WebMod.enemy #{id}：名字“恶人”被原版留作随机恶人" if name == '恶人'
      bad = stats.keys - NPC_FIELDS.keys
      raise ArgumentError, "WebMod.enemy #{id}：未知的数值字段 #{bad.join('、')}，可用：#{NPC_FIELDS.keys.join('、')}" unless bad.empty?
      raise ArgumentError, "WebMod.enemy #{id}：武功最多 12 门" if skills && skills.size > 12
      @enemies[id] = { name: name, tile: tile, like: like, maxhp: maxhp, maxsp: maxsp, gold: gold,
                       stats: stats, skills: skills, elite: elite }
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
        e.battler_name = format('NPC_Tile_%02d', d[:tile] - 823)
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
    attr_reader :map, :map_id, :tile_edits

    def initialize(map, map_id, first_event_id)
      @map = map
      @map_id = map_id
      @next_id = [first_event_id, (map.events.keys.max || 0) + 1].max
      @tile_edits = []
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
    def event(x, y, name: '', tile: 0, trigger: 0, through: false, &block)
      check_xy(x, y, name.empty? ? 'event' : name)
      e = RPG::Event.new(x, y)
      e.id = @next_id
      e.name = name.empty? ? format('EV%03d', @next_id) : name
      page = e.pages[0]
      page.graphic.tile_id = tile
      page.trigger = trigger
      page.through = through
      c = Commands.new
      block.call(c) if block
      page.list = c.finish
      @map.events[e.id] = e
      @next_id += 1
      e
    end

    # NPC：照原版模板生成（名牌 → 交谈 / 查看 [/ 战斗] → 取消），见 docs/地图扩展指南.md 3.1。
    #   tile：人物头像图块，824～887
    #   talk：交谈内容，每个字符串是一页对话；需要条件分支时改用块：
    #         m.npc(...) { |c| c.if_switch(102) { c.text '……' }.else { c.text '……' } }
    #   look：查看的描述。字符串，或 { age:, level:, attack:, items:, text: }
    #         age 是年龄的十位数（3 → “30多岁”），level / attack 是 $levels / $attacks 的下标
    #   fight：能战斗时给出敌人编号（WebMod.enemy 定义），或 { enemy:, loot:, morality:, switch:, lose:, corpse: }
    #         loot：战胜后得到的东西，[[:armor, 4], [:weapon, 15], [:item, 16, 2]]，最多 4 种
    #         morality：杀死后道德值（变量 160）的变化，[道德 ≥ 128 时, 道德 < 128 时]，例如 [-10, -5]
    #         switch：杀死后打开的开关（记录这个人已死，剧情判断用）
    #         lose：战败时，:death（默认，公共事件 25：道德低则死，否则“承让了。”）或一句台词（切磋）
    #         corpse：死后显示的图块，默认 508
    #         杀死后：自开关 A 打开（事件换成第 2 页的尸体），$live[编号] 记为 false。
    #         name、tile 不写时取敌人定义里的。
    def npc(x, y, name: nil, tile: nil, talk: [], look: nil, fight: nil, &block)
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
      args = [name, look[:age].to_s].map(&:inspect).join(',') +
             ",$levels[#{look[:level].to_i}],$attacks[#{look[:attack].to_i}]," +
             [look[:items], look[:text]].map(&:inspect).join(',')
      labels = fight ? %w[交谈 查看 战斗] : %w[交谈 查看]
      e = event(x, y, name: name, tile: tile) do |c|
        c.script '@s=Draw_event_name.new'
        c.choices(labels) do |i|
          case i
          when 0 then block ? block.call(c) : Array(talk).each { |t| c.text t }
          when 1 then c.script "$scene=Lookover.new(#{args})"
          when 2 then fight_commands(c, fight)
          end
        end
        c.script '@s.dispose'
      end
      add_corpse_page(e, fight[:corpse] || 508) if fight
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
    def initialize
      @list = []
      @indent = 0
    end

    def cmd(code, *params)
      @list << RPG::EventCommand.new(code, @indent, params)
      self
    end

    # 一页对话（消息窗口会自动换行）
    def text(s)
      cmd(101, s)
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

    def wait(frames)
      cmd(106, frames)
    end

    # 战斗：win / escape / lose 是各分支要执行的 lambda（可省略）
    def battle(troop_id, can_escape: true, can_lose: true, win: nil, escape: nil, lose: nil)
      cmd(301, troop_id, can_escape, can_lose)
      cmd(601); nested { win&.call }
      cmd(602); nested { escape&.call }
      cmd(603); nested { lose&.call }
      cmd(604)
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

    # 条件分歧：脚本（结果为真时执行）
    def if_script(code, &block)
      branch([12, code], &block)
    end

    def finish
      raise '事件指令的分支没有闭合' unless @indent == 0
      @list << RPG::EventCommand.new(0, 0, [])
      @list
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
# 013 Data_NPC：新敌人的数值表（战斗开始时 Scene_Battle 按敌人编号调用）
#--------------------------------------------------------------------------
alias __webmod_get_npc_data get_npc_data
def get_npc_data(id)
  return $npc_data = WebMod.npc_row(id, method(:__webmod_get_npc_data)) if WebMod.enemies.key?(id)
  __webmod_get_npc_data(id)
end
