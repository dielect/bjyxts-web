#==============================================================================
# ■ Scene_Menu
#------------------------------------------------------------------------------
# 　处理主菜单画面的类。
#==============================================================================
class Scene_Menu
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     menu_index : 命令光标的初期位置
  #--------------------------------------------------------------------------
  def initialize(menu_index = 0)
    @menu_index = menu_index
  end
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    # 生成命令窗口
    @screen = Spriteset_Map.new
    @command_window = Window_Command.new(640, ["查看","物品","技能","功能"],4)
    @command_window.index = @menu_index
    # 执行过渡
    Graphics.transition
    # 主循环
    loop do
      # 刷新游戏画面
      Graphics.update
      # 刷新输入信息
      Input.update
      # 刷新画面
      update
      # 如果切换画面就中断循环
      if $scene != self
        break
      end
    end
    # 准备过渡
    Graphics.freeze
    # 释放窗口
    @command_window.dispose
    @screen.dispose
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 刷新窗口
    @command_window.update
    # 命令窗口被激活的情况下: 调用 update_command
    if @command_window.active
      update_command
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (命令窗口被激活的情况下)
  #--------------------------------------------------------------------------
  def update_command
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 切换的地图画面
      $scene = Scene_Map.new
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 命令窗口的光标位置分支
      case @command_window.index
      when 0  # 查看（状态）
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 切换到物品画面
        $scene = Scene_Status.new(true)
      when 1  # 物品
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 激活状态窗口
        $scene = Scene_Item.new(true)
      when 2  # 装备
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 激活状态窗口
        $scene = Scene_Skill.new(true)
      when 3  # 功能
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 切换到游戏结束画面
        $scene = Scene_End.new
      end
      return
    end
  end
end