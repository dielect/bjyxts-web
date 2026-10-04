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

  @maps  = {}                                    # 新地图编号 => 定义
  @edits = Hash.new { |h, k| h[k] = [] }         # 原版地图编号 => [定义块, ...]

  class << self
    attr_reader :maps, :edits

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

    # NPC：照原版模板生成（名牌 → 交谈 / 查看 → 取消），见 docs/地图扩展指南.md 3.1。
    #   tile：人物头像图块，824～887
    #   talk：交谈内容，每个字符串是一页对话；需要条件分支时改用块：
    #         m.npc(...) { |c| c.if_switch(102) { c.text '……' }.else { c.text '……' } }
    #   look：查看的描述。字符串，或 { age:, level:, attack:, items:, text: }
    #         age 是年龄的十位数（3 → “30多岁”），level / attack 是 $levels / $attacks 的下标
    def npc(x, y, name:, tile:, talk: [], look: nil, &block)
      raise ArgumentError, "npc #{name}：tile 应是人物头像 824～887" unless (824..887).include?(tile)
      look = { text: look } if look.is_a?(String)
      look = { age: 3, level: 0, attack: 0, items: '布衣', text: '' }.merge(look || {})
      args = [name, look[:age].to_s].map(&:inspect).join(',') +
             ",$levels[#{look[:level].to_i}],$attacks[#{look[:attack].to_i}]," +
             [look[:items], look[:text]].map(&:inspect).join(',')
      event(x, y, name: name, tile: tile) do |c|
        c.script '@s=Draw_event_name.new'
        c.choices(%w[交谈 查看]) do |i|
          if i == 0
            block ? block.call(c) : Array(talk).each { |t| c.text t }
          else
            c.script "$scene=Lookover.new(#{args})"
          end
        end
        c.script '@s.dispose'
      end
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
