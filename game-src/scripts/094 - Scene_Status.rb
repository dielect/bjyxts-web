#==============================================================================
# ■ Scene_Status
#------------------------------------------------------------------------------
# 　处理状态画面的类。
#==============================================================================

class Scene_Status
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     actor_index : 角色索引
  #--------------------------------------------------------------------------
  def initialize(menu=false,actor_index = 0, equip_index = 0)
    @menu=menu
    @actor_index = actor_index
    @menu_index=0
  end
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    @screen = Spriteset_Map.new
    draw_main_menu
    # 获取角色
    @actor = $game_party.actors[0]
    # 生成状态窗口
    @look_window= Window_Command.new(396,["状态","描述","属性"],3)
    @look_window.x=122
    @look_window.y=64
    @look_window.index = @menu_index
    @status_window = Window_Status.new(@actor)
    @status_window.y=128
    # 执行过渡
    Graphics.transition
    # 主循环
    loop do
      # 刷新游戏画面
      Graphics.update
      # 刷新输入信息
      Input.update
      # 刷新画面
      $game_system.update
      update
      # 如果画面被切换的话就中断循环
      if $scene != self
        break
      end
    end
    # 准备过渡
    Graphics.freeze
    # 释放窗口
    @screen.dispose
    @top_menu.dispose
    @status_window.dispose
    @look_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    @look_window.update
    if @look_window.active
      # 按下 B 键的情况下
      if Input.trigger?(Input::B)
        # 演奏取消 SE
        $game_system.se_play($data_system.cancel_se)
        if @menu
          $scene = Scene_Menu.new(0)
          return
        else
          $scene = Scene_Map.new
          return
        end
      else
        case @look_window.index
        when 0
          @status_window.look0
        when 1
          @status_window.look1
        when 2
          @status_window.look2
        end
      end
    end
    return
  end
end