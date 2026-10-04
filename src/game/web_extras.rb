#==============================================================================
# ■ 网页版扩展（构建时插在 117 - Main 之前，作为一个普通游戏脚本载入）
#------------------------------------------------------------------------------
#  1. 前世奇遇：新角色第一次站在地图上、原有开场事件播完后，触发一段剧情，
#     可选择继承不同档位的经验与潜能，或拒绝。只触发一次（开关 WebCheat::SWITCH）。
#  2. 数值修改器：网页右上角 ⚙ 设置面板里读取、修改经验/潜能/金钱。
#  修改数值后同步原版的三个校验变量（151 金钱 CRC、152 经验 CRC、153 潜能+3），
#  这样存档导回 PC 原版时，并行公共事件 4 也不会判定为异常。
#==============================================================================
module WebCheat
  SWITCH   = 1999        # 前世奇遇已触发（原版只用到 101 号以内）
  NEW_EXP  = 1000        # 经验低于此值才视为新角色，老存档不再弹出奇遇
  GOLD_MAX = 9999999
  # [选项文字, 经验, 潜能]
  TIERS = [
    ['略有小成·各十万',   100_000,    100_000],
    ['登堂入室·各百万',   1_000_000,  1_000_000],
    ['前世宗师·各千万',   10_000_000, 10_000_000],
  ]
  DECLINE = '不必了，从头来过'

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

  # ------------------------------------------------------------ 前世奇遇
  def cmd(code, indent, params)
    RPG::EventCommand.new(code, indent, params)
  end

  def message(list, indent, lines)
    lines.each_with_index { |t, i| list << cmd(i == 0 ? 101 : 401, indent, [t]) }
  end

  def event_list
    l = []
    message(l, 0, ['你刚在这片陌生的大陆上站稳，', '脑中忽然一阵剧痛。',
                   '无数画面翻涌而来：', '刀光剑影，雪山古寺……'])
    message(l, 0, ['原来那次时空转换并不完整，', '你前世苦修的武学根基，',
                   '竟也随你一同来到了这里。', '要唤醒多少前世的记忆？'])
    l << cmd(102, 0, [TIERS.map { |t| t[0] } + [DECLINE], 4])
    TIERS.each_with_index do |t, i|
      l << cmd(402, 0, [i, t[0]])
      l << cmd(355, 1, ["WebCheat.accept(#{i})"])
      message(l, 1, ['前世的修为渐渐苏醒，', "经验 +#{t[1]}", "潜能 +#{t[2]}",
                     '（右上角设置里可随时调整）'])
      l << cmd(0, 1, [])
    end
    l << cmd(402, 0, [TIERS.size, DECLINE])
    message(l, 1, ['你摇了摇头，', '将那些画面抛诸脑后。', '这一世，从头来过。'])
    l << cmd(0, 1, [])
    l << cmd(404, 0, [])
    l << cmd(0, 0, [])
    l
  end

  def accept(i)
    t = TIERS[i]
    return true unless t
    $game_variables[19] += t[1]
    $game_variables[20] += t[2]
    sync_checks
    true
  end

  def check_qiyu
    return if $game_switches.nil? || $game_switches[SWITCH]
    if $game_variables[19] >= NEW_EXP
      $game_switches[SWITCH] = true
      return
    end
    it = $game_system.map_interpreter
    if it.running? || $game_temp.message_window_showing || $game_player.moving? ||
       $game_temp.transition_processing || $game_temp.player_transferring ||
       $game_temp.battle_calling || $game_temp.menu_calling
      @idle = 0
      return
    end
    @idle = (@idle || 0) + 1
    return if @idle < 20          # 等原有开场事件全部结束，再静止半秒
    @idle = 0
    $game_switches[SWITCH] = true
    it.setup(event_list, 0)
  end

  # ------------------------------------------------------------ 数值修改器
  # 网页端通过 RG.cheatTake() 下发指令："get" 或 "set|经验|潜能|金钱"
  # 结果通过 RG.cheatReport("ok|经验|潜能|金钱|姓名") 或 "err|原因" 返回
  def poll
    s = RGWeb.call(:cheatTake).to_s
    return if s.empty? || s == 'null' || s == 'undefined'
    unless in_game?
      RGWeb.call(:cheatReport, 'err|请先进入游戏（新建角色或读档）')
      return
    end
    a = s.split('|')
    if a[0] == 'set'
      exp, pot, gold = a[1].to_i, a[2].to_i, a[3].to_i
      $game_variables[19] = [exp, 0].max
      $game_variables[20] = [pot, 0].max
      gold = [[gold, 0].max, GOLD_MAX].min
      $game_party.gain_gold(gold - $game_party.gold)
      sync_checks
    end
    name = $game_party.actors[0].name.to_s
    RGWeb.call(:cheatReport, "ok|#{$game_variables[19]}|#{$game_variables[20]}|#{$game_party.gold}|#{name}")
  rescue StandardError => e
    RGWeb.call(:cheatReport, "err|#{e.class}: #{e.message}")
  end
end

class Scene_Map
  alias web_extras_update update
  def update
    web_extras_update
    WebCheat.check_qiyu if $scene.equal?(self)
  end
end

module Graphics
  class << self
    alias web_extras_graphics_update update
    def update
      web_extras_graphics_update
      WebCheat.poll if (@frame_count % 5) == 0
    end
  end
end
