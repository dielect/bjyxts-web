#==============================================================================
# ■ 装备特效（构建时紧接江湖奇遇载入，装备本身写在 src/game/mods/*.rb）
#------------------------------------------------------------------------------
#  原版的武器只有攻击力和属性加成，防具只有防御和加成。这里给装备登记“特效”，
#  只对玩家生效（NPC 拿着同一件兵器不触发）。
#
#    WebGear.effect :weapon, 35, :drain, ratio: 0.15          # 饮血
#    WebGear.effect :armor,  36, :reflect, ratio: 0.2         # 反震
#
#  武器特效（普通攻击打中时）：
#    :crit    几率 chance% 多打 ratio 倍伤害              { chance:, ratio:, name: }
#    :drain   回复伤害 ratio 的气血                        { ratio:, name: }
#    :poison  几率 chance% 让对方中毒 turns 回合：对方每次行动前失血（最大气血的 4%，至少 10，不致死）
#    :stun    几率 chance% 定住对方（木鸡3，挨打时可能醒）
#  防具特效：
#    :reflect 被普通攻击打中时，把伤害的 ratio 反弹给对方（不致死）
#    :guard   每场战斗一次：气血将要归零时保住 1 点
#    :regen   自己每次行动前回复最大气血的 pct%
#  每件装备只登记一个特效；描述里自己写上【特效名】，玩家在物品栏里能看到。
#  回归测试：node tools/encounter-test.mjs（含装备特效部分）
#==============================================================================
module WebGear
  WEAPON_EFFECTS = %i[crit drain poison stun]
  ARMOR_EFFECTS  = %i[reflect guard regen]

  @weapons = {}
  @armors  = {}

  class << self
    attr_reader :weapons, :armors

    def effect(kind, id, type, **opts)
      table, allowed = kind == :weapon ? [@weapons, WEAPON_EFFECTS] : [@armors, ARMOR_EFFECTS]
      raise ArgumentError, "WebGear #{kind} #{id}：特效应是 #{allowed.join('、')}" unless allowed.include?(type)
      raise ArgumentError, "WebGear #{kind} #{id}：重复登记" if table[id]
      table[id] = opts.merge(type: type)
    end

    def actor
      $game_actors[1]
    end

    def weapon_effect
      @weapons[actor.weapon_id]
    end

    def armor_effects(type)
      a = actor
      [a.armor1_id, a.armor2_id, a.armor3_id, a.armor4_id].map { |i| @armors[i] }.compact.select { |e| e[:type] == type }
    end

    def battle_start
      @guard_used = false
    end

    def append(note)
      $defend_text = "#{$defend_text}#{note}" if note
    end

    # ---- 普通攻击之后
    def after_attack(attacker, target)
      return unless target.damage.is_a?(Integer) && target.damage > 0
      if attacker.is_a?(Game_Actor) && target.is_a?(Game_Enemy)
        append(weapon_hit(attacker, target))
      elsif attacker.is_a?(Game_Enemy) && target.is_a?(Game_Actor)
        append(reflect(attacker, target))
        append(guard(target))
      end
    end

    def weapon_hit(attacker, target)
      e = weapon_effect or return nil
      case e[:type]
      when :crit
        return nil unless rand(100) < e[:chance]
        extra = (target.damage * e[:ratio]).to_i
        return nil if extra <= 0
        target.hp -= extra
        target.damage += extra
        "（#{e[:name]}）"
      when :drain
        heal = [(target.damage * e[:ratio]).to_i, attacker.maxhp - attacker.hp].min
        return nil if heal <= 0
        attacker.hp += heal
        "（#{e[:name]}：回复#{heal}点气血）"
      when :poison
        return nil unless target.hp > 0 && rand(100) < e[:chance]
        target.instance_variable_set(:@gear_poison, e[:turns])
        "（#{e[:name]}：#{target.name}中毒了）"
      when :stun
        return nil unless target.hp > 0 && rand(100) < e[:chance]
        target.add_state(1)
        "（#{e[:name]}：#{target.name}动弹不得！）"
      end
    end

    def reflect(attacker, target)
      e = armor_effects(:reflect)[0] or return nil
      back = [(target.damage * e[:ratio]).to_i, attacker.hp - 1].min
      return nil if back <= 0
      attacker.hp -= back
      "（#{e[:name]}：反震#{back}点）"
    end

    # 绝招打中后也要检查（skill_effect 里调用）
    def guard(target)
      return nil unless target.is_a?(Game_Actor) && target.hp <= 0 && !@guard_used
      e = armor_effects(:guard)[0] or return nil
      @guard_used = true
      target.hp = 1
      "（#{e[:name]}：护住了心脉，勉强撑住！）"
    end

    # ---- 行动前：回春、中毒
    def before_action(battler, window)
      if battler.is_a?(Game_Actor)
        e = armor_effects(:regen)[0]
        return unless e && battler.hp > 0 && battler.hp < battler.maxhp
        heal = [[battler.maxhp * e[:pct] / 100, 1].max, battler.maxhp - battler.hp].min
        battler.hp += heal
        show(window, "#{e[:name]}：一股暖意流遍全身，回复#{heal}点气血")
      else
        left = battler.instance_variable_get(:@gear_poison).to_i
        return if left <= 0 || battler.hp <= 0
        battler.instance_variable_set(:@gear_poison, left - 1)
        dmg = [[battler.maxhp * 4 / 100, 10].max, battler.hp - 1].min
        return if dmg <= 0
        battler.hp -= dmg
        show(window, "#{battler.name}毒性发作，脸色发青，气血损失#{dmg}点")
      end
    end

    def show(window, text)
      return unless window
      window.draw_words(text)
      30.times { Graphics.update }
    end
  end
end

class Game_Battler
  alias __gear_attack_effect attack_effect
  def attack_effect(attacker, s_atk1, s_atk2, s_atk3)
    r = __gear_attack_effect(attacker, s_atk1, s_atk2, s_atk3)
    WebGear.after_attack(attacker, self)
    r
  end

  alias __gear_skill_effect skill_effect
  def skill_effect(user, skill, window)
    r = __gear_skill_effect(user, skill, window)
    WebGear.append(WebGear.guard(self))
    r
  end
end

class Scene_Battle
  alias __gear_start_phase1 start_phase1
  def start_phase1
    WebGear.battle_start
    __gear_start_phase1
  end

  alias __gear_update_phase4_step2 update_phase4_step2
  def update_phase4_step2
    WebGear.before_action(@active_battler, @help_window) if @active_battler
    __gear_update_phase4_step2
  end
end
