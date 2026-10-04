#==============================================================================
# ■ 网页版扩展（构建时插在 117 - Main 之前，作为一个普通游戏脚本载入）
#------------------------------------------------------------------------------
#  沙盒模式：网页右上角 ⚙ 设置面板里读取、修改经验/潜能/金钱。
#    默认关闭；玩家在设置里开启后，当前存档永久标记为沙盒（开关 SANDBOX），之后才能修改数值，
#    画面左上角显示“沙盒”标记。未开启时，修改指令一律拒绝。
#  修改数值后同步原版的三个校验变量（151 金钱 CRC、152 经验 CRC、153 潜能+3），
#  这样存档导回 PC 原版时，并行公共事件 4 也不会判定为异常。
#  （原先的“前世奇遇”开局剧情已移除，见 git 历史。）
#==============================================================================
module WebCheat
  SANDBOX  = 1998        # 本存档已开启沙盒模式（原版只用到 101 号以内）
  GOLD_MAX = 9999999

  module_function

  def sync_checks
    $game_variables[151] = Zlib.crc32($game_party.gold.to_s, 51)
    $game_variables[152] = Zlib.crc32($game_variables[19].to_s, 51)
    $game_variables[153] = $game_variables[20] + 3
  end

  # 标题、序幕、建角时存档尚未真正载入（标题页会预读存档，进入时再读一次），
  # 战斗中改数值也容易与战斗结算冲突，因此只在地图和菜单类场景中允许修改。
  BLOCKED_SCENES = %w[Scene_Title Scene_Begin Scene_Create Scene_Battle Scene_Gameover]
  def in_game?
    return false if $scene.nil? || BLOCKED_SCENES.any? { |n| Object.const_defined?(n) && $scene.is_a?(Object.const_get(n)) }
    !$game_variables.nil? && !$game_party.nil? && !$game_party.actors.empty? && !$game_map.nil?
  end

  def sandbox?
    !$game_switches.nil? && $game_switches[SANDBOX] == true
  end

  # ------------------------------------------------------------ 沙盒模式
  # 网页端通过 RG.cheatTake() 下发指令："get"、"sandbox"（开启）或 "set|经验|潜能|金钱"
  # 结果通过 RG.cheatReport("ok|经验|潜能|金钱|姓名|是否沙盒") 或 "err|原因" 返回
  def poll
    push_state
    s = RGWeb.call(:cheatTake).to_s
    return if s.empty? || s == 'null' || s == 'undefined'
    unless in_game?
      RGWeb.call(:cheatReport, 'err|请先进入游戏（新建角色或读档）')
      return
    end
    a = s.split('|')
    case a[0]
    when 'sandbox'
      $game_switches[SANDBOX] = true
      push_state
    when 'set'
      unless sandbox?
        RGWeb.call(:cheatReport, 'err|请先开启沙盒模式')
        return
      end
      exp, pot, gold = a[1].to_i, a[2].to_i, a[3].to_i
      $game_variables[19] = [exp, 0].max
      $game_variables[20] = [pot, 0].max
      gold = [[gold, 0].max, GOLD_MAX].min
      $game_party.gain_gold(gold - $game_party.gold)
      sync_checks
    end
    name = $game_party.actors[0].name.to_s
    RGWeb.call(:cheatReport, "ok|#{$game_variables[19]}|#{$game_variables[20]}|#{$game_party.gold}|#{name}|#{sandbox? ? 1 : 0}")
  rescue StandardError => e
    RGWeb.call(:cheatReport, "err|#{e.class}: #{e.message}")
  end

  # 当前存档是否沙盒，变化时通知网页显示 / 隐藏“沙盒”标记（读档、新建角色后都会更新）
  def push_state
    v = in_game? && sandbox?
    return if v == @pushed
    @pushed = v
    RGWeb.call(:sandboxState, v ? 1 : 0)
  end
end

module Graphics
  class << self
    alias web_extras_graphics_update update
    def update
      web_extras_graphics_update
      WebCheat.poll if (@frame_count % 5) == 0
      web_dev_poll
    end
    # 见 main.js 中 window.__rb
    def web_dev_poll
      code = RGWeb.call(:devTake).to_s
      return if code.empty? || code == 'undefined' || code == 'null'
      r = begin
        TOPLEVEL_BINDING.eval(code).inspect
      rescue Exception => e
        "#{e.class}: #{e.message}"
      end
      RGWeb.call(:devPut, r)
    end
  end
end
