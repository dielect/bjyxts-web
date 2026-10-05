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
  COUNT_MIN, COUNT_RANGE = 100, 80
  @chance = 70                                   # 计满后真正来一段的几率（%）

  @list = {}

  class << self
    attr_reader :list
    attr_accessor :chance

    def add(id, name, where:, weight: 1, once: false, cooldown: 0, after: nil, combat: false, if: nil, &block)
      cond = binding.local_variable_get(:if)
      raise ArgumentError, "WebEncounter #{id}：编号要在 1～#{MAX_ID}" unless (1..MAX_ID).include?(id)
      raise ArgumentError, "WebEncounter #{id}：重复定义" if @list[id]
      raise ArgumentError, "WebEncounter #{id}：需要块" unless block
      maps = Array(where).flat_map { |w| w.is_a?(Symbol) ? REGIONS.fetch(w) { raise ArgumentError, "WebEncounter #{id}：未知区域 #{w}" } : [w] }
      key = :"奇遇_#{id}"
      WebMod.auto_common_event(key, "奇遇-#{name}", &block)
      @list[id] = { id: id, name: name, maps: maps, weight: weight, once: once, cooldown: cooldown,
                    after: after, combat: combat, cond: cond, key: key }
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
      reset_count if @count.nil?
      @count -= STEP_COST[r]
      @ready = true if @count <= 0
    end

    # 地图画面每帧调用：攒够步数、没有别的事件在跑时开始一段奇遇
    def update
      return unless @ready
      return if busy?
      @ready = false
      reset_count
      return if rand(100) >= @chance
      e = pick
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

    # 记录并启动（测试也直接调用它）
    def start(e)
      e = @list.fetch(e) if e.is_a?(Integer)
      n = total + 1
      $game_variables[VAR_TOTAL] = n
      $game_variables[VAR_STAMP + e[:id]] = n
      $game_variables[VAR_COMBAT] = n if e[:combat]
      $game_variables[VAR_RECENT[1]] = $game_variables[VAR_RECENT[0]]
      $game_variables[VAR_RECENT[0]] = e[:id]
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
