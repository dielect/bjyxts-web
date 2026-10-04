#==============================================================================
# ■ Scene_Create
#------------------------------------------------------------------------------
# 　自定义创建一个新角色
#==============================================================================
class Scene_Create
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    # 生成索引
    @index = 0
    $game_variables[11] = 20
    $game_variables[12] = 20
    $game_variables[13] = 20
    $game_variables[14] = 20
    # 生成窗口
    @create_window = Window_Create.new
    @create_window.index = 0
    Audio.bgm_play("Audio/BGM/创建人物.mp3") 
    # 执行过渡
    Graphics.transition
    # 主循环
    loop do
      Graphics.frame_reset
      # 刷新游戏画面
      Graphics.update
      # 刷新输入情报
      Input.update
      # 刷新画面
      update
      # 如果画面被切换的话就中断循环
      if $scene != self
        break
      end
    end
    # 准备过渡
    Graphics.freeze
    # 释放窗口
    @create_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● 选择退出
  #--------------------------------------------------------------------------
  def on_cancel
    # 播放取消SE
    $game_system.se_play($data_system.cancel_se)
    # 淡入淡出 BGM、BGS、ME
    Audio.bgm_fade(800)
    Audio.bgs_fade(800)
    Audio.me_fade(800)
    $scene = nil
  end
  #--------------------------------------------------------------------------
  # ● 改变角色名称
  #--------------------------------------------------------------------------
  def change_name
    if Input.trigger?(Input::C)
      $game_system.se_play($data_system.decision_se)
      $game_temp.name_actor_id = 1
      name_thread=Thread.new{ActorNameInput(1)}
      name_thread.exit
    end
  end
  #--------------------------------------------------------------------------
  # ● 改变角色性别
  #--------------------------------------------------------------------------
  def change_gender
    if $game_variables[11]>15
      $gender = "男"
    else
      $gender = "女"
    end    
  end
  #--------------------------------------------------------------------------
  # ● 改变角色膂力
  #--------------------------------------------------------------------------
  def change_a
    if Input.trigger?(Input::LEFT)
      $game_system.se_play($data_system.cursor_se)
      $game_variables[11] -= 1
      if $game_variables[11]<10
        $game_variables[11]=10
      end
      return
    elsif Input.trigger?(Input::RIGHT)
      if $game_variables[11]+$game_variables[12]+$game_variables[13]+$game_variables[14]<80
        $game_system.se_play($data_system.cursor_se)
        $game_variables[11] += 1
        if $game_variables[11]>30
          $game_variables[11]=30
        end
      else
        Audio.se_play("Audio/SE/Buzzer1.ogg")
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 改变角色敏捷
  #--------------------------------------------------------------------------
  def change_b
    if Input.trigger?(Input::LEFT)
      $game_system.se_play($data_system.cursor_se)
      $game_variables[12] -= 1
      if $game_variables[12]<10
        $game_variables[12]=10
      end
      return
    elsif Input.trigger?(Input::RIGHT)
      if $game_variables[11]+$game_variables[12]+$game_variables[13]+$game_variables[14]<80
        $game_system.se_play($data_system.cursor_se)
        $game_variables[12] += 1
        if $game_variables[12]>30
          $game_variables[12]=30
        end
      else
        Audio.se_play("Audio/SE/Buzzer1.ogg")
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 改变角色悟性
  #--------------------------------------------------------------------------
  def change_c
    if Input.trigger?(Input::LEFT)
      $game_system.se_play($data_system.cursor_se)
      $game_variables[13] -= 1
      if $game_variables[13]<10
        $game_variables[13]=10
      end
      return
    elsif Input.trigger?(Input::RIGHT)
      if $game_variables[11]+$game_variables[12]+$game_variables[13]+$game_variables[14]<80
        $game_system.se_play($data_system.cursor_se)
        $game_variables[13] += 1
        if $game_variables[13]>30
          $game_variables[13]=30
        end
      else
       Audio.se_play("Audio/SE/Buzzer1.ogg")
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 改变角色根骨
  #--------------------------------------------------------------------------
  def change_d
    if Input.trigger?(Input::LEFT)
      $game_system.se_play($data_system.cursor_se)
      $game_variables[14] -= 1
      if $game_variables[14]<10
        $game_variables[14]=10
      end
      return
    elsif Input.trigger?(Input::RIGHT)
      if $game_variables[11]+$game_variables[12]+$game_variables[13]+$game_variables[14]<80
        $game_system.se_play($data_system.cursor_se)
        $game_variables[14] +=1
        if $game_variables[14]>30
          $game_variables[14]=30
        end
      else
        Audio.se_play("Audio/SE/Buzzer1.ogg")
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 创建完毕
  #--------------------------------------------------------------------------
  def create
    if Input.trigger?(Input::C)
      if ($game_variables[11]+$game_variables[12]+$game_variables[13]+$game_variables[14])!=80
        Audio.se_play("Audio/SE/Buzzer1.ogg")
        return
      end
      s=false
      for i in 1..143
        s=true if $game_party.actors[0].name ==$data_enemies[i].name
        break if s
      end
      for i in 0..7
        for j in 0..7
          s=true if $task1[0][i]+$task1[1][j]==$game_party.actors[0].name
          break if s
        end
      end
      s=true if $game_party.actors[0].name==""
      if s
        Audio.se_play("Audio/SE/Buzzer1.ogg")
        return
      end
      $scene = Scene_Map.new
    end
  end  
  #--------------------------------------------------------------------------
  # ● 控制处理
  #--------------------------------------------------------------------------
  def update_commands
    if Input.trigger?(Input::B)
      on_cancel
    elsif Input.trigger?(Input::UP)
      $game_system.se_play($data_system.cursor_se)
      @index = (@index + 6) % 7
      if @index==1
        @index=0
      end
      @create_window.index = @index
      return
    elsif Input.trigger?(Input::DOWN)
      $game_system.se_play($data_system.cursor_se)        
      @index = (@index + 1) % 7
      if @index==1
        @index=2
      end
      @create_window.index = @index
      return
    end
  end    
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def update
    change_gender
    case @index    
    when 0
      change_name
    when 2
      change_a  
    when 3
      change_b
    when 4
      change_c
    when 5
      change_d
    when 6
      create
    end
    update_commands    
    @create_window.update
  end
end
