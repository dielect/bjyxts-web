#==============================================================================
# ■ Scene_NetBattle (分割定义 2)
#------------------------------------------------------------------------------
# 　处理联机战斗画面的类。
#==============================================================================
class Scene_NetBattle
  #--------------------------------------------------------------------------
  # ● 开始主回合
  #--------------------------------------------------------------------------
  def start_phase4
    $game_troop.enemies[0].remove_states_auto(@help_window)
    $game_party.actors[0].blink = false
    @wait_count=600
    # 转移到回合 4
    @phase = 4
    # 回合数计数
    $game_temp.battle_turn += 1
    # 设置角色为非选择状态
    @actor_index = -1
    @active_battler = nil
    # 无效化角色指令窗口
    @actor_command_window.active = false
    @actor_command_window.visible = false
    # 设置主回合标志
    $game_temp.battle_main_phase = true
    # 生成行动顺序
    @action_battlers=[$game_party.actors[0]]
    # 移动到步骤 1
    @phase4_step = 1
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (主回合)
  #--------------------------------------------------------------------------
  def update_phase4
    case @phase4_step
    when 1
      update_phase4_step1
    when 2
      update_phase4_step2
    when 3
      update_phase4_step3
    when 4
      update_phase4_step4
    when 5
      update_phase4_step5
    when 6
      update_phase4_step6
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (主回合步骤 1 : 准备行动)
  #--------------------------------------------------------------------------
  def update_phase4_step1
    # 隐藏帮助窗口
    @help_window.visible = false
    # 判定胜败
    if judge
      return
    end
    # 强制行动的战斗者不存在的情况下
    if $game_temp.forcing_battler == nil
      # 设置战斗事件
      #setup_battle_event
      # 执行战斗事件中的情况下
      if $game_system.battle_interpreter.running?
        return
      end
    end
    # 强制行动的战斗者存在的情况下
    if $game_temp.forcing_battler != nil
      # 在头部添加后移动
      @action_battlers.delete($game_temp.forcing_battler)
      @action_battlers.unshift($game_temp.forcing_battler)
    end
    # 未行动的战斗者不存在的情况下 (全员已经行动)
    if @action_battlers.size == 0
      msg=recv
      # 开始同伴命令回合
      if msg=="recieved"
        @phase=1 
        @wait_count=600
      end
      @wait_count-=1
      if @wait_count<0
        p "网络出现异常，连接已断开"
        $game_party.gain_gold(2000)
        battle_end(1)
      end
      return
    end
    # 初始化动画 ID 和公共事件 ID
    @animation1_id = 0
    @animation2_id = 0
    @common_event_id = 0
    # 未行动的战斗者移动到序列的头部
    @active_battler = @action_battlers.shift
    # 如果已经在战斗之外的情况下
    if @active_battler.index == nil
      return
    end
    # 连续伤害
    if @active_battler.hp > 0 and @active_battler.slip_damage?
      @active_battler.slip_damage_effect
      @active_battler.damage_pop = false
    end
    # 自然解除状态
    @active_battler.remove_states_auto(@help_window)
    if judge
      # 胜利或者失败的情况下 : 过程结束
      return
    end
    # 刷新状态窗口
    @status_window.refresh
    # 移至步骤 2
    @phase4_step = 2
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (主回合步骤 2 : 开始行动)
  #--------------------------------------------------------------------------
  def update_phase4_step2
    # 如果不是强制行动
    unless @active_battler.current_action.forcing
      # 限制为 [敌人为普通攻击] 或 [我方为普通攻击] 的情况下
      if @active_battler.restriction == 2 or @active_battler.restriction == 3
        # 设置行动为攻击
        @active_battler.current_action.kind = 0
        @active_battler.current_action.basic = 0
      end
      # 限制为 [不能行动] 的情况下
      if @active_battler.restriction == 4
        # 清除行动强制对像的战斗者
        $game_temp.forcing_battler = nil
        # 移至步骤 1
        @phase4_step = 1
        return
      end
    end
    # 清除对像战斗者
    @target_battlers = []
    # 行动种类分支
    case @active_battler.current_action.kind
    when 0  # 基本
      make_basic_action_result
    when 1  # 特技
      make_skill_action_result
    when 2  # 物品
      make_item_action_result
    end
    # 移至步骤 3
    if @phase4_step == 2
      @phase4_step = 3
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成基本行动结果
  #--------------------------------------------------------------------------
  def make_basic_action_result
    # 攻击的情况下
    if @active_battler.current_action.basic == 0
      # 设置攻击 ID
      @animation1_id = @active_battler.animation1_id
      @animation2_id = @active_battler.animation2_id
      # 行动方的战斗者是角色的情况下
      if @active_battler.is_a?(Game_Actor)
        @actor_command_window.able_item(1)
        @disable_skill=false
        if @active_battler.restriction == 3
          target = $game_party.random_target_actor
        elsif @active_battler.restriction == 2
          target = $game_troop.random_target_enemy
        else
          index = @active_battler.current_action.target_index
          target = $game_troop.smooth_target_enemy(index)
        end
      end
      # 设置对像方的战斗者序列
      @target_battlers = [target]
      if @active_battler.is_a?(Game_Actor) and $game_switches[100]==true and $game_variables[13]<=16
        for target in @target_battlers
          target.skill_effect(@active_battler,$data_skills[27],@help_window)
        end
        s_atk=[0,0,0,0,0]
      else
        # 应用通常攻击效果
        s_atk=draw_atk_text(@active_battler,target).split('|')
        for target in @target_battlers
          target.attack_effect(@active_battler,s_atk[0],s_atk[1],s_atk[2])
        end
      end
      hit_result=$game_troop.enemies[0].damage
      if hit_result.is_a?(Numeric)
        if hit_result>0
          hit_result=0
          $dis_id=100
        else
          hit_result=2
        end
      else
        hit_result=1
        hit_result=2 if $gedang
      end
      msg="action|1|"+hit_result.to_s+"|"+$game_troop.enemies[0].damage.to_s+"|"+
        $game_troop.enemies[0].hp.to_s+"|"+$game_troop.enemies[0].maxhp.to_s+"|"+
        s_atk[3].to_s+"|"+$dis_id.to_s+"|"+s_atk[4].to_s+"|"
      for i in $game_troop.enemies[0].states
        msg+=i.to_s+"|"
      end
      send(msg)
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 设置物品或特技对像方的战斗者
  #     scope : 特技或者是物品的范围
  #--------------------------------------------------------------------------
  def set_target_battlers(scope)
    # 行动方的战斗者是角色的情况下
    if @active_battler.is_a?(Game_Actor)
      # 效果范围分支
      case scope
      when 1  # 敌单体
        index = @active_battler.current_action.target_index
        @target_battlers.push($game_troop.smooth_target_enemy(index))
      when 2  # 敌全体
        for enemy in $game_troop.enemies
          if enemy.exist?
            @target_battlers.push(enemy)
          end
        end
      when 3  # 我方单体
        index = @active_battler.current_action.target_index
        @target_battlers.push($game_party.smooth_target_actor(index))
      when 4  # 我方全体
        for actor in $game_party.actors
          if actor.exist?
            @target_battlers.push(actor)
          end
        end
      when 5  # 我方单体 (HP 0) 
        index = @active_battler.current_action.target_index
        actor = $game_party.actors[index]
        if actor != nil and actor.hp0?
          @target_battlers.push(actor)
        end
      when 6  # 我方全体 (HP 0) 
        for actor in $game_party.actors
          if actor != nil and actor.hp0?
            @target_battlers.push(actor)
          end
        end
      when 7  # 使用者
        @target_battlers.push(@active_battler)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成特技行动结果
  #--------------------------------------------------------------------------
  def make_skill_action_result
    # 获取特技
    @skill = $data_skills[@active_battler.current_action.skill_id]
    # 如果不是强制行动
    unless @active_battler.current_action.forcing
      # 因为 SP 耗尽而无法使用的情况下
      unless @active_battler.skill_can_use?(@skill.id)
        # 清除强制行动对像的战斗者
        $game_temp.forcing_battler = nil
        # 移至步骤 1
        @phase4_step = 1
        return
      end
    end
    # 消耗 SP
    @active_battler.sp -= @skill.sp_cost
    if @active_battler.is_a?(Game_Actor)
      @actor_command_window.disable_item(1)
      @disable_skill=true
    end
    # 刷新状态窗口
    @status_window.refresh
    # 设置动画 ID
    @animation1_id = @skill.animation1_id
    @animation2_id = @skill.animation2_id
    # 设置公共事件 ID
    @common_event_id = @skill.common_event_id
    # 设置对像侧战斗者
    set_target_battlers(@skill.scope)
    # 应用特技效果
    for target in @target_battlers
      target.skill_effect(@active_battler, @skill, @help_window)
    end
    msg="action|2|"+@skill.id.to_s+"|"+@target_battlers[0].damage.to_s+"|"+
      @target_battlers[0].hp.to_s+"|"+@target_battlers[0].maxhp.to_s+"|"+
      $dis_id2.to_s+"|"+$game_variables[91].to_s+"|"+$game_variables[92].to_s+
      +"|"+$game_variables[94].to_s+"|"+$game_variables[95].to_s+
      "|"+$game_variables[96].to_s+"|"+$npc_data[29]+"|"+$npc_data[30]+
      "|"+$npc_data[24]+"|"+$npc_data[25]+"|"+$npc_data[28]+"|"
    for i in @target_battlers[0].states
      msg+=i.to_s+"|"
    end
    send(msg)
  end
  #--------------------------------------------------------------------------
  # ● 生成物品行动结果
  #--------------------------------------------------------------------------
  def make_item_action_result
    @target=$game_party.actors[0]
    # 获取物品
    @item = $data_items[@active_battler.current_action.item_id]
    # 因为物品耗尽而无法使用的情况下
    unless $game_party.item_can_use?(@item.id)
      return
    end
    $game_party.lose_item(@item.id, 1)
    full_hp=100+$game_variables[24]/4
    full_hp+=[($game_variables[157]-14)*20,300].min
    case @item.id
    when 8
      maxhp=@target.maxhp
      if full_hp==maxhp
        $game_party.gain_item(@item.id,1)
        $game_system.se_play($data_system.buzzer_se)
      else
        maxhp+=full_hp/4
        @target.maxhp=[maxhp,full_hp].min
      end
    when 9
      maxhp=@target.maxhp
      if full_hp==maxhp
        $game_party.gain_item(@item.id,1)
        $game_system.se_play($data_system.buzzer_se)
      else
        maxhp+=full_hp/2
        @target.maxhp=[maxhp,full_hp].min
      end
    when 10
      $game_variables[24] +=5
    end
    send_item
  end
  def send_item
    msg="action|3|"+$game_party.actors[0].hp.to_s+"|"+$game_party.actors[0].maxhp.to_s
    send(msg)
    send(msg)
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (主回合步骤 3 : 行动方动画)
  #--------------------------------------------------------------------------
  def update_phase4_step3
    def update_phase4_step3
    # 行动方动画 (ID 为 0 的情况下是白色闪烁)
    if @animation1_id == 0
      @active_battler.white_flash = false
    else
      @active_battler.animation_id = @animation1_id
      @active_battler.animation_hit = true
    end
    @help_window.draw_words($defend_text)
    # 对像方动画
    for target in @target_battlers
      target.animation_id = @animation2_id
      target.animation_hit = (target.damage != "Miss")
      if ["Miss",""].include?(target.damage)
        Audio.se_play("Audio/SE/Miss.ogg")
      else
        target.animation_id = 1
      end
    end
    # 限制动画长度、最低 8 帧
    @wait_count = 18
    # 移至步骤 5
    @phase4_step = 5
  end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (主回合步骤 5 : 显示伤害)
  #--------------------------------------------------------------------------
  def update_phase4_step5
    # 刷新状态窗口
    @status_window.refresh
    # 显示伤害
    for target in @target_battlers
      if target.damage != nil
        target.damage_pop = false
      end
    end
    # 隐藏帮助窗口
    @help_window.visible = false
    # 移至步骤 6
    @phase4_step = 6
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (主回合步骤 6 : 刷新)
  #--------------------------------------------------------------------------
  def update_phase4_step6
    # 清除强制行动对像的战斗者
    $game_temp.forcing_battler = nil
    # 公共事件 ID 有效的情况下
    if @common_event_id > 0
      # 设置事件
      common_event = $data_common_events[@common_event_id]
      $game_system.battle_interpreter.setup(common_event.list, 0)
    end
    # 移至步骤 1
    @phase4_step = 1
  end
end
