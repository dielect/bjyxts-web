#==============================================================================
# ■ 逍遥派武功：小无相功（内功 78）
#------------------------------------------------------------------------------
#  无相：本身没有招式，却能催动天下各派绝招。
#
#  观招：启用小无相功（内功栏）时，对手在战斗中使出任何绝招，你都会默记下来（永久保存）。
#  化用：启用时，记下的绝招出现在你的绝招列表里，不看原版的使用条件（不需要对方门派的武功），
#        若本身已满足原版条件（例如天下无狗不要求内功），就按原版规则使用、原价扣内力；
#        只看内力。威力按“模仿度”：使用时把这招相关武功的等级临时视为“小无相功等级 × 模仿度”。
#  现学现用：本场战斗里对手刚使出的绝招，可以免费回敬一次（不耗内力）。
#        每场可免费回敬的次数 = 1 + 等级 ÷ 100。内力不够时也能用：使用时临时借足内力。
#  模仿度 = 50% + 等级 ÷ 10 %，最高 100%。平时化用耗内力 = 原耗 × 模仿度。
#  记忆上限 = 1 + 等级 ÷ 50 招，记满时选择忘掉哪一招（或不记这一招）。
#  境界：100 级“无相反照”：对手用你记得的绝招打你时，有 等级 ÷ 10 %（最多 50%）几率被化解；
#        200 级“万法归宗”：化用的内力消耗减半。
#  打坐时内力修为的上限由启用内功的等级决定（原版规则），所以练小无相功本身就在扩充内力。
#
#  编号：武功 / 变量 78（学习点数 138）；变量 241～252 依次存记下的绝招编号（0 为空）
#==============================================================================
WebSkill.add_skill 78, WebSkill::INNER, 45
WebMod.variable_name 78, '小无相功'

module WebXwx
  SKILL   = 78
  SLOTS   = (241..252).to_a
  EXCLUDE = [26, 27]               # 左右互搏是系统内部用的绝招，不观、不化用

  module_function

  def level
    $game_variables[SKILL].to_i
  end

  def active?
    level > 0 && $game_variables[32] == SKILL
  end

  # 模仿度：50% 起，每 10 级 +1%，最高 100%
  def mimic
    [0.5 + level / 1000.0, 1.0].min
  end

  def capacity
    [1 + level / 50, SLOTS.size].min
  end

  def memory
    SLOTS.map { |v| $game_variables[v].to_i }.reject(&:zero?)
  end

  def memory=(list)
    SLOTS.each_with_index { |v, i| $game_variables[v] = list[i] || 0 }
  end

  def remember?(id)
    memory.include?(id)
  end

  # ---- 本场战斗的状态（不存档）
  def battle_start
    @seen = []
    @free_ids = []
    @free_left = 1 + level / 100
  end

  def seen
    @seen ||= []
  end

  def free?(id)
    active? && (@free_ids || []).include?(id) && (@free_left || 0) > 0
  end

  def use_free(id)
    @free_ids.delete(id)
    @free_left -= 1
  end

  # 是否满足原版的使用条件（与 103 skill_check 相同的判断）。满足时按原版规则用，不算化用
  def meets_requirements?(id)
    reqs = WebSkill.requirements_of(id)
    !reqs.empty? && reqs.all? { |v, val| v < 38 ? $game_variables[v] == val : $game_variables[v] >= val }
  end

  # 化用：启用小无相功，记得或本场看过这一招，且不满足原版的使用条件
  def borrowed?(battler, id)
    battler.is_a?(Game_Actor) && active? && (remember?(id) || seen.include?(id)) && !meets_requirements?(id)
  end

  def name_of(id)
    $data_skills[id] ? $data_skills[id].name : "绝招#{id}"
  end

  def say(window, text, frames = 40)
    window.draw_words(text)
    frames.times { Graphics.update }
  end

  # ---- 观招：对手使出绝招之后调用
  def observe(battler, skill, window)
    return unless battler.is_a?(Game_Enemy) && active?
    id = skill.id
    return if EXCLUDE.include?(id)
    unless seen.include?(id)
      seen << id
      @free_ids << id
    end
    if remember?(id)
      say(window, "你以小无相功看破了「#{name_of(id)}」，可以原样奉还！")
    elsif memory.size < capacity
      self.memory = memory + [id]
      say(window, "你以小无相功默记下了「#{name_of(id)}」的运功法门！")
    else
      forget = choose_forget(id, window)
      if forget
        self.memory = memory - [forget] + [id]
        say(window, "你忘掉了「#{name_of(forget)}」，默记下了「#{name_of(id)}」的运功法门！")
      else
        say(window, "你看破了「#{name_of(id)}」，但没有记下它。本场仍可原样奉还。")
      end
    end
  end

  # 记满时让玩家选择忘掉哪一招；返回要忘掉的绝招编号，nil 表示不记新招
  def choose_forget(id, window)
    window.draw_words("小无相功只能记 #{capacity} 招，忘掉哪一招来记「#{name_of(id)}」？")
    list = memory
    cmd = Window_Command.new(260, list.map { |k| name_of(k) } + ['不记这一招'])
    cmd.x = 640 - 260 - 16
    cmd.y = [352 - cmd.height, 0].max
    cmd.z = 1000
    result = nil
    loop do
      Graphics.update
      Input.update
      cmd.update
      if Input.trigger?(Input::C)
        $game_system.se_play($data_system.decision_se)
        result = cmd.index < list.size ? list[cmd.index] : nil
        break
      elsif Input.trigger?(Input::B)
        $game_system.se_play($data_system.cancel_se)
        break
      end
    end
    cmd.dispose
    result
  end

  # ---- 化用：使用借来的绝招时，临时把相关武功提到“小无相功等级 × 模仿度”，并借足内力
  def boost(user, skill)
    return nil unless borrowed?(user, skill.id)
    eff = [(level * mimic).to_i, 1].max
    saved = { vars: {}, sp_delta: 0 }
    WebSkill.requirements_of(skill.id).each do |v, val|
      saved[:vars][v] ||= $game_variables[v]
      $game_variables[v] = v < 38 ? val : [$game_variables[v], eff].max
    end
    need = (skill.sp_cost * mimic).round
    if user.sp < need
      saved[:sp_delta] = need - user.sp
      user.instance_variable_set(:@sp, need)       # 绕过内力上限，借足内力（原版效果按内力比拼）
    end
    saved
  end

  def restore(user, saved)
    saved[:vars].each { |v, val| $game_variables[v] = val }
    user.instance_variable_set(:@sp, [user.sp - saved[:sp_delta], 0].max) if saved[:sp_delta] > 0
  end

  # ---- 100 级 无相反照：对手用你记得的绝招打你时，有几率化解
  def reflect?(user, target, skill)
    user.is_a?(Game_Enemy) && target.is_a?(Game_Actor) && active? && level >= 100 &&
      remember?(skill.id) && rand(100) < [level / 10, 50].min
  end

  def reflect(user, target, skill, window)
    words = get_skill_words(user, target, skill.id)
    say(window, words[0], 21) if words
    $dis_id2 = 100
    target.damage = 'Miss'
    $defend_text = "你以小无相功使出同一招「#{skill.name}」，将这一招化解于无形！"
    true
  end
end

#--------------------------------------------------------------------------
# 接入点
#--------------------------------------------------------------------------
module WebSkill
  class << self
    alias __xwx_sp_cost sp_cost
    def sp_cost(battler, skill_id)
      c = __xwx_sp_cost(battler, skill_id)
      return c unless WebXwx.borrowed?(battler, skill_id)
      return 0 if WebXwx.free?(skill_id)
      c = (c * WebXwx.mimic).round
      c /= 2 if WebXwx.level >= 200                 # 万法归宗
      c
    end

    alias __xwx_consume_sp consume_sp
    def consume_sp(battler, skill_id)
      if WebXwx.borrowed?(battler, skill_id) && WebXwx.free?(skill_id)
        WebXwx.use_free(skill_id)
        return 0
      end
      __xwx_consume_sp(battler, skill_id)
    end

    alias __xwx_requirements_for requirements_for
    def requirements_for(id, original)
      return [] if WebXwx.borrowed?($game_party.actors[0], id)
      __xwx_requirements_for(id, original)
    end
  end
end

# 绝招列表：本身学会的 + 启用小无相功时记下的和本场看过的
alias __xwx_study_skill study_skill
def study_skill
  __xwx_study_skill
  actor = $game_party.actors[0]
  (WebXwx.memory | WebXwx.seen).each { |id| actor.learn_skill(id) } if WebXwx.active?
end

class Game_Battler
  alias __xwx_skill_effect skill_effect
  def skill_effect(user, skill, window)
    return WebXwx.reflect(user, self, skill, window) if WebXwx.reflect?(user, self, skill)
    saved = WebXwx.boost(user, skill)
    __xwx_skill_effect(user, skill, window)
  ensure
    WebXwx.restore(user, saved) if saved
  end
end

class Scene_Battle
  alias __xwx_start_phase1 start_phase1
  def start_phase1
    WebXwx.battle_start
    __xwx_start_phase1
  end

  alias __xwx_make_skill_action_result make_skill_action_result
  def make_skill_action_result
    __xwx_make_skill_action_result
    # 内力不足没放出来时，原版把步骤退回 1
    WebXwx.observe(@active_battler, @skill, @help_window) if @skill && @phase4_step != 1
  end
end
