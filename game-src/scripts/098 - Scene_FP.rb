#==============================================================================
# ■ Scene_FP
#------------------------------------------------------------------------------
# 　处理内力画面的类。
#==============================================================================
class Scene_FP
  def initialize(menu=false)
    @menu=menu
  end
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    @screen = Spriteset_Map.new
    @command_window = Window_Command.new(96, ["打坐","加力","吸气","疗伤"],1)
    @command_window.x = 538 - @command_window.width
    @command_window.y=64
    @info = Window_Base.new(80,304,480,160)
    @info.contents = Bitmap.new(@info.width - 32, @info.height - 32)
    @info.contents.font.color=Color.new(0, 0, 0, 255)
    @info.visible=false
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      $game_system.update
      update
      if $scene != self
        break
      end
    end
    Graphics.freeze    
    @command_window.dispose
    @info.dispose
    @screen.dispose
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    @command_window.update
    if @command_window.active
      update_command
      return
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
        $scene = Scene_Map.new
        return
      end
    end
    if Input.trigger?(Input::C)
      if $game_variables[32]==nil or $game_variables[32]==0
        draw_disable
        return
      end
      case @command_window.index
      when 0
        Graphics.frame_rate =120
        $game_system.se_play($data_system.decision_se)
        $game_switches[3]=false
        dazuo($game_party.actors[0])
        Graphics.frame_rate =40
      when 1
        $game_system.se_play($data_system.decision_se)
        plus
      when 2
        $game_system.se_play($data_system.decision_se)
        hp_max($game_party.actors[0])
      when 3
        $game_system.se_play($data_system.decision_se)
        recover($game_party.actors[0])
      end
      return
    end
  end
  def draw_disable
    @info.draw_words("请先选择你所要使用的内功心法！")
    @info.visible=true
    for i in 0..40
      Graphics.update
    end
    @info.visible=false
    return
  end
  def dazuo(actor)
    ex=Window_Base.new(160,400,352,64)
    ex.contents=Bitmap.new(320,32)
    age = $game_variables[157] - 14
    #age =[age,8].min
    lv_max=$game_variables[45]/2*10+$game_variables[$game_variables[32]]*10
    lv_max+=$game_variables[19]/1000
    lv_max+=[20*age,920].min
    lv_max=[lv_max,65535].min
    ex.contents.font.color = Color.new(0, 0, 0, 255)
    loop do
      Input.update
      if Input.trigger?(Input::B)
        break
      end
      step=$game_variables[45]*7+$game_variables[$game_variables[32]]*10+($game_variables[14])*20
      step/=100
      step=1 if step<1
      actor.sp+=step
      if $game_variables[24]==0
        actor.maxsp=1
      else
        actor.maxsp=$game_variables[24]*2
      end
      process=200*actor.sp/actor.maxsp
      Graphics.update
      Input.update
      draw_process(process,ex)
      for i in 0..4
        Graphics.update
        if Input.trigger?(Input::B)
          ex.dispose
          return
        end
      end
      if actor.sp>=actor.maxsp
        actor.sp=actor.maxsp
        $game_variables[24]+=1
        if $game_variables[24]>lv_max
          $game_variables[24]-=1
          actor.sp=$game_variables[24]
          ex.contents.clear
          ex.visible=false
          @info.visible=true
          @info.draw_words("你内功等级不够！")
          for i in 0..120
            Graphics.update
          end
          break
        end
        actor.sp=0
      end
    end
    @info.visible=false
    ex.dispose
    $game_switches[3]=true
    return
  end
  def draw_process(process,obj)
    actor=$game_party.actors[0]
    obj.update
    obj.contents.clear
    #边框
    obj.contents.fill_rect(5,9,200,1,Color.new(0, 0, 0, 255))
    obj.contents.fill_rect(5,24,200,1,Color.new(0, 0, 0, 255))
    obj.contents.fill_rect(5,9,1,15,Color.new(0, 0, 0, 255))
    obj.contents.fill_rect(205,9,1,16,Color.new(0, 0, 0, 255))
    #进度条
    obj.contents.fill_rect(5,9,process,15,Color.new(0, 0, 0, 255))
    #点数/等级
    obj.contents.draw_text(216,0,128,32,actor.sp.to_s+"/"+
    $game_variables[24].to_s)
  end
  def plus
    li=Window_InputNumber.new(3)
    li.x=320
    li.y=96
    li.opacity=255
    li.back_opacity=255
    li.number=$game_variables[23]
    loop do
      Graphics.update
      Input.update
      li.update
      if Input.trigger?(Input::B)
        $game_system.se_play($data_system.cancel_se)
        break
      end
      if Input.trigger?(Input::C)
        $game_variables[23]=li.number
        break
      end
    end
    max=$game_variables[45]+$game_variables[$game_variables[32]]*2
    max/=4
    li.dispose
    if $game_variables[23]>=max
      $game_variables[23]=max
      p=Window_Base.new(128,400,352,64)
      p.contents=Bitmap.new(320,32)
      p.contents.font.color.set(0,0,0)
      p.contents.draw_text(0,0,320,32,"你目前加力上限为:"+max.to_s,1)
      for i in 0..40
        Graphics.update
      end
      p.dispose
    end
    return
  end
  def hp_max(actor)
    full_hp=$game_variables[24]/4
    full_hp+=100
    full_hp+=[($game_variables[157]-14)*20,300].min
    if actor.sp<15 or $game_variables[24]<50
      @info.draw_words("你的内力不够！")
      @info.visible=true
      for i in 0..40
        Graphics.update
      end
      @info.visible=false
      return
    end
    if actor.hp>=actor.maxhp
      s="你现在体力充沛!"
      actor.hp=actor.maxhp
    else
      if actor.sp<actor.maxhp-actor.hp
        actor.hp+=actor.sp
        actor.sp=0
      else
        actor.sp-=(actor.maxhp-actor.hp)
        actor.hp=actor.maxhp
      end
      s="你深深吸了口气，脸色看起来好多了！"
    end
    @info.draw_words(s)
    @info.visible=true
    for i in 0..40
      Graphics.update
    end
    @info.visible=false
    return
  end
  def recover(actor)
    full_hp=100+$game_variables[24]/4
    full_hp+=[($game_variables[157]-14)*20,300].min
    if actor.maxhp<(full_hp*0.33)
      @info.draw_words("你已受伤过重，只怕一运真气便有生命危险。")
      @info.visible=true
      for i in 0..40
        Graphics.update
      end
      @info.visible=false
      return
    end
    if actor.sp<60
      @info.draw_words("你内力不够，不能疗伤！")
      @info.visible=true
      for i in 0..40
        Graphics.update
      end
      @info.visible=false
      return
    end
    if $game_variables[$game_variables[32]]<30 or $game_variables[45]<30
      @info.draw_words("你运功良久，一抖衣袖，长叹一声站起身来。")
      @info.visible=true
      for i in 0..40
        Graphics.update
      end
      @info.visible=false
      return
    end
    if actor.maxhp>=full_hp
      @info.draw_words("你现在并没有受伤！")
      @info.visible=true
      for i in 0..40
        Graphics.update
      end
      @info.visible=false
      return
    else
      actor.maxhp+=(full_hp*0.05)
      actor.sp-=54
      actor.maxhp=full_hp if actor.maxhp>full_hp
      @info.draw_words("你全身放松，坐下来开始运功疗伤。")
      @info.visible=true
      for i in 0..35
        Graphics.update
      end
      @info.draw_words("你催动真气，脸上一阵白一阵红，哇地一声，吐出一口淤血，脸色看起来好多了。")
      for i in 0..45
        Graphics.update
      end
      @info.visible=false
      return
    end
  end
end