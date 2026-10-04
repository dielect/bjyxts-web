#==============================================================================
# ■ Scene_Practice
#------------------------------------------------------------------------------
# 　处理练功画面的类。
#==============================================================================
class Scene_Practice
  def initialize(menu=false)
    @menu=menu
    @err=["你的功夫很难再有所提高了，还是向师傅请教一下吧",
          "趁手的兵器都没有一把，瞎比划什么？",
          "你的内力修为不足，要勤修内功！",
          "你受伤了，还是先治疗要紧！",
          "你的武学经验不足，无法领会更深的功夫"]
  end
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    @screen = Spriteset_Map.new
    draw_main_menu
    @list=[]
    @command_list=[]
    for i in 29..31
      if $game_variables[$game_variables[i]]>0
        @list.push $game_variables[i]
        @command_list.push $data_system.variables[$game_variables[i]]
      end
    end
    @skill_window = Window_Command.new(160, @command_list,1)
    @skill_window.x = 490 - @skill_window.width
    @skill_window.y = 64
    $game_switches[3]=false
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      $game_system.update
      update
      if $scene != self
       # study_skill
        break
      end
    end
    #Detect.make_snapshot
    Graphics.freeze
    $game_switches[3]=true
    @skill_window.dispose
    @top_menu.dispose
    @screen.dispose
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    @skill_window.update
    if @skill_window.active
      update_command
      return
    else
      update_ex
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (命令窗口被激活的情况下)
  #--------------------------------------------------------------------------
  def update_command
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      if @menu
        $scene = Scene_Menu.new(3)
        return
      else
        Graphics.frame_rate =120
        $scene = Scene_Map.new
        Graphics.frame_rate =40
        return
      end
    end
    if Input.trigger?(Input::C)
      $game_system.se_play($data_system.decision_se)
      @skill_window.active=false
      return
    end
  end
  def update_ex
    loop do
      Graphics.update
      Input.update
      skill_number=@list[@skill_window.index]
      skill_point=skill_number+60
      if check(skill_number)
        draw2(skill_number,skill_point)
      else
        draw1
        @skill_window.active=true
        return
      end
      if Input.trigger?(Input::B)
        # 演奏取消 SE
        $game_system.se_play($data_system.cancel_se)
        @skill_window.active=true
        return
      end
    end
  end
  #检查合法性
  def check(skill_number)
    actor=$game_party.actors[0]
    full_hp=100+$game_variables[24]/4
    full_hp+=[($game_variables[157]-14)*20,300].min
    ph=[100*actor.maxhp/full_hp,100].min
    if ph !=100
      @msg=@err[3]
      return false
    end
    unless ckeck_exp_maxlv(skill_number)
      @msg=@err[4]
      return false
    end
    if skill_number>=64 and skill_number<=69 #轻功
      if $game_variables[skill_number]>$game_variables[46]
        @msg=@err[0]
        return false
      elsif $game_variables[skill_number]>$game_variables[24]/15
        @msg=@err[2]
        return false
      else
        return true
      end
    end
    if actor.weapon_id==0
      #没有武器的情况下
      if skill_number>=53 and skill_number<=61
        if $game_variables[skill_number]>$game_variables[40]
          @msg=@err[0]
          return false
        elsif $game_variables[skill_number]>$game_variables[24]/15
          @msg=@err[2]
          return false
        end
      else
        @msg=@err[1]
        return false
      end
    else
      #有武器的情况下
      if weapon_matching_skill?(skill_number)
        if $game_variables[skill_number]>$game_variables[weapon_skill_base(skill_number)]
          @msg=@err[0]
          return false
        elsif $game_variables[skill_number]>$game_variables[24]/15
          @msg=@err[2]
          return false
        end
      else
        @msg=@err[1]
        return false
      end
    end
    return true
  end
  #描绘不能练功的提示
  def draw1
    @info_window=Window_Base.new((608-@msg.length*8)/2,400, @msg.length*8+32, 64)
    @info_window.contents=Bitmap.new(@msg.length*8,32)
    @info_window.contents.font.color.set(0,0,0)
    @info_window.contents.draw_text(0,0,@msg.length*8,32,@msg,1)
    for i in 0..50
      Graphics.update
    end
    @info_window.dispose
    return
  end
  #描绘练功的进度
  def draw2(level,point)
    max=$game_variables[level]**2
    step=$game_variables[get_all_skill_base(level)]/5
    step*=($game_variables[13]+$game_variables[48]/10+$game_variables[93])
    step/=15
    if step<=0
      step=1
    end
    ex=Window_Base.new(160,400,352,64)
    ex.contents=Bitmap.new(320,32)
    ex.contents.font.color.set(0,0,0)
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::B)
        ex.dispose
        return
      end
      process=200*$game_variables[point]/max
      draw_process(process,ex,point,level)
      Graphics.update
      Graphics.update
      $game_variables[point]+=step
      if $game_variables[point]>=max
        $game_variables[level]+=1
        $game_variables[point]=0
        #Detect.make_snapshot
        ex.contents.clear
        ex.contents.draw_text(0, 0, 448, 32, "你的功夫进步了！")
        for i in 0..30
          Graphics.update
        end
        break
      end
    end
    ex.dispose
  end
  def draw_process(process,ex,point,level)
    ex.contents.clear
    #边框
    ex.contents.fill_rect(5,9,200,1,Color.new(0, 0, 0, 255))
    ex.contents.fill_rect(5,24,200,1,Color.new(0, 0, 0, 255))
    ex.contents.fill_rect(5,9,1,15,Color.new(0, 0, 0, 255))
    ex.contents.fill_rect(205,9,1,16,Color.new(0, 0, 0, 255))
    #进度条
    ex.contents.fill_rect(5,9,process,15,Color.new(0, 0, 0, 255))
    #点数/等级
    ex.contents.draw_text(216,0,160,32,$game_variables[point].to_s+
    "/"+$game_variables[level].to_s)
  end
end