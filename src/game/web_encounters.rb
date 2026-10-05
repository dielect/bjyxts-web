#==============================================================================
# ■ 江湖奇遇（构建时紧接地图扩展层载入，内容写在 src/game/mods/*.rb）
#------------------------------------------------------------------------------
#  在野外、郊外和镇上走动时，每走一段路检查一次，从“奇遇池”里按权重抽一段小插曲。
#  每段奇遇是一个公共事件（对话、选项、战斗、奖励），写法与 NPC 的交谈块相同：
#
#    WebEncounter.add 1, '山贼劫道', where: :wild, weight: 3, cooldown: 4 do |c|
#      c.text '……'
#    end
#
#  参数：
#    编号        1～40，存档里用变量 260 + 编号 记录“上次发生在第几次奇遇”（0 为没发生过）
#    where      :wild 野外（大地图与各处山野） :suburb 平安镇四郊 :town 镇上，可以写数组或地图编号
#    weight     权重，数字或 lambda
#    once       只发生一次
#    cooldown   发生后，至少再经过几次别的奇遇才会再次出现
#    after      [奇遇编号, n]：那段奇遇发生过、并且之后又经过了 n 次奇遇（用于“日后报恩 / 寻仇”）
#    if         额外条件（lambda），例如 -> { WebEncounter.good? }
#    combat     这段奇遇会打起来（含可以选择动手的）。两段战斗奇遇之间至少隔一段不打架的
#    show       看得见的奇遇：{ tile: 841 } 或 { sprite: '行走图' }。抽中后先在主角附近的路边出现一个人或物，
#               走过去碰到才开始；看见了也可以绕开。不写的是“找上门来”的（伏击、来访），抽中就开始
#
#  看得见的奇遇何时回收：离开这张地图时（无论触发没有）一定回收；另外
#    一次性的（捡东西、救人）触发后就消失；没碰过的走开 40 步、离开 12 格以外也回收；
#    摆摊的（show: { ..., stay: true }，货郎、骰子摊、郎中）碰过以后留在原地，可以再找，离开地图才回收。
#  只有触发了才算发生过（计入冷却、最近记录），摆摊的再找几次也只算一次。
#
#  节奏：野外每走一步计 2，郊外和镇上计 1，计满 100～180 时有七成几率来一段（大地图约 50～90 步一次）；
#        刚发生过的两段奇遇不会紧接着重复（池里只剩它们时除外）；
#        战斗奇遇之后，下一段一定是不打架的，池里只剩战斗奇遇时这次就不来。
#  编号登记：变量 253 奇遇总次数，254～255 最近两段奇遇，256 上一段战斗奇遇的序号，
#            261～300 各奇遇的发生记录（docs/内容设计思路.md 0.4）
#  回归测试：node tools/encounter-test.mjs
#==============================================================================
module WebEncounter
  VAR_TOTAL   = 253
  VAR_RECENT  = [254, 255]
  VAR_COMBAT  = 256                              # 上一段战斗奇遇发生在第几次奇遇
  VAR_STAMP   = 260                              # 变量 260 + 编号
  MAX_ID      = 40

  REGIONS = {
    wild:   [1, 23, 24, 26, 27, 28, 29, 37, 42],
    suburb: [12, 13, 14, 21],
    town:   [3, 5, 15],
  }
  STEP_COST = { wild: 2, suburb: 1, town: 1 }
  FIGURE_ID = 9001                               # 看得见的奇遇：临时事件的编号（原版地图事件远小于它）
  FIGURE_LIFE = 80                               # 出现后再走这么多计步就回收（野外约 40 步）
  FIGURE_FAR = 12                                # 离开这么远也回收
  MOUNTAINS = [23, 24, 26, 27, 28, 42]           # 山野（山贼更多）
  COUNT_MIN, COUNT_RANGE = 100, 80
  @chance = 70                                   # 计满后真正来一段的几率（%）

  @list = {}

  class << self
    attr_reader :list
    attr_accessor :chance

    def add(id, name, where:, weight: 1, once: false, cooldown: 0, after: nil, combat: false, show: nil, if: nil, &block)
      cond = binding.local_variable_get(:if)
      raise ArgumentError, "WebEncounter #{id}：编号要在 1～#{MAX_ID}" unless (1..MAX_ID).include?(id)
      raise ArgumentError, "WebEncounter #{id}：重复定义" if @list[id]
      raise ArgumentError, "WebEncounter #{id}：需要块" unless block
      maps = Array(where).flat_map { |w| w.is_a?(Symbol) ? REGIONS.fetch(w) { raise ArgumentError, "WebEncounter #{id}：未知区域 #{w}" } : [w] }
      key = :"奇遇_#{id}"
      WebMod.auto_common_event(key, "奇遇-#{name}", &block)
      @list[id] = { id: id, name: name, maps: maps, weight: weight, once: once, cooldown: cooldown,
                    after: after, combat: combat, show: show, cond: cond, key: key }
    end

    # ---- 存档里的记录
    def total
      $game_variables[VAR_TOTAL].to_i
    end

    def stamp(id)
      $game_variables[VAR_STAMP + id].to_i
    end

    def happened?(id)
      stamp(id) > 0
    end

    # 那段奇遇之后又经过了几次奇遇（没发生过为 nil）
    def since(id)
      happened?(id) ? total - stamp(id) : nil
    end

    # ---- 常用条件
    def good?
      $game_variables[160] >= 128
    end

    def age
      $game_variables[157].to_i
    end

    # 情境（权重里用）
    def gold
      $game_party.gold
    end

    def hp_rate
      a = $game_actors[1]
      a.hp.to_f / [a.maxhp, 1].max
    end

    def wanted
      $game_variables[164].to_i
    end

    def mountain?
      MOUNTAINS.include?($game_map.map_id)
    end

    def exp
      $game_variables[19].to_i
    end

    # ---- 抽取
    def available?(e, map_id = $game_map.map_id)
      return false unless e[:maps].include?(map_id)
      s = stamp(e[:id])
      return false if e[:once] && s > 0
      return false if s > 0 && total - s < e[:cooldown]
      if (a = e[:after])
        n = since(a[0])
        return false if n.nil? || n < a[1]
      end
      return false if e[:combat] && combat_rest?
      return false if e[:cond] && !e[:cond].call
      true
    rescue StandardError
      false
    end

    # 上一段是战斗奇遇：这次只来不打架的
    def combat_rest?
      last = $game_variables[VAR_COMBAT].to_i
      last > 0 && last == total
    end

    def weight_of(e)
      w = e[:weight].respond_to?(:call) ? e[:weight].call : e[:weight]
      [w.to_i, 0].max
    end

    def candidates(map_id = $game_map.map_id)
      pool = @list.values.select { |e| available?(e, map_id) && weight_of(e) > 0 }
      recent = VAR_RECENT.map { |v| $game_variables[v].to_i }
      fresh = pool.reject { |e| recent.include?(e[:id]) }
      fresh.empty? ? pool : fresh
    end

    def pick(map_id = $game_map.map_id)
      pool = candidates(map_id)
      return nil if pool.empty?
      r = rand(pool.sum { |e| weight_of(e) })
      pool.each do |e|
        r -= weight_of(e)
        return e if r < 0
      end
      pool[-1]
    end

    # ---- 走路计数
    def region_of(map_id)
      REGIONS.each { |k, ids| return k if ids.include?(map_id) }
      nil
    end

    def reset_count
      @count = COUNT_MIN + rand(COUNT_RANGE)
    end

    def step
      r = region_of($game_map.map_id) or return
      if @figure
        @figure[:life] -= STEP_COST[r]
        return
      end
      reset_count if @count.nil?
      @count -= STEP_COST[r]
      @ready = true if @count <= 0
    end

    # 地图画面每帧调用：攒够步数、没有别的事件在跑时开始一段奇遇
    def update
      tidy_figure
      return unless @ready
      return if busy? || @figure
      @ready = false
      reset_count
      return if rand(100) >= @chance
      e = pick
      e = nil if e && e[:show] && !spawn(e)
      return if @figure
      unless e
        # 战斗奇遇后只剩战斗奇遇可选：这次空过，下次照常（不然就再也不来了）
        $game_variables[VAR_COMBAT] = 0 if combat_rest?
        return
      end
      start(e)
    end

    def busy?
      $game_system.map_interpreter.running? || $game_temp.message_window_showing ||
        $game_temp.player_transferring || $game_temp.common_event_id > 0 ||
        $game_temp.battle_calling || $game_temp.menu_calling || $game_temp.shop_calling ||
        $game_player.moving? || $game_player.move_route_forcing
    end

    #------------------------------------------------------------------ 看得见的奇遇
    attr_reader :figure

    # 在主角附近找一处站得住、走得到、在屏幕里的空地，放一个临时事件
    def spawn(e)
      spot = find_spot or return false
      x, y = spot
      ev = RPG::Event.new(x, y)
      ev.id = FIGURE_ID
      ev.name = "奇遇-#{e[:name]}"
      pg = ev.pages[0]
      if e[:show][:sprite]
        pg.graphic.character_name = e[:show][:sprite]
        pg.direction_fix = true
      else
        pg.graphic.tile_id = e[:show][:tile]
      end
      pg.trigger = 1                               # 碰到就开始（站在旁边按确定也行）
      pg.list = [RPG::EventCommand.new(355, 0, ["WebEncounter.claim(#{e[:id]})"]),
                 RPG::EventCommand.new(117, 0, [WebMod.auto_common_event_id(e[:key])]),
                 RPG::EventCommand.new(0, 0, [])]
      gev = Game_Event.new($game_map.map_id, ev)
      $game_map.events[FIGURE_ID] = gev
      if (sprites = character_sprites)
        sprites.insert(-2, Sprite_Character.new(spriteset.instance_variable_get(:@viewport1), gev))
      end
      @figure = { id: e[:id], map: $game_map.map_id, life: FIGURE_LIFE }
      true
    end

    # 碰到了：这才算发生过（摆摊的只记第一次）。一次性的人物马上消失，等事件跑完再收拾
    def claim(id)
      e = @list.fetch(id)
      f = @figure
      record(e) unless f && f[:met]
      f[:met] = true if f
      return if e[:show] && e[:show][:stay]
      ev = $game_map.events[FIGURE_ID]
      ev.erase if ev
      f[:claimed] = true if f
    end

    # 这一次出现期间要保持不变的东西（例如货郎的货），换了地图就重新来
    def figure_memo(key)
      return yield unless @figure
      (@figure[:memo] ||= {})[key] ||= yield
    end

    # 回收：触发完、换了地图、走远了、过了太久
    def tidy_figure
      f = @figure or return
      if f[:map] != $game_map.map_id || $game_map.events[FIGURE_ID].nil?
        @figure = nil                              # 换了地图：新地图的事件里本来就没有它
        return
      end
      return if $game_system.map_interpreter.running?
      return remove_figure if f[:claimed]
      return if f[:met]                            # 摆摊的碰过以后一直留着，换地图才走
      ev = $game_map.events[FIGURE_ID]
      far = ($game_player.x - ev.x).abs + ($game_player.y - ev.y).abs > FIGURE_FAR
      remove_figure if f[:life] <= 0 || far
    end

    def remove_figure
      ev = $game_map.events.delete(FIGURE_ID)
      if ev && (sprites = character_sprites)
        sprites.reject! { |sp| sp.character.equal?(ev) && (sp.dispose; true) }
      end
      @figure = nil
    end

    def spriteset
      $scene.is_a?(Scene_Map) ? $scene.instance_variable_get(:@spriteset) : nil
    end

    def character_sprites
      spriteset && spriteset.instance_variable_get(:@character_sprites)
    end

    # 主角走得到（3～7 步）、在屏幕里、不压着别的事件和出入口的格子，优先放在前方
    def find_spot
      px, py = $game_player.x, $game_player.y
      dirs = [[2, 0, 1], [4, -1, 0], [6, 1, 0], [8, 0, -1]]
      taken = $game_map.events.values.map { |ev| [ev.x, ev.y] }
      seen = { [px, py] => 0 }
      queue = [[px, py]]
      until queue.empty?
        x, y = queue.shift
        d0 = seen[[x, y]]
        next if d0 >= 7
        dirs.each do |d, dx, dy|
          xy = [x + dx, y + dy]
          next if seen.key?(xy) || taken.include?(xy) || !$game_player.passable?(x, y, d)
          seen[xy] = d0 + 1
          queue << xy
        end
      end
      sx, sy = $game_map.display_x / 128, $game_map.display_y / 128
      fx, fy = { 2 => [0, 1], 4 => [-1, 0], 6 => [1, 0], 8 => [0, -1] }[$game_player.direction]
      spots = seen.select do |(x, y), dist|
        dist.between?(3, 7) && x.between?(sx + 1, sx + 18) && y.between?(sy + 1, sy + 13) &&
          dirs.count { |_, dx, dy| seen.key?([x + dx, y + dy]) } >= 2   # 不堵死单格宽的路
      end
      return nil if spots.empty?
      best = spots.keys.max_by { |x, y| (x - px) * fx + (y - py) * fy + rand * 3 }
      best
    end

    #------------------------------------------------------------------ 记录并启动
    # 记一笔“发生过”
    def record(e)
      n = total + 1
      $game_variables[VAR_TOTAL] = n
      $game_variables[VAR_STAMP + e[:id]] = n
      $game_variables[VAR_COMBAT] = n if e[:combat]
      $game_variables[VAR_RECENT[1]] = $game_variables[VAR_RECENT[0]]
      $game_variables[VAR_RECENT[0]] = e[:id]
    end

    # 记录并启动（测试也直接调用它）
    def start(e)
      e = @list.fetch(e) if e.is_a?(Integer)
      record(e)
      $game_temp.common_event_id = WebMod.auto_common_event_id(e[:key])
      e
    end
  end
end

# 本作的 move_down 等去掉了“增加步数”的调用，所以按主角所在格子的变化计步（传送不在这里发生）
class Game_Player
  alias __enc_update update
  def update
    x, y = @x, @y
    __enc_update
    WebEncounter.step if @x != x || @y != y
  end
end

class Scene_Map
  alias __enc_update update
  def update
    __enc_update
    WebEncounter.update if $scene.equal?(self)
  end
end
