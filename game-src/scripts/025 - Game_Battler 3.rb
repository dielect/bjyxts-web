#==============================================================================
# ■ Game_Battler (分割定义 3)
#------------------------------------------------------------------------------
# 　处理战斗者的类。这个类作为 Game_Actor 类与 Game_Enemy 类的
# 超级类来使用。
#==============================================================================

class Game_Battler
  #--------------------------------------------------------------------------
  # ● 可以使用特技的判定
  #     skill_id : 特技 ID
  #--------------------------------------------------------------------------
  def skill_can_use?(skill_id)
    # SP 不足的情况下不能使用
    if $data_skills[skill_id].sp_cost > self.sp
      return false
    end
    # 战斗不能的情况下不能使用
    if dead?
      return false
    end
    # 沉默状态的情况下、物理特技以外的特技不能使用
    if $data_skills[skill_id].atk_f == 0 and self.restriction == 1
      return false
    end
    # 获取可以使用的时机
    occasion = $data_skills[skill_id].occasion
    # 战斗中的情况下
    if $game_temp.in_battle
      # [平时] 或者是 [战斗中] 可以使用
      return (occasion == 0 or occasion == 1)
    # 不是战斗中的情况下
    else
      # [平时] 或者是 [菜单中] 可以使用
      return (occasion == 0 or occasion == 2)
    end
  end
  #--------------------------------------------------------------------------
  # ● 应用通常攻击效果
  #     attacker : 攻击者 (battler)
  #--------------------------------------------------------------------------
  def attack_effect(attacker,s_atk1,s_atk2,s_atk3)
    # 清除会心一击标志
    self.critical = false
    # 第一命中判定
    hit_result = (rand(100) < attacker.hit)
    hits=attacker.str
    percent=100*(hits-self.dex)/([self.dex,attacker.dex].min+1)
    n_hit=percent
    if attacker.is_a?(Game_Actor)
      n_hit=50 if self.npc_level==0
      hit_add=$game_variables[19]-$npc_data[26]
      hit_add/=([$game_variables[19],$npc_data[26]].min+1)
      n_hit+=10 if attacker.weapon_id !=0
    else
      n_hit=50 if get_actor_level==0
      hit_add=$npc_data[26]-$game_variables[19]
      hit_add/=([$game_variables[19],$npc_data[26]].min+1)
      n_hit+=10 if $npc_data[9] !=0
    end
    n_hit+=(50+rand(13))
    hit_add=[hit_add,80].min
    hit_add=[hit_add,-80].max
    n_hit+=hit_add*5
    hit_result &= (rand(100)<=n_hit)
    if hit_result == true
      $fenshen=false
      $gedang=false
      #判定影分身
      if attacker.state?(7)
        i=rand(100)
        if i<25
          text=draw_defend2_text(self,5).split('|')
          $defend_text=text[0]
          $dis_id=5
          $gedang=true
          hit_result=false
          self.damage="Miss"
          self.critical = false
          return true
        end
      end
      #判定格挡
      if self.is_a?(Game_Actor)
        if self.weapon_id !=0 and $game_variables[47]>0
          i=rand(100)
          j=($game_variables[14]+$game_variables[11])/2+10
          j+=($game_variables[47]*2+$game_variables[40])/30
          j=[j,55].min
          if i<j
            text=draw_defend2_text(self).split('|')
            $defend_text=text[0]
            $dis_id=text[1].to_i
            hit_result == false
            $gedang=true
            self.damage="Miss"
            self.critical = false
            return true
          end
        else
          if self.weapon_id==0 and $game_variables[47]>0
            i=rand(100)
            j=($game_variables[14]+$game_variables[11])/2
            j+=($game_variables[47]*2+$game_variables[40])/30
            j*=0.75
            j=[j,35].min
            if i<j
              $defend_text="结果被你挡开了"
              $dis_id=4
              hit_result == false
              $gedang=true
              self.damage="Miss"
              self.critical = false
              return true
            end
          end
        end
      else
        if $npc_data[9] !=0 and self.get_skill_level(47)>0
          i=rand(100)
          j=($npc_data[3]+$npc_data[0])/2+10
          j+=(self.get_skill_level(47)+2*self.get_skill_level(40))/30
          j=[j,55].min
          if i<j
            text=draw_defend2_text(self).split('|')
            $defend_text=text[0]
            $dis_id=text[1].to_i
            hit_result == false
            $gedang=true
            self.damage="Miss"
            self.critical = false
            return true
          end
        else
          if $npc_data[9]==0 and self.get_skill_level(47)>0
            i=rand(100)
            j=($npc_data[3]+$npc_data[0])/2
            j+=(self.get_skill_level(47)+2*self.get_skill_level(40))/30
            j*=0.75
            j=[j,35].min
            if i<j
              $defend_text="结果被"+self.name+"挡开了"
              $dis_id=4
              hit_result == false
              $gedang=true
              self.damage="Miss"
              self.critical = false
              return true
            end
          end
        end
      end
      # 计算基本伤害
      if attacker.is_a?(Game_Actor)
        if $game_variables[23]>0 and attacker.sp>0
          atk=attacker.atk+[attacker.sp/20,150].min
        else
          atk=attacker.atk-$game_variables[23]/2
        end
        dmg_per=$npc_data[28]*self.get_skill_level(77)/65535
        dmg_per=[dmg_per,0.3].min
        if 1.2*$game_actors[1].full_fp<$game_variables[24] and $game_switches[96]
          baoti=$game_variables[24]-$game_actors[1].full_fp*1.2
          gailv=rand($game_actors[1].full_fp)
          if gailv<= baoti
            $game_actors[1].hp/=2
            $game_actors[1].sp/=2
            $game_actors[1].maxhp/=2
          end
        end
        s_atk1=($game_variables[50]/10*5+s_atk1.to_i).to_s
      else
        if attacker.exp>0 and attacker.sp>0
          atk=attacker.atk+[attacker.sp/20,150].min
        else
          atk=attacker.atk-attacker.exp/2
        end
        dmg_per=$game_variables[96]*$game_variables[77]/65535.0
        dmg_per=[dmg_per,0.3].min
        s_atk1=(attacker.get_skill_level(50)/3+s_atk1.to_i).to_s
      end
      atk=atk*(s_atk1.to_i/100.0+0.8)
      self.damage=atk/2+rand(atk/2)
      self.damage*=(1.0-dmg_per)
      self.damage=self.damage.truncate
    end
    # 命中的情况下
    if hit_result == true
      if attacker.is_a?(Game_Actor)
        attacker.sp-=$game_variables[23]
        if attacker.sp<=0
          attacker.sp=0
        end
      else
        attacker.sp-=attacker.exp
        if attacker.sp<=0
          attacker.sp=0
        end
      end
      # 状态冲击解除
      remove_states_shock
      if attacker.is_a?(Game_Actor)
        if attacker.weapon_id !=0
          if weapon_matching_skill?
            sk_id=$game_variables[30]
          else
            sk_id=get_weapon_base_skill
          end
        else
          sk_id=$game_variables[29]!=0 ? $game_variables[29]:40
        end
        result_array=draw_hit_result(self.name,s_atk3)
        index=get_hit_index(damage)
        index=[index,result_array.size-1].min
        i=rand(1)
        $defend_text=result_array[index]+draw_hurt_text(self.name,self.hp-self.damage,self.maxhp,i)
      else
        if $npc_data[9]==0 
          sk_id=$npc_data[4]
          sk_id=40 if sk_id==0
        else
          sk_id=$npc_data[5]
          if sk_id==0
            case $npc_data[9]
            when 8,9,10,11,12,13,14,1,28,29
              sk_id=42
            when 2,3,4,6,7,15,16,17,18,19,20,30
              sk_id=41
            when 5,21,22,23,24
              sk_id=44
            when 25,26,27
              sk_id=43
            end
          end
        end
        full_hp=100+$game_variables[24]/4
        full_hp+=[($game_variables[157]-14)*20,300].min
        result_array=draw_hit_result("你",s_atk3)
        index=get_hit_index(damage)
        index=[index,result_array.size-1].min
        rand(100)<=(1-self.pdef/500.0)*s_atk2.to_i ? i=1 : i=0
        $defend_text=result_array[index]+draw_hurt_text("你",self.hp-self.damage,full_hp,i)
      end
      # HP 的伤害计算
      self.hp -= self.damage
      if self.is_a?(Game_Actor)
        if i==1
          self.maxhp-=[rand(self.damage*1.3),self.damage].min
          self.maxhp=[self.maxhp,1].max
        end
        attacker.hp+=(self.damage*(attacker.get_skill_level(51)/100.0)).truncate
      else
        attacker.hp+=(self.damage*($game_variables[51]/100.0)).truncate
        attacker.hp-=self.damage/2 if self.id==142
      end
      attacker.hp=[attacker.hp,attacker.maxhp].min
      # 状态变化
      @state_changed = false
      states_plus(attacker.plus_state_set)
      states_minus(attacker.minus_state_set)
    # Miss 的情况下
    else  
      text=draw_defend_text(self,attacker).split('|')
      $defend_text=text[0]
      $dis_id=text[1].to_i
      # 伤害设置为 "Miss"
      self.damage = "Miss"
      # 清除会心一击标志
      self.critical = false
    end
    # 过程结束
    return true
  end
  #--------------------------------------------------------------------------
  # ● 应用特技效果
  #     user  : 特技的使用者 (battler)
  #     skill : 特技
  #--------------------------------------------------------------------------
  def skill_effect(user, skill ,window)
    if skill.id !=26 and skill.id !=27
      words=get_skill_words(user ,self ,skill.id)
      window.draw_words(words[0])
      for i in 0..20
        Graphics.update
      end
    end
    if 1.2*$game_actors[1].full_fp<$game_variables[24] and $game_switches[96]
      baoti=$game_variables[24]-$game_actors[1].full_fp*1.2
      gailv=rand($game_actors[1].full_fp)
      if gailv<= baoti
        $game_actors[1].hp/=2
        $game_actors[1].sp/=2
        $game_actors[1].maxhp/=2
      end
    end
    $dis_id2=100
    case skill.id
    when 4,5,24,22,14,15,8,26,27
      attack_times(user,self,skill.id,window)
    #落英缤纷
    when 7
      set_turns(user,2)
      if user.is_a?(Game_Actor)
        if $npc_data[9]==0
          if hit_result?(user,self)
            $defend_text=words[3]
            $dis_id2=3
            self.damage=rand(200)+50
            self.add_state(2)
            self.hp-=self.damage
            user.hp-=self.damage/2 if self.id==142
          else
            $defend_text=words[4]
            $dis_id2=4
            user.add_state(1)
            self.damage="Miss"
          end
        else
          if hit_result?(user,self)
            $defend_text=words[1]
            $dis_id2=1
            id=$npc_data[9]
            $game_party.gain_weapon(id,1)
            $npc_data[9]=0
          else
            $defend_text=words[2]
            $dis_id2=2
            user.add_state(1)
          end
          self.damage=0
        end
      else
        if self.weapon_id==0
          if hit_result?(user,self)
            $defend_text=words[3]
            self.damage=rand(200)+50
            self.add_state(2)
            self.hp-=self.damage
          else
            $defend_text=words[4]
            user.add_state(1)
            self.damage="Miss"
          end
        else
          if hit_result?(user,self)
            $defend_text=words[1]
            id=self.weapon_id
            $game_actors[1].equip(0,0)
            $game_party.gain_weapon(id,-1)
          else
            $defend_text=words[2]
            user.add_state(1)
          end
          self.damage=0
        end
      end
    #八阵化掌为刀
    when 2
      set_turns(user,4)
      if user.is_a?(Game_Actor)
        $game_variables[91]+=$game_variables[54]/10
        $game_variables[94]+=$game_variables[54]/10
        $game_variables[91]=[$game_variables[91],255].min
        $game_variables[94]=[$game_variables[94],255].min
      else
        $npc_data[29]+=user.get_skill_level(54)/10
        $npc_data[24]+=user.get_skill_level(54)/10
        $npc_data[29]=[$npc_data[29],255].min
        $npc_data[24]=[$npc_data[24],255].min
      end
      user.add_state(1)
      $defend_text=""
      self.damage="Miss"
    #八卦化掌为刀
    when 3
      set_turns(user,2)
      if user.is_a?(Game_Actor)
        $game_variables[94] += (($game_variables[40]+$game_variables[53])/20)
        $game_variables[94]=[$game_variables[94],255].min
      else
        $npc_data[24]+=user.get_skill_level(54)/10
        $npc_data[24]=[$npc_data[24],255].min
      end
      $defend_text=""
      self.damage="Miss"
    #三花
    when 6
      set_turns(user,9)
      if user.is_a?(Game_Actor)
        $game_variables[92]+=($game_variables[73]/5-4)
        $game_variables[92]=[$game_variables[92],255].min
        $game_variables[95]=($game_variables[45]+2*$game_variables[73])/10-5
      else
        $npc_data[30]+=user.get_skill_level(73)/5-4
        $npc_data[30]=[$npc_data[30],255].min
        $npc_data[25]=user.get_skill_level(45)+2*user.get_skill_level(73)/10-5
      end
      $defend_text=""
      self.damage="Miss"
    #雷动九天
    when 9
      if user.is_a?(Game_Actor)
        $game_variables[91]+=(3+($game_variables[45]+$game_variables[74])/10)
        $game_variables[91]=[$game_variables[91],255].min
      else
        $npc_data[29]+=3+(user.get_skill_level(45)+user.get_skill_level(74))/10
        $npc_data[29]=[$npc_data[29],255].min
      end
      $defend_text=""
      self.damage="Miss"
    #红莲出世
    when 10
      if user.is_a?(Game_Actor)
        $game_variables[94]+=(($game_variables[45]+$game_variables[74])/10-3)
        $game_variables[94]=[$game_variables[94],255].min
      else
        $npc_data[24]+=(user.get_skill_level(45)+user.get_skill_level(74))/10-3
        $npc_data[24]=[$npc_data[24],255].min
      end
      user.add_state(11)
      $defend_text=""
      self.damage="Miss"
    #忍法影分身
    when 13
      set_turns(user,7)
      if user.is_a?(Game_Actor)
        $game_variables[93]=90
        $game_variables[22]=30
      end
      self.add_state(7)
      $defend_text=""
      self.damage="Miss"
    #连字诀
    when 21
      set_turns(user,6)
      if user.is_a?(Game_Actor)
        $game_variables[94]+=10
        $game_variables[95]+=($game_variables[85]/10)
        $game_variables[95]=[$game_variables[95],255].min
        $game_variables[94]=[$game_variables[94],255].min
      else
        $npc_data[24]+=10
        $npc_data[25]+=user.get_skill_level(85)/10
        $npc_data[25]=[$npc_data[25],255].min
        $npc_data[24]=[$npc_data[24],255].min
      end
      $defend_text=""
      self.damage="Miss"
    #冰心诀
    when 25
      set_turns(user,5)
      if user.is_a?(Game_Actor)
        $game_variables[96]+=($game_variables[45]/8+$game_variables[77]/4)
        $game_variables[96]=[$game_variables[96],255].min
      else
        $npc_data[28]+=user.get_skill_level(45)/8+user.get_skill_level(77)/4
        $npc_data[28]=[$npc_data[28],255].min
      end
      $defend_text=""
      self.damage="Miss"
    #流星飞掷
    when 11
      if user.is_a?(Game_Actor)
        hit=($game_variables[11]+$game_variables[40]/10+$game_variables[91])/33.0
        dama=$game_variables[11]*2+($game_variables[43]/2+$game_variables[89])*2
      else
        hit=($npc_data[0]+user.get_skill_level(40)/10+$npc_data[29])/33.0
        dama=$npc_data[0]*2+(user.get_skill_level(43)/2+user.get_skill_level(89))*2
      end
      hit*=(40*(user.sp+1.0)/(2*self.sp+1.0))
      hit=0 if user.sp<=self.sp/3.0
      hit=0 if self.id>125
      hit=[hit,40].min
      hit_result=(rand(100)<hit)
      if hit_result
        self.damage=dama
        $defend_text=words[1]
        $dis_id2=1
        self.hp-=self.damage
      else
        $defend_text=words[2]
        $dis_id2=2
        user.add_state(1)
        self.damage="Miss"
      end
      if user.is_a?(Game_Actor)
        id=$game_actors[1].weapon_id
        $game_actors[1].equip(0,0)
        $game_party.lose_weapon(id,1)
      else
        id=$npc_data[9]
        $npc_data[9]=0
      end
    #忍术烟幕
    when 12
      set_turns(user,10)
      if user.is_a?(Game_Actor)
        $game_variables[94]=$npc_data[24]
        $game_variables[94]=[$game_variables[94],255].min
      else
        $npc_data[24]=$game_variables[94]
        $npc_data[24]=[$npc_data[24],255].min
      end
      if hit_result?(user,self)
        $defend_text=""
        self.add_state(10)
      else
        $defend_text=words[2]
        user.add_state(3)
        $dis_id2=2
      end
      self.damage="Miss"
    #挤字诀
    when 16
      hit=85*(user.sp+1.0)/(self.sp+1.0)
      hit=0 if user.sp<=self.sp/3.0
      hit=[hit,85].min
      hit_result=(rand(100)<=hit)
      if hit_result
        if (user.sp+1.0)/(self.sp+1.0)<=1
          $defend_text=words[2]
          $dis_id2=2
          self.sp-=350
          self.sp=[self.sp,0].max
        else
          $defend_text=words[1]
          $dis_id2=1
          if user.is_a?(Game_Actor)
            self.sp-=(user.sp/10+350+$game_variables[23])
          else
            self.sp-=user.sp/10+350+user.exp
          end
          self.sp=[self.sp,0].max
        end
      else
        $defend_text=words[3]
        $dis_id2=3
        user.add_state(1)
      end
      self.damage=0
    #乱环诀，缠字诀
    when 17,20
      if hit_result?(user,self)
        $defend_text=words[1]
        $dis_id2=1
        self.add_state(2)
      else
        $defend_text=words[2]
        $dis_id2=2
        user.add_state(1)
      end
      self.damage=0
    #阴阳诀
    when 18
      if rand(100)<50
        #阴手
        window.draw_words(words[1])
        set_turns(user,19)
        for i in 0..20
          Graphics.update
        end
        if hit_result?(user,self)
          $defend_text=words[2]
          $dis_id2=12
          self.add_state(19)
        else
          $defend_text=words[3]
          $dis_id2=13
          user.add_state(1)
        end
        self.damage=0
      else
        #揽雀尾
        if user.is_a?(Game_Actor)
          $game_variables[91]+=(($game_variables[40]+$game_variables[58])/10)
          $game_variables[91]=[$game_variables[91],255].min
          $game_variables[94]+=15
          $game_variables[94]=[$game_variables[94],255].min
        else
          $npc_data[29]+=(user.get_skill_level(40)+user.get_skill_level(58))/10
          $npc_data[29]=[$npc_data[29],255].min
          $npc_data[24]+=15
          $npc_data[24]=[$npc_data[24],255].min
        end
        user.add_state(1)
        user.add_state(8)
        s_atk=draw_atk_text(user,self,58,0,0,window).split('|')
        self.attack_effect(user,s_atk[0],s_atk[1],s_atk[2])
        user.remove_state(8)
      end
    #神倒鬼跌
    when 23
      set_turns(user,19)
      if hit_result?(user,self)
        if user.is_a?(Game_Actor)
          self.damage=$game_variables[40]/5+$game_variables[59]*3/10
        else
          self.damage=user.get_skill_level(40)/5+user.get_skill_level(59)*3/10
        end
        $defend_text=words[1]
        $dis_id2=1
        self.hp-=self.damage
        user.hp-=self.damage/2 if self.is_a?(Game_Enemy) and self.id==142
        self.add_state(19)
      else
        $defend_text=words[2]
        $dis_id2=2
        user.add_state(1)
        self.damage="Miss"
      end
    #震字诀
    when 19
      if hit_result?(user,self)
        if user.is_a?(Game_Actor)
          self.damage=user.sp/10-self.sp/30+$game_variables[23]
        else
          self.damage=user.sp/10-self.sp/30+user.exp
        end
        $defend_text=words[1]
        $dis_id2=1
        user.hp-=self.damage/2 if self.id==142
        self.hp-=self.damage
      else
        $defend_text=words[2]
        $dis_id2=2
        user.add_state(1)
        self.damage="Miss"
      end
    end
    if skill.scope>=3
      states_plus(skill.plus_state_set)
      states_minus(skill.minus_state_set)
      self.damage = ""
      $defend_text=""
      return true
    end
    # 清除会心一击标志
    self.critical = false
    # 清除有效标志
    effective = true
    return effective
  end
  #--------------------------------------------------------------------------
  # ● 应用物品效果
  #     item : 物品
  #--------------------------------------------------------------------------
  def item_effect(item)
    # 清除会心一击标志
    self.critical = false
    # 物品的效果范围是 HP 1 以上的己方、自己的 HP 为 0、
    # 或者物品的效果范围是 HP 0 的己方、自己的 HP 为 1 以上的情况下
    if ((item.scope == 3 or item.scope == 4) and self.hp == 0) or
       ((item.scope == 5 or item.scope == 6) and self.hp >= 1)
      # 过程结束
      return false
    end
    # 清除有效标志
    effective = false
    # 公共事件 ID 是有效的情况下,设置为有效标志
    effective |= item.common_event_id > 0
    # 命中判定
    hit_result = (rand(100) < item.hit)
    # 不确定的特技的情况下设置为有效标志
    effective |= item.hit < 100
    # 命中的情况
    if hit_result == true
      # 计算回复量
      recover_hp = maxhp * item.recover_hp_rate / 100 + item.recover_hp
      recover_sp = maxsp * item.recover_sp_rate / 100 + item.recover_sp
      if recover_hp < 0
        recover_hp += self.pdef * item.pdef_f / 20
        recover_hp += self.mdef * item.mdef_f / 20
        recover_hp = [recover_hp, 0].min
      end
      # 属性修正
      recover_hp *= elements_correct(item.element_set)
      recover_hp /= 100
      recover_sp *= elements_correct(item.element_set)
      recover_sp /= 100
      # 分散
      if item.variance > 0 and recover_hp.abs > 0
        amp = [recover_hp.abs * item.variance / 100, 1].max
        recover_hp += rand(amp+1) + rand(amp+1) - amp
      end
      if item.variance > 0 and recover_sp.abs > 0
        amp = [recover_sp.abs * item.variance / 100, 1].max
        recover_sp += rand(amp+1) + rand(amp+1) - amp
      end
      # 回复量符号为负的情况下
      if recover_hp < 0
        # 防御修正
        if self.guarding?
          recover_hp /= 2
        end
      end
      # HP 回复量符号的反转、设置伤害值
      self.damage = -recover_hp
      # HP 以及 SP 的回复
      last_hp = self.hp
      last_sp = self.sp
      self.hp += recover_hp
      self.sp += recover_sp
      effective |= self.hp != last_hp
      effective |= self.sp != last_sp
      # 状态变化
      @state_changed = false
      effective |= states_plus(item.plus_state_set)
      effective |= states_minus(item.minus_state_set)
      # 能力上升值有效的情况下
      if item.parameter_type > 0 and item.parameter_points != 0
        # 能力值的分支
        case item.parameter_type
        when 1  # MaxHP
          @maxhp_plus += item.parameter_points
        when 2  # MaxSP
          @maxsp_plus += item.parameter_points
        when 3  # 力量
          @str_plus += item.parameter_points
        when 4  # 灵巧
          @dex_plus += item.parameter_points
        when 5  # 速度
          @agi_plus += item.parameter_points
        when 6  # 魔力
          @int_plus += item.parameter_points
        end
        # 设置有效标志
        effective = true
      end
      # HP 回复率与回复量为 0 的情况下
      if item.recover_hp_rate == 0 and item.recover_hp == 0
        # 设置伤害为空的字符串
        self.damage = ""
        # SP 回复率与回复量为 0、能力上升值无效的情况下
        if item.recover_sp_rate == 0 and item.recover_sp == 0 and
           (item.parameter_type == 0 or item.parameter_points == 0)
          # 状态没有变化的情况下
          unless @state_changed
            # 伤害设置为 "Miss"
            self.damage = "Miss"
          end
        end
      end
    # Miss 的情况下
    else
      # 伤害设置为 "Miss"
      self.damage = "Miss"
    end
    # 不在战斗中的情况下
    unless $game_temp.in_battle
      # 伤害设置为 nil
      self.damage = nil
    end
    # 过程结束
    return effective
  end
  #--------------------------------------------------------------------------
  # ● 应用连续伤害效果
  #--------------------------------------------------------------------------
  def slip_damage_effect
    # 设置伤害
    self.damage = self.maxhp / 20
    # 分散
    if self.damage.abs > 0
      amp = [self.damage.abs * 20 / 100, 1].max
      self.damage += rand(amp+1) + rand(amp+1) - amp
    end
    # HP 的伤害减法运算
    self.hp -= self.damage
    # 过程结束
    return true
  end
  #--------------------------------------------------------------------------
  # ● 属性修正计算
  #     element_set : 属性
  #--------------------------------------------------------------------------
  def elements_correct(element_set)
    # 無属性的情况
    if element_set == []
      # 返回 100
      return 100
    end
    # 在被赋予的属性中返回最弱的
    # ※过程 element_rate 是、本类以及继承的 Game_Actor
    #   和 Game_Enemy 类的定义
    weakest = -100
    for i in element_set
      weakest = [weakest, self.element_rate(i)].max
    end
    return weakest
  end
end