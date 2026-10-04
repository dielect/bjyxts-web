#==============================================================================
# ■ Scene_End
#------------------------------------------------------------------------------
# 　处理游戏结束画面的类。
#==============================================================================

class Scene_End
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
    @screen = Spriteset_Map.new
    draw_main_menu
    @help_window=Window_Help.new
    @help_window.width=416
    @help_window.height=64
    @help_window.contents=Bitmap.new(384,32)
    @help_window.x=112
    @help_window.y=176
    @help_window.z=500
    @help_window.visible=false
    @yesno=Window_Command.new(416,["确定","放弃"],2)
    @yesno.x=112
    @yesno.y=240
    @yesno.z=500
    @yesno.visible=false
    @yesno.active=false
    @yesno2=Window_Command.new(416,["确定","放弃"],2)
    @yesno2.x=112
    @yesno2.y=240
    @yesno2.z=500
    @yesno2.visible=false
    @yesno2.active=false
    # 生成命令窗口
    @command_window = Window_Command.new(96, ["内力","练功","存档","结束"],1)
    @command_window.x = 624 - @command_window.width
    @command_window.y = 64
    @command_window.index = @menu_index
    # 执行过渡
    Graphics.transition
    # 主循环
    loop do
      # 刷新游戏画面
      Graphics.update
      # 刷新输入情报
      Input.update
      # 刷新画面
      update
      # 如果画面切换的话就中断循环
      if $scene != self
        break
      end
    end
    # 准备过渡
    Graphics.freeze
    # 释放窗口
    @command_window.dispose
    @help_window.dispose
    @yesno.dispose
    @yesno2.dispose
    @top_menu.dispose
    @screen.dispose
    # 如果在标题画面切换中的情况下
    if $scene.is_a?(Scene_Title)
      # 淡入淡出画面
      Graphics.transition
      Graphics.freeze
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 刷新命令窗口
    @command_window.update
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      # 演奏取消 SE
      $game_system.se_play($data_system.cancel_se)
      # 切换到菜单画面
      $scene = Scene_Menu.new(3)
      return
    end
    # 按下 C 键的场合下
    if Input.trigger?(Input::C)
      # 命令窗口光标位置分支
      case @command_window.index
      when 2
        # 禁止存档的情况下
        if $game_system.save_disabled
          # 演奏冻结 SE
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 切换到存档画面
        command_save_file
      when 0  #内力
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        # 切换到游戏结束画面
        $scene = Scene_FP.new(true)
      when 1  # 练功
        for i in 29..31
          if $game_variables[$game_variables[i]]>0
            $game_system.se_play($data_system.decision_se)
            $scene = Scene_Practice.new(true)
            return
          end
        end
        $game_system.se_play($data_system.buzzer_se)
        return
      when 3  # 退出
        # 演奏确定 SE
        $game_system.se_play($data_system.decision_se)
        @help_window.set_text("真的退出游戏吗？")
        @help_window.visible=true
        @command_window.visible=false
        @yesno.visible=true
        @yesno.active=true
        # 主循环
        loop do
          # 刷新游戏画面
          Graphics.update
          # 刷新输入情报
          Input.update
          @yesno.update
          # 按下 B 键的情况下
          if Input.trigger?(Input::B)
            # 演奏取消 SE
            $game_system.se_play($data_system.cancel_se)
            # 切换到菜单画面
            $scene = Scene_Menu.new(3)
            break
            return
          end
          if Input.trigger?(Input::C)
            # 演奏确定 SE
            $game_system.se_play($data_system.decision_se)
            case @yesno.index
            when 0
              stime=Graphics.frame_count/Graphics.frame_rate
              if stime-$save_time>600
                @help_window.set_text("你已经好久没存档了，现在保存吗？")
                @yesno.visible=false
                @yesno.active=false
                @yesno2.visible=true
                @yesno2.active=true
                # 主循环
                loop do
                  # 刷新游戏画面
                  Graphics.update
                  # 刷新输入情报
                  Input.update
                  @yesno2.update
                  # 按下 B 键的情况下
                  if Input.trigger?(Input::B)
                    # 演奏取消 SE
                    $game_system.se_play($data_system.cancel_se)
                    # 切换到菜单画面
                    $scene = Scene_Menu.new(3)
                    break
                    return
                  end
                  if Input.trigger?(Input::C)
                    # 演奏确定 SE
                    $game_system.se_play($data_system.decision_se)
                    case @yesno2.index
                    when 0
                      file = File.open("Gmud.sav", "wb")
                      write_save_data(file)
                      file.close
                      command_to_title
                      break
                    when 1
                      command_to_title
                      break
                    end
                  end
                end
                break
                return
              else
                command_to_title
                break
              end
            when 1
              # 演奏取消 SE
              $game_system.se_play($data_system.cancel_se)
              @help_window.visible=false
              @yesno.visible=false
              @yesno.active=false
              # 切换到菜单画面
              $scene = Scene_Menu.new(3)
              break
              return
            end
          end
        end
      end
      return
    end
  end
  
  #--------------------------------------------------------------------------
  # ● 选择命令 [返回标题画面] 时的处理
  #--------------------------------------------------------------------------
  def command_to_title
    # 演奏确定 SE
    $game_system.se_play($data_system.decision_se)
    # 淡入淡出 BGM、BGS、ME
    Audio.bgm_fade(800)
    Audio.bgs_fade(800)
    Audio.me_fade(800)
    # 切换到标题画面
    $scene = nil
  end
  def command_save_file
    file = File.open("Gmud.sav", "wb")
    write_save_data(file)
    file.close
    $save_time=Graphics.frame_count/Graphics.frame_rate
    save_msg
    return
  end
  #显示存档成功
  def save_msg
    good=Window_Base.new(376,128,152,64)
    good.contents=Bitmap.new(120,32)
    good.contents.font.size = 24
    good.contents.font.color.set(0,0,0)
    good.contents.draw_text(0,0,120,32,"存档成功！",1)
    # 演奏读档 SE
    $game_system.se_play($data_system.save_se)
    for i in 0..50
      Graphics.update
    end
    good.dispose
    $scene=Scene_Menu.new(3)
  end

  #--------------------------------------------------------------------------
  # ● 生成文件名
  #     file_index : 文件名的索引 (0～3)
  #--------------------------------------------------------------------------
  def make_filename(file_index)
    return "Gmud.sav"
  end
end
