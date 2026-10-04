#==============================================================================
# ■ Scene_Battle (分割定义 2)
#------------------------------------------------------------------------------
# 　处理战斗画面的类。
#==============================================================================

class Scene_Battle
  #--------------------------------------------------------------------------
  # ● 开始自由战斗回合
  #--------------------------------------------------------------------------
  def start_phase1
    # 转移到回合 1
    @phase = 1
    # 清除全体同伴的行动
    $game_party.clear_actions
    # 设置战斗事件
    setup_battle_event
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (自由战斗回合)
  #--------------------------------------------------------------------------
  def update_phase1
    # 胜败判定
    if judge
      # 胜利或者失败的情况下 : 过程结束
      return
    end
    # 直接开始角色命令
    start_phase3
  end
  #--------------------------------------------------------------------------
  # ● 开始同伴命令回合
  #--------------------------------------------------------------------------
  def start_phase2
    # 转移到回合 2
    @phase = 2
    # 设置角色为非选择状态
    @actor_index = -1
    @active_battler = nil
    # 无效化角色指令窗口
    @actor_command_window.active = false
    @actor_command_window.visible = false
    # 清除主回合标志
    $game_temp.battle_main_phase = false
    # 清除全体同伴的行动
    $game_party.clear_actions
    # 不能输入命令的情况下
    unless $game_party.inputable?
      # 开始主回合
      start_phase4
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (同伴命令回合)
  #--------------------------------------------------------------------------
  def update_phase2
    return
  end
  #--------------------------------------------------------------------------
  # ● 画面更新 (同伴指令回合 : 逃跑)
  #--------------------------------------------------------------------------
  def update_phase2_escape
    # 计算敌人速度的平均值
    enemies_agi = 0
    enemies_number = 0
    for enemy in $game_troop.enemies
      if enemy.exist?
        enemies_agi += enemy.agi
        enemies_number += 1
      end
    end
    if enemies_number > 0
      enemies_agi /= enemies_number
    end
    # 计算角色速度的平均值
    actors_agi = 0
    actors_number = 0
    for actor in $game_party.actors
      if actor.exist?
        actors_agi += actor.agi
        actors_number += 1
      end
    end
    if actors_number > 0
      actors_agi /= actors_number
    end
    # 逃跑成功判定
    success = rand(100) < [40 * actors_agi / enemies_agi,80].min
    # 成功逃跑的情况下
    if success
      # 演奏逃跑 SE
      @help_window.visible=true
      @help_window.contents.clear
      @help_window.draw_words("哼，哪里逃！")
      for i in 0..40
        Graphics.update
      end
      @help_window.visible=false
      $game_system.se_play($data_system.escape_se)
      # 还原为战斗开始前的 BGM
      $game_system.bgm_play($game_temp.map_bgm)
      # 战斗结束
      battle_end(1)
    # 逃跑失败的情况下
    else
      # 清除全体同伴的行动
      $game_party.clear_actions
      @actor_command_window.active = false
      @actor_command_window.visible = false
      @help_window.visible=true
      @help_window.contents.clear
      @help_window.draw_words("你转身想溜,被"+
                           $game_troop.enemies[0].name+"一把抓住：想跑？没门儿！")
      for i in 0..40
        Graphics.update
      end
      @help_window.visible=false
      # 开始主回合
      start_phase4
    end
  end
  #--------------------------------------------------------------------------
  # ● 开始结束战斗回合
  #--------------------------------------------------------------------------
  def start_phase5
    # 转移到回合 5
    @phase = 5
    # 演奏战斗结束 ME
    $game_system.me_play($game_system.battle_end_me)
    # 还原为战斗开始前的 BGM
    $game_system.bgm_play($game_temp.map_bgm)
    @ene_id=$game_troop.enemies[0].id
    unless (@ene_id>125 and @ene_id<136) or (@ene_id>139 and @ene_id<142)
      @help_window.visible=true
      @help_window.contents.clear
      @help_window.y=0
      @help_window.height=64
      @help_window.draw_words($game_actors[1].name+"这一刀是劈还是不劈呢？")
      @yesno.active=true
      @yesno.visible=true
      @yesno.index=1
      @yesno.z=1000
      loop do
        # 刷新游戏画面
        Graphics.update
        # 刷新输入信息
        @yesno.update
        Input.update
        if Input.trigger?(Input::B)
          $game_system.se_play($data_system.buzzer_se)
        else
          if Input.trigger?(Input::C)
            @help_window.contents.clear
            @help_window.height=128
            @help_window.z=1000
            #杀头
            if @yesno.index==0
              $game_switches[95]=true
              dead_words
            else
              $game_switches[95]=false
              @help_window.draw_words("..............")
            end
            $game_system.se_play($data_system.decision_se)
            @yesno.visible=false
            @help_window.visible=true
            for i in 1..80
              Graphics.update
            end
            @help_window.visible=false
            @yesno.active=false
            break
          end
        end
      end
      # 初始化 EXP、金钱、宝物
      gold = 0
      # 循环
      enemy=$game_troop.enemies[0]
      # 敌人不是隐藏状态的情况下
      unless enemy.hidden
        # 获得 EXP、增加金钱
        gold += enemy.gold
      end
      # 获得金钱
      gold=[gold,50001].min
      $game_party.gain_gold(gold)
      # 生成战斗结果窗口
      @result_window = Window_BattleResult.new(gold, $trea1,$trea2,$trea3,$trea4)
      # 设置等待计数
      Audio.se_play("Audio/SE/Item3.ogg")
    end
    @phase5_wait_count = 10
  end
  #--------------------------------------------------------------------------
  # ● 死亡对话
  #--------------------------------------------------------------------------
  def dead_words
    i=rand(5)
    case i
    when 0
      d="二十年后又是一条好汉！"
    when 1
      d="有的人活着，他已经死了，有……哎，我还没说完……"
    when 2
      d="我会在地狱里等着你的。"
    when 3
      d="啊-----！"
    when 4
      d="可恶！我怎么会死呢。"
    end
    @help_window.draw_words(d)
  end
  #--------------------------------------------------------------------------
  # ● 画面更新 (结束战斗回合)
  #--------------------------------------------------------------------------
  def update_phase5
    # 等待计数大于 0 的情况下
    if @phase5_wait_count > 0
      # 减少等待计数
      @phase5_wait_count -= 1
      # 等待计数为 0 的情况下
      if @phase5_wait_count == 0
        # 显示结果窗口
        @result_window.visible = true if @result_window !=nil
        # 清除主回合标志
        $game_temp.battle_main_phase = false
        # 刷新状态窗口
        @status_window.refresh
      end
      return
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      # 战斗结束
      battle_end(0)
    end
  end
end
