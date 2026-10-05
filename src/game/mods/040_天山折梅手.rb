#==============================================================================
# ■ 逍遥派武功：天山折梅手（拳脚 61，基础 40 基本拳脚）
#------------------------------------------------------------------------------
#  “天下任何招数武功，都能自行化在这六路折梅手之中。”——与小无相功是一套：
#  小无相功偷别人的绝招，折梅手把别派的招式化进平时的出手。
#
#  招式：自身 8 招，0～120 级逐步解锁；每一招命中后带一个小特效（见 MOVES）。
#  化入：启用小无相功时，记下的绝招所属的拳脚武功（太极拳、雪影擒拿手、八卦游身掌……）的招式
#        也会混进出手，受折梅手等级限制（与原版招式按等级解锁的规则相同）。
#  越博越强：小无相功每记下一招，折梅手所有招式威力 +8%。
#  境界：30 级“折梅”：普通攻击有 等级 ÷ 10 %（最多 30%）几率追加一击（威力减半）；
#        80 级绝招“生死符”：种下生死符，对方每次行动前发作，损失气血（不致死），并有几率定身。
#  获取：写在无相残卷里（逍遥派秘籍 6），与小无相功一起学，最高 150 级。
#
#  编号：武功 / 变量 61（学习点数 121）；绝招 29 生死符
#==============================================================================
WebSkill.add_skill 61, WebSkill::FIST, 40
WebMod.variable_name 61, '天山折梅手'
WebSkill.study 7, 6, [[78, 150], [61, 150]]      # 无相残卷：小无相功 + 天山折梅手（覆盖 030 里只有小无相功的列表）

module WebZhemei
  SKILL = 61

  # [最低等级, 描述, 威力, 命中修正, 伤害类型, 特效]
  # 伤害类型：3 钝击，4 内劲掌力，5 抓伤（见 010 Data_Hit）
  MOVES = [
    [0,   '%{user}使出天山折梅手第一路「折梅」，五指轻拂，似折梅枝，拂向%{objector}的%{sp}', 25, 30, 4, :xieli],
    [0,   '%{user}一招「拂柳」，手掌斜斜拂出，掌风如柳，掠向%{objector}的%{sp}', 25, 30, 4, :fuxue],
    [10,  '%{user}一招「扣腕」，反手一扣一拿，直取%{objector}的手腕', 35, 32, 5, :qinna],
    [20,  '%{user}掌缘斜切，一招「穿云」，直穿%{objector}中宫，取其%{sp}', 45, 30, 4, :pofang],
    [35,  '%{user}身随掌走，一招「踏雪」，脚下不停，向%{objector}的%{sp}连拍三掌', 60, 30, 3, :taxue],
    [50,  '%{user}六掌连环，一招「六阳」，掌心隐隐发热，按向%{objector}的%{sp}', 80, 32, 4, :fenyuan],
    [80,  '%{user}一手化作六手，一招「梅影重重」，虚虚实实罩向%{objector}', 100, 34, 4, :meiying],
    [120, '%{user}掌力一吐，一招「天山雪落」，寒气彻骨，如雪花漫天压向%{objector}', 130, 35, 4, :hanqi],
  ]

  module_function

  def level
    $game_variables[SKILL].to_i
  end

  # 越博越强：小无相功记下的招数
  def bonus
    1.0 + 0.08 * WebXwx.memory.size
  end

  # 化入：记下的绝招所属的拳脚武功（使用条件里“启用拳脚”那一项）
  def borrowed_families
    WebXwx.memory.flat_map { |pid| WebSkill.requirements_of(pid).select { |v, _| v == 29 }.map { |_, sk| sk } }.uniq - [SKILL]
  end

  def pool(own, original)
    list = own.dup
    if WebXwx.active? && original
      borrowed_families.each { |sk| list.concat((original[sk] || []).map(&:dup)) }
    end
    k = bonus
    list.map { |m| m = m.dup; m[2] = (m[2] * k).round; m }
  end

  # ---- 命中后的招式特效（只对玩家出手生效）
  def after_hit(attacker, target, move)
    return unless attacker.is_a?(Game_Actor) && target.is_a?(Game_Enemy)
    return unless target.damage.is_a?(Integer) && target.damage > 0
    effect = move && move[5]
    note = effect ? apply(effect, attacker, target) : nil
    note = [note, chase(attacker, target)].compact.join if $game_variables[29] == SKILL
    $defend_text = "#{$defend_text}#{note}" if note && !note.empty?
  end

  def extra_damage(target, ratio)
    extra = (target.damage * ratio).to_i
    return 0 if extra <= 0
    target.hp -= extra
    target.damage += extra
    extra
  end

  def apply(effect, attacker, target)
    lv = level
    case effect
    when :xieli                                      # 卸力：对方下一招伤害 -20%
      target.instance_variable_set(:@zm_soften, true)
      '（卸力：对方下一招力道减弱）'
    when :fuxue                                      # 拂穴：对方闪避下降
      $npc_data[25] = $npc_data[25].to_i - [lv / 5, 5].max
      '（拂穴：对方身法迟滞）'
    when :qinna                                      # 擒拿：几率夺下兵器（同原版落英缤纷，兵器归你）
      w = $npc_data[9].to_i
      if w != 0 && rand(100) < [10 + lv / 10, 40].min
        $game_party.gain_weapon(w, 1)
        $npc_data[9] = 0
        "（擒拿：夺下了对方的#{$data_weapons[w].name}！）"
      end
    when :pofang                                     # 破防：这一下多 30% 伤害
      extra_damage(target, 0.3) > 0 ? '（破防）' : nil
    when :taxue                                      # 连拍：三掌合计约 1.6 倍
      extra_damage(target, 0.6) > 0 ? '（连拍三掌）' : nil
    when :fenyuan                                    # 焚元：烧掉对方内力
      target.sp = [target.sp - target.damage / 2, 0].max
      '（焚元：对方内力受损）'
    when :meiying                                    # 虚招：对方下一招必定落空
      target.instance_variable_set(:@zm_feint, true)
      '（虚招：对方下一招将扑空）'
    when :hanqi                                      # 寒气：几率冻住（木鸡3）
      if rand(100) < 25
        target.add_state(1)
        '（寒气：对方被冻住了！）'
      end
    end
  end

  # 30 级“折梅”：几率追加一击，威力为这一击的一半
  def chase(attacker, target)
    lv = level
    return nil if lv < 30 || target.hp <= 0 || rand(100) >= [lv / 10, 30].min
    extra_damage(target, 0.5) > 0 ? '（折梅：顺势又是一掌）' : nil
  end

  # ---- 对方出手时：卸力减伤、虚招落空
  def before_enemy_attack(attacker, target)
    return false unless attacker.is_a?(Game_Enemy) && attacker.instance_variable_get(:@zm_feint)
    attacker.instance_variable_set(:@zm_feint, false)
    target.damage = 'Miss'
    $defend_text = "那不过是一道梅影，#{attacker.name}扑了个空！"
    true
  end

  def after_enemy_attack(attacker, target)
    return unless attacker.is_a?(Game_Enemy) && attacker.instance_variable_get(:@zm_soften)
    attacker.instance_variable_set(:@zm_soften, false)
    return unless target.damage.is_a?(Integer) && target.damage > 0
    cut = target.damage / 5
    target.hp += cut
    target.damage -= cut
  end

  # ---- 生死符：对方每次行动前发作
  def plant(user, target)
    turns = 3 + level / 40
    target.instance_variable_set(:@zm_shengsi, turns)
  end

  def flare(battler, window)
    left = battler.instance_variable_get(:@zm_shengsi).to_i
    return if left <= 0 || battler.hp <= 0
    battler.instance_variable_set(:@zm_shengsi, left - 1)
    dmg = [[level, 30].max, battler.hp - 1].min      # 生死符折磨人，但不致死
    battler.hp -= dmg if dmg > 0
    stun = rand(100) < 30
    battler.add_state(1) if stun
    text = "#{battler.name}体内的生死符发作，奇痒难当，气血损失#{[dmg, 0].max}点"
    text += '，浑身发颤，动弹不得！' if stun
    window.draw_words(text)
    40.times { Graphics.update }
  end
end

#--------------------------------------------------------------------------
# 招式与绝招数据
#--------------------------------------------------------------------------
WebSkill.attack_words 61, WebZhemei::MOVES

WebMod.skill 29, like: 20, name: '生死符', sp_cost: 300, description: '逍遥派绝技，化水为冰，种入敌身'
WebSkill.perform 61, 29
WebSkill.requirement 29, [[29, 61], [61, 80], [40, 80]]   # 启用折梅手，折梅手、基本拳脚都到 80 级
WebSkill.skill_words 29, [
  '%{user}掌心运起寒气，化水为冰，一片薄冰无声无息地打向%{objector}……',
  '%{objector}只觉身上某处一凉，随即奇痒难当——生死符已然种下！',
  '%{objector}内力深厚，将那片寒冰震了出去。',
]

#--------------------------------------------------------------------------
# 接入点
#--------------------------------------------------------------------------
module WebSkill
  class << self
    alias __zm_attack_words_for attack_words_for
    def attack_words_for(skill_id, user, objector, weapon, sp, original = nil)
      list = __zm_attack_words_for(skill_id, user, objector, weapon, sp, original)
      skill_id == WebZhemei::SKILL && list ? WebZhemei.pool(list, original) : list
    end
  end
end

class Game_Battler
  alias __zm_attack_effect attack_effect
  def attack_effect(attacker, s_atk1, s_atk2, s_atk3)
    move = $web_atk_move
    $web_atk_move = nil
    return false if WebZhemei.before_enemy_attack(attacker, self)
    r = __zm_attack_effect(attacker, s_atk1, s_atk2, s_atk3)
    WebZhemei.after_hit(attacker, self, move)
    WebZhemei.after_enemy_attack(attacker, self)
    r
  end

  alias __zm_skill_effect skill_effect
  def skill_effect(user, skill, window)
    r = __zm_skill_effect(user, skill, window)
    if skill.id == 29 && user.is_a?(Game_Actor) != is_a?(Game_Actor)        # 打向对方时
      words = get_skill_words(user, self, 29)
      if hit_result?(user, self)
        WebZhemei.plant(user, self)
        $defend_text = words[1]
      else
        $defend_text = words[2]
      end
      self.damage = 0
    end
    r
  end
end

class Scene_Battle
  alias __zm_update_phase4_step2 update_phase4_step2
  def update_phase4_step2
    WebZhemei.flare(@active_battler, @help_window) if @active_battler
    __zm_update_phase4_step2
  end
end
