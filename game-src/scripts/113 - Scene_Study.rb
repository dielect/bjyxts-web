#==============================================================================
# ■ Scene_Study
#------------------------------------------------------------------------------
# 　处理请教画面的类。
#==============================================================================
class Scene_Study
  def initialize(school_id,teacher_id=1)
    @school=school_id
    @teacher=teacher_id
    case @school
    when 0
      case @teacher
      when 1#顾炎武
        @skill_list=[[48,180]]
      when 2#独行大侠
        @skill_list=[[40,250],[41,250],[42,250],[39,250],[43,250],[44,250],
        [45,250],[46,250],[47,250]]
      end
    when 1
      case @teacher
      when 1#商宝震
        @skill_list=[[40,60],[42,60],[46,60],[45,80],[47,60],[53,60],[80,60],
        [64,60],[72,60],[48,50]]
      when 2#商剑鸣
        @skill_list=[[40,110],[42,110],[46,110],[45,110],[47,110],[53,110],
        [80,110],[64,110],[72,150],[48,50]]
      when 3#王维扬
        @skill_list=[[40,160],[42,160],[46,160],[45,160],[47,160],[53,110],
        [54,180],[80,180],[64,160],[72,250],[48,60]]
      end
    when 2
      case @teacher
      when 1#平婆婆
        @skill_list=[[40,70],[46,70],[45,70],[47,50],[55,70],[65,60],[73,80],
        [48,60]]
      when 2#桑青虹
        @skill_list=[[40,100],[44,130],[46,110],[45,100],[47,100],[55,100],
        [88,130],[65,100],[73,150],[48,100],[49,120]]
      when 3#唐婉辞
        @skill_list=[[40,100],[42,120],[46,120],[45,100],[47,100],[55,100],
        [81,120],[65,120],[73,150],[48,100],[49,80]]
      when 4#李清照
        @skill_list=[[40,150],[44,160],[42,160],[46,140],[45,140],[47,140],
        [55,180],[88,180],[81,180],[65,150],[73,250],[48,150],[49,150]]
      end
    when 3
      case @teacher
      when 1#方长老
        @skill_list=[[40,150],[43,120],[45,120],[46,120],[47,120],
        [56,120],[89,120],[66,120],[74,150],[48,50],[50,120]]
      when 2#余鸿儒
        @skill_list=[[40,160],[43,160],[45,160],[46,160],[47,160],
        [56,180],[89,180],[66,160],[74,250],[48,150],[50,180]]
      end
    when 4
      case @teacher
      when 1#滕王丸
        @skill_list=[[40,120],[42,80],[46,100],[45,100],[47,100],
        [57,120],[82,60],[67,100],[75,150],[48,60]]
      when 2#陈美娜
        @skill_list=[[40,80],[42,120],[46,100],[45,100],[47,100],
        [57,60],[82,120],[67,100],[75,150],[48,60]]
      when 3#和仲阳
        @skill_list=[[40,150],[42,180],[46,140],[45,160],[47,140],
        [57,150],[82,180],[67,170],[75,250],[48,120]]
      end
    when 5
      case @teacher
      when 1#苍月道长
        @skill_list=[[40,120],[42,130],[46,130],[45,130],[47,130],
        [83,130],[68,130],[76,150],[48,100]]
      when 2#古松道长
        @skill_list=[[40,120],[46,120],[45,120],[47,120],
        [58,120],[68,120],[76,120]]
      when 3#清虚道长
        @skill_list=[[40,200],[42,200],[41,200],[46,200],[45,200],[47,200],
        [58,220],[85,220],[68,220],[76,250],[48,130]]
      end
    when 6
      case @teacher
      when 1#雪山教头
        @skill_list=[[40,50],[41,50],[46,50],[45,50],[47,50],
        [87,60],[69,50],[77,50]]
      when 2#封万剑
        @skill_list=[[40,120],[41,120],[46,120],[45,120],[47,120],
        [87,120],[86,120],[69,120],[77,120]]
      when 3#白瑞德
        @skill_list=[[40,150],[41,150],[46,140],[45,140],[47,140],
        [59,180],[86,170],[69,150],[77,250],[48,80]]
      end
    when 7
      case @teacher
      when 1#手抄本
        @skill_list=[[45,250],[73,250]]
      when 2#惊天刀谱
        @skill_list=[[42,250],[82,200]]
      when 3#焦黄纸页
        @skill_list=[[47,250],[46,250]]
      when 4#拳经
        @skill_list=[[40,250],[60,200]]
      when 5#菜花宝典
        @skill_list=[[49,250],[51,100]]
      end
    end
    if @school !=7
      @top_window=Window_Base.new(0, 0, 640, 64)
      @top_window.contents = Bitmap.new(288, 32)
      @top_window.contents.font.color.set(0,0,0)
      @top_window.contents.draw_text(4, 0, 256, 32, "你想学什么就说吧")
    end
    @list=[]
    for i in @skill_list
      sk=$data_system.variables[i[0]]
      case sk.size
      when 9
        sk+=" "*4
      when 12
        sk+=" "*2
      end
      sk+=" " if i[1]<100
      sk+="×"+i[1].to_s
      @list.push sk
    end
    @skill_window=Window_Command.new(224,@list)
    @skill_window.y=48
    @skill_window.x=8
    @confirm_window = Window_Base.new(80, 368, 480, 64)
    @confirm_window.contents = Bitmap.new(448, 32)
    @confirm_window.contents.font.color.set(0,0,0)
    @confirm_window.contents.draw_text(0, 0, 448, 32, "你的功夫进步了！继续学习吗？",1)
    @confirm_window.visible = false
    @confirm_window.z = 1300
    @yes_no_window = Window_Command.new(256, ["确定","放弃"],2)
    @yes_no_window.visible = false
    @yes_no_window.active = false
    @yes_no_window.index = 0
    @yes_no_window.x = 192
    @yes_no_window.y = 416
    @yes_no_window.z = 1500
    @info = Window_Base.new(80,304,480,160)
    @info.contents = Bitmap.new(@info.width - 32, @info.height - 32)
    @info.contents.font.color=Color.new(0, 0, 0, 255)
    @info.visible=false
    @continue = true
  end
  def main
    @screen = Spriteset_Map.new
    Graphics.transition
    # 主循环
    loop do
      $scene=Scene_Map.new if @skill_list.size==0
      # 刷新游戏画面
      Graphics.update
      # 刷新输入信息
      Input.update
      # 刷新信息
      update
      # 如果画面切换就中断循环
      if $scene != self
        break
      end
    end
    #Detect.make_snapshot
    # 准备过渡
    Graphics.freeze
    # 释放窗口
    @top_window.dispose if @school !=7
    @skill_window.dispose
    @yes_no_window.dispose
    @confirm_window.dispose
    @info.dispose
    @screen.dispose
  end
  def update
    @skill_window.update
    @yes_no_window.update
    if @yes_no_window.active
      update_command_2
      return
    end
    if @skill_window.active
      update_command_1
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (命令窗口被激活的情况下)
  #--------------------------------------------------------------------------
  def update_command_1
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      #study_skill
      $scene = Scene_Map.new
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      @skill_window.active=false
      sk=@skill_list[@skill_window.index]
      Graphics.frame_rate = 120
      study(sk)
      Graphics.frame_rate = 40
    end
  end
  def update_command_2
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
      @skill_window.active=true
      @yes_no_window.active=false
      @confirm_window.visible = false
      @yes_no_window.visible = false
      @yes_no_window.index=0
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      if @yes_no_window.index==0
        @yes_no_window.active=false
        @confirm_window.visible = false
        @yes_no_window.visible = false
        sk=@skill_list[@skill_window.index]
        Graphics.frame_rate = 120
        study(sk)
        Graphics.frame_rate = 40
      else
        @skill_window.active=true
        @yes_no_window.active=false
        @confirm_window.visible = false
        @yes_no_window.visible = false
        @yes_no_window.index=0
      end
    end
  end
  def study(sk)
    skill_number=sk[0]
    skill_point=skill_number+60
    @max_level=sk[1]
    ex=Window_Base.new(160,400,352,64)
    ex.contents=Bitmap.new(320,32)
    ex.contents.font.color.set(0,0,0)
    actor = $game_party.actors[0]
    agi=$game_variables[48]/10+$game_variables[13]+$game_variables[93]
    agi /=2
    point_max=($game_variables[skill_number]+1) **2
    point_max*=((rand(100)+9950.9)/10000.11)
    ex.contents.font.color = Color.new(0, 0, 0, 255)
    loop do
      unless ckeck_exp_maxlv(skill_number)
        ex.contents.clear
        ex.visible=false
        @info.draw_words("你的武学经验不足,无法领会更深的功夫！")
        for i in 0..120
          Graphics.update
        end
        @continue=false
        break
      end
      if $game_variables[20]>0
        $game_variables[20]-=1
        $game_variables[skill_point]+=agi
        if skill_number==48
          if $game_party.gold>=study_gold($game_variables[48])
            $game_party.gain_gold(-1*study_gold($game_variables[48]))
          else
            $game_variables[20]+=1
            $game_variables[skill_point]-=agi
            ex.contents.clear
            ex.visible=false
            @info.draw_words("没钱读什么书啊，回去准备够学费再来吧！")
            @continue=false
            for i in 0..120
              Graphics.update
            end
            break
          end
        end
      end
      if $game_variables[20]<=0
        $game_variables[20]=0
        ex.contents.clear
        ex.visible=false
        @info.draw_words("你的潜能已经发挥到极限了，没有办法再成长了。")
        for i in 0..120
          Graphics.update
        end
        @continue=false
        break
      end
      if $game_variables[skill_number]>@max_level
        $game_variables[20]+=1
        $game_variables[skill_point]=0
        ex.contents.clear
        ex.visible=false
        @info.draw_words(0,0,320,32,"你的功夫已经不输为师了，真是可喜可贺呀！")
        for i in 0..120
          Graphics.update
        end
        @continue=false
        break
      end
      Graphics.update
      Input.update
      process=200*$game_variables[skill_point]/point_max
      Graphics.update
      draw_process(process,ex,skill_point,skill_number)
      if $game_variables[skill_point]>=point_max.truncate+1
        $game_variables[skill_point]=0
        $game_variables[skill_number]+=1
        @continue=true
        for i in 0..10
          Graphics.update
        end
        break
      end
      if Input.trigger?(Input::B)
        $game_variables[skill_point]-=1
        @continue=false
        break
      end
    end
    if @continue
      @confirm_window.visible = true
      @yes_no_window.visible = true
      @yes_no_window.active = true
      @skill_window.active=false
      @continue=false
    else
      @confirm_window.visible = false
      @yes_no_window.visible = false
      @yes_no_window.active = false
      @skill_window.active=true
    end
    ex.dispose
    @info.visible=false
    Input.update
  end
  def draw_process(process,ex,skill_point,skill_number)
    process=200 if process>=200
    ex.contents.clear
    #边框
    ex.contents.fill_rect(5,9,200,1,Color.new(0,0, 0, 255))
    ex.contents.fill_rect(5,24,200,1,Color.new(0,0, 0, 255))
    ex.contents.fill_rect(5,9,1,15,Color.new(0,0, 0, 255))
    ex.contents.fill_rect(205,9,1,16,Color.new(0,0, 0, 255))
    #进度条
    ex.contents.fill_rect(5,9,process,15,Color.new(0,0, 0, 255))
    #点数/等级
    ex.contents.draw_text(216,0,128,32,$game_variables[skill_point].to_s+
    "/"+$game_variables[skill_number].to_s)
  end
  def study_gold(lv)
    return 5 if lv<=20
    return 10 if lv<=30
    return 50 if lv<=50
    return 100 if lv<=60
    return 150 if lv<=80
    return 300 if lv<=100
    return 500 if lv<=120
    return 1000
  end
end