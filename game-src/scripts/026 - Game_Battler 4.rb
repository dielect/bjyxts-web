#==============================================================================
# ■ Game_Battler (分割定义 4)
#------------------------------------------------------------------------------
# 　处理战斗者的类。这个类作为 Game_Actor 类与 Game_Enemy 类的
# 超级类来使用。本页主要处理绝招效果。
#==============================================================================
class Game_Battler
  #--------------------------------------------------------------------------
  # ● 状态转换成对应技能编号
  #--------------------------------------------------------------------------
  def state_to_skill(i)
    case i
    when 3
      return 3
    when 4
      return 2
    when 5
      return 25
    when 6
      return 21
    when 7
      return 13
    when 9
      return 6
    when 10
      return 12
    end
    return 0
  end
  #--------------------------------------------------------------------------
  # ● 获取击中描述序号
  #--------------------------------------------------------------------------
  def get_hit_index(damage)
    return 0 if damage<10
    return 1 if damage<20
    return 2 if damage<40
    return 3 if damage<80
    return 4 if damage<120
    return 5 if damage<160
    return 6 if damage<200
    return 7
  end
  #--------------------------------------------------------------------------
  # ● 命中判定
  #     user  : 绝招的使用者 (battler)
  #     target: 绝招目标
  #--------------------------------------------------------------------------
  def hit_result?(user,target)
    hit=85.0*(user.sp+1.0)/(target.sp+1.0)
    hit=0 if user.sp<=target.sp/3.0
    hit=[hit,85].min
    hit_result=(rand(100)<=hit)
    return hit_result
  end
  #--------------------------------------------------------------------------
  # ● 连击绝招
  #     user  : 绝招的使用者 (battler)
  #     id    : 绝招ID
  #     target: 绝招目标
  #--------------------------------------------------------------------------
  def attack_times(user,target,id,window)
    i1=0
    i2=0
    times1=0
    times2=0
    case id
    #雪花六出
    when 24
      i1=86
      if user.is_a?(Game_Actor)
        times1=2+($game_variables[86]-60)/20
        times1=[times1,5].min if $game_switches[101]==false
      else
        times1=2+(user.get_skill_level(86)-60)/20
        times1=[times1,5].min
      end
    #三环套月
    when 22
      i1=85
      times1=3
    #旋风三连斩
    when 14
      i1=82
      times1=3
    #迎风一刀斩
    when 15
      i1=82
      times1=1
      user.add_state(8)
    #柳浪闻莺
    when 8
      i1=55
      times1=2
      i2=81
      times2=1
    #八卦刀影掌
    when 4
      i1=53
      i2=80
      times1=1
      times2=1
    #八阵刀影掌
    when 5
      i1=54
      i2=80
      times1=2
      times2=1
    #周伯通左右互搏
    when 26
      i1=60
      i2=59
      times1=1
      times2=1
      user.add_state(20)
    #玩家左右互搏
    when 27
      i1=0
      times1=2
      user.add_state(20)
    end
    if id !=27 and user.is_a?(Game_Actor) and $game_switches[100]==true and $game_variables[13]<=16
      times1 *=2
      times2 *=2
      user.add_state(20)
    end
    for i in 1..times1
      s_atk=draw_atk_text(user,target,i1,0,0,window).split('|')
      target.attack_effect(user,s_atk[0],s_atk[1],s_atk[2])
      for a in 0..10
        Graphics.update
      end
      unless i==times1 and i2==0 
        # 对像方动画
        if ["Miss",""].include?(target.damage)
          Audio.se_play("Audio/SE/Miss.ogg")
        else
          Audio.se_play("Audio/SE/Blow8.ogg")
        end
        window.draw_words($defend_text)
        for a in 0..30
          Graphics.update
        end
      end
    end
    if i2 !=0
      for i in 1..times2
        s_atk=draw_atk_text(user,target,i2,0,0,window).split('|')
        target.attack_effect(user,s_atk[0],s_atk[1],s_atk[2])
        for a in 0..10
          Graphics.update
        end
        unless i==times2
          # 对像方动画
          if ["Miss",""].include?(target.damage)
            Audio.se_play("Audio/SE/Miss.ogg")
          else
            Audio.se_play("Audio/SE/Blow8.ogg")
          end
          window.draw_words($defend_text)
          for a in 0..30
            Graphics.update
          end
        end
      end
    end
    user.remove_state(8) if user.state?(8)
    user.remove_state(20) if user.state?(20)
    case id
    when 24,22,8
      user.add_state(1)
    when 14,15,4,5
      user.add_state(11)
    end
  end
  #--------------------------------------------------------------------------
  # ● 设置状态持续时间
  #--------------------------------------------------------------------------
  def set_turns(user,id)
    if user.is_a?(Game_Actor)
      $data_states[id].hold_turn=($game_variables[45]+$game_variables[$game_variables[32]])/40
    else
      for i in 72..77
        sk_id=i if user.get_skill_level(i)>0
      end
      $data_states[id].hold_turn=(user.get_skill_level(45)+user.get_skill_level(sk_id))/40
    end
  end
end
    