#==============================================================================
# ■ 武功注册表（构建时插在 117 - Main 之前，晚于全部原版脚本载入）
#------------------------------------------------------------------------------
#  原版把“哪些编号是拳脚 / 兵刃 / 轻功……”“哪些武器是刀 / 剑……”写死在多个脚本里，
#  而且彼此不一致。这里把它们收拢成几张表，并覆盖原版的判断函数，
#  以后新增武功、武器、绝招只改这里的表。
#
#  接管的原版判断：
#    004 weapon_skill_base / get_all_skill_base / get_weapon_base_skill / weapon_matching_skill?
#    006 study_skill
#    029 Game_Enemy#npc_weapon? / npc_base_skill
#    057 Window_Skill#refresh / update_help
#    以及 tools/build.py 里 PATCHES 改写的几处区间与“编号 + 60”
#      （099 Scene_Practice、113 Scene_Study、013 Data_NPC、026 Game_Battler 4）
#
#  与原版的差异（有意修正）：
#    - 70 凌波微步登记为轻功，84 打狗棒法登记为兵刃（基础 39 基本棍法）；
#      原版两者都无法显示和练习。原版没有途径学到它们，所以不影响老存档。
#    - 61 号不再被当作拳脚（原版练功接受、窗口却不列；它没有名字，是空位）。
#    - 没登记类型的武器不再被判定为“匹配”任何兵刃武功（原版会因此在练功时报错）。
#
#  回归测试：node tools/skill-baseline-test.mjs
#==============================================================================
module WebSkill
  # 技能窗口的分类，同时也是“当前启用”变量的偏移：变量 29 + 分类
  FIST, WEAPON, MOVE, INNER, PARRY, LORE = 0, 1, 2, 3, 4, 5

  # 武功表：编号 => [分类, 基础武功]。基础武功本身填 nil。
  # 按技能窗口的显示顺序排列（保持原版顺序，新增的排在各分类末尾）。
  # 空位（未登记、不显示、不能练）：61～63 拳脚，71 轻功，78～79 内功，90 兵刃。
  # 新武功编号不能超过 90：学习点数存在变量“编号 + 60”，91 起会和属性加成、年龄、道德撞号，
  # 要用 91 以上，先在 POINT_VARS 里给它指定点数变量。
  SKILLS = {
    40 => [FIST, nil],
    53 => [FIST, 40], 54 => [FIST, 40], 55 => [FIST, 40], 56 => [FIST, 40],
    57 => [FIST, 40], 58 => [FIST, 40], 59 => [FIST, 40], 60 => [FIST, 40],

    41 => [WEAPON, nil], 42 => [WEAPON, nil], 43 => [WEAPON, nil], 44 => [WEAPON, nil],
    39 => [WEAPON, nil],
    85 => [WEAPON, 41], 86 => [WEAPON, 41], 87 => [WEAPON, 41],
    88 => [WEAPON, 44], 89 => [WEAPON, 43],
    80 => [WEAPON, 42], 81 => [WEAPON, 42], 82 => [WEAPON, 42], 83 => [WEAPON, 42],
    84 => [WEAPON, 39],                       # 打狗棒法（原版未完成）

    46 => [MOVE, nil],
    64 => [MOVE, 46], 65 => [MOVE, 46], 66 => [MOVE, 46], 67 => [MOVE, 46],
    68 => [MOVE, 46], 69 => [MOVE, 46],
    70 => [MOVE, 46],                         # 凌波微步（原版漏列）

    45 => [INNER, nil],
    72 => [INNER, 45], 73 => [INNER, 45], 74 => [INNER, 45], 75 => [INNER, 45],
    76 => [INNER, 45], 77 => [INNER, 45],

    47 => [PARRY, nil],

    48 => [LORE, nil], 49 => [LORE, nil], 50 => [LORE, nil], 51 => [LORE, nil], 52 => [LORE, nil],
  }

  # 学习点数变量。没列出的用“编号 + 60”（原版规则）。
  POINT_VARS = {}

  # 武器类型：基础武功 => 武器编号。新武器必须在这里登记，否则装备后战斗会出错。
  WEAPON_TYPES = {
    42 => [1, 28, 29] + (8..14).to_a,           # 刀
    41 => [2, 3, 4, 6, 7, 30] + (15..20).to_a,  # 剑
    44 => [5] + (21..24).to_a,                  # 鞭
    43 => (25..27).to_a,                        # 杖
  }

  # 启用武功后自动学会的绝招：武功编号 => [绝招编号, ...]
  # 写成 [绝招编号, 拳脚编号] 表示还要求当前启用的拳脚（变量 29）是该编号。
  # 兵刃武功的绝招只在装备了对应类型的武器时学会。
  PERFORMS = {
    73 => [6], 74 => [9, 10], 75 => [12, 13], 77 => [25],
    53 => [3], 54 => [2], 58 => [19, 16, 17, 18], 59 => [23],
    80 => [[4, 53], [5, 54]], 81 => [8], 82 => [14, 15],
    85 => [21, 20, 22], 86 => [24], 88 => [7], 89 => [11],
  }

  WEAPON_OF = {}
  WEAPON_TYPES.each { |base, ids| ids.each { |w| WEAPON_OF[w] = base } }

  # 以下几张表原版没有对应的空位，由扩展内容（src/game/mods）用下面的登记函数填写。
  # 普通攻击的描述：武功编号 => [[最低等级, 文字, 威力, 命中修正, 部位类型], ...]，与 008 Data_Attack 的格式相同。
  # 文字里用 %{user}、%{objector}、%{weapon}、%{sp}（攻击部位）代替人称和兵器名。
  ATTACK_WORDS = {}
  # 绝招的描述：绝招编号 => [出招, 命中, 被化解]，与 011 Data_Skill 的格式相同，占位符同上（没有 %{sp}）
  SKILL_WORDS = {}
  DEFEND_WORDS = {}
  # 连击型绝招：绝招编号 => [出招用哪门武功的招式, 连击次数]，走 026 attack_times
  COMBOS = {}
  # 连击后的定身效果：绝招编号 => { state: 状态编号, text: 描述 }
  COMBO_STUNS = {}
  # 绝招的使用条件：绝招编号 => [[变量, 值], ...]，与 103 Scene_Battle 4 skill_check 的格式相同：
  # 变量小于 38 时要求“当前启用”等于该值（29 拳脚、30 兵刃、32 内功），否则要求等级不低于该值
  REQUIREMENTS = {}

  module_function

  # 请教 / 秘籍的武功列表：[门派, 师傅或秘籍编号] => [[武功, 最高等级], ...]
  # 原版逍遥派（门派 7）的秘籍是 1～5，新秘籍从 6 起。113 Scene_Study 在原版表里查不到时用这里的
  STUDY_LISTS = {}

  def study(school, teacher, list)
    STUDY_LISTS[[school, teacher]] = list
  end

  def study_list(school, teacher, original)
    original || STUDY_LISTS.fetch([school, teacher])
  end

  # 登记新武功：编号、分类、基础武功（技能窗口按登记顺序列在各分类末尾）。名字用 WebMod.variable_name 登记
  def add_skill(id, category, base)
    raise ArgumentError, "武功 #{id} 已登记" if SKILLS.key?(id)
    SKILLS[id] = [category, base]
  end

  # ---- 绝招的内力与使用条件（原版通过构建补丁调用这里；扩展内容可以重定义，例如 030 小无相功）
  # 显示与判断用的内力消耗（055 绝招窗口、025 skill_can_use?、102 内力不足提示）
  def sp_cost(battler, skill_id)
    $data_skills[skill_id].sp_cost
  end

  # 实际扣除的内力（103 make_skill_action_result）
  def consume_sp(battler, skill_id)
    sp_cost(battler, skill_id)
  end

  # 绝招使用条件（103 skill_check）：原版表里有就用原版的，否则查 REQUIREMENTS
  def requirements_for(id, original)
    original || REQUIREMENTS.fetch(id)
  end

  # 原版 103 Scene_Battle 4 skill_check 里的绝招使用条件表（原文照录，供扩展内容查询；判断时仍用原版的表）
  ORIGINAL_REQUIREMENTS = {
    2 => [[32, 72], [29, 54], [72, 90], [45, 90], [54, 90], [40, 90]],
    3 => [[32, 72], [29, 53], [72, 70], [45, 70], [53, 70], [40, 70]],
    4 => [[32, 72], [29, 53], [30, 80], [72, 70], [45, 70], [80, 90]],
    5 => [[32, 72], [29, 54], [30, 80], [72, 70], [45, 70], [80, 90]],
    6 => [[32, 73], [73, 60], [45, 60]],
    7 => [[32, 73], [30, 88], [73, 80], [45, 80], [88, 80], [44, 80]],
    8 => [[32, 73], [30, 81], [73, 100], [45, 100], [81, 100], [42, 100]],
    11 => [[32, 74], [30, 89], [74, 80], [45, 80], [89, 80], [43, 80]],
    9 => [[32, 74], [74, 60], [45, 60]],
    10 => [[32, 74], [74, 80], [45, 80]],
    12 => [[32, 75], [75, 60], [45, 60]],
    13 => [[32, 75], [75, 70], [45, 70]],
    14 => [[32, 75], [30, 82], [75, 60], [45, 60], [82, 60], [42, 60]],
    15 => [[32, 75], [30, 82], [75, 80], [45, 80], [82, 80], [42, 80]],
    16 => [[32, 76], [29, 58], [76, 70], [45, 70], [58, 70], [40, 70]],
    17 => [[32, 76], [29, 58], [76, 100], [45, 100], [58, 100], [40, 100]],
    18 => [[32, 76], [29, 58], [76, 120], [45, 120], [58, 120], [40, 120]],
    19 => [[32, 76], [29, 58], [76, 60], [45, 60], [58, 60], [40, 60]],
    20 => [[32, 76], [30, 85], [76, 80], [45, 80], [85, 80], [41, 80]],
    21 => [[32, 76], [30, 85], [76, 80], [45, 80], [85, 80], [41, 80]],
    22 => [[32, 76], [30, 85], [76, 120], [45, 120], [85, 120], [41, 120]],
    23 => [[32, 77], [29, 59], [77, 100], [45, 100], [59, 80], [40, 80]],
    24 => [[32, 77], [30, 86], [77, 60], [45, 60], [86, 60], [41, 60]],
    25 => [[32, 77], [77, 60], [45, 60]],
  }

  # 某绝招的使用条件（原版或扩展登记的）
  def requirements_of(id)
    ORIGINAL_REQUIREMENTS[id] || REQUIREMENTS[id] || []
  end

  # 登记武器类型：基础武功 => 武器编号
  def weapon_type(base, ids)
    (WEAPON_TYPES[base] ||= []).concat(ids)
    ids.each { |w| WEAPON_OF[w] = base }
  end

  # 登记启用武功后学会的绝招
  def perform(skill_id, *performs)
    (PERFORMS[skill_id] ||= []).concat(performs)
  end

  def attack_words(skill_id, entries)
    ATTACK_WORDS[skill_id] = entries
  end

  # 新轻功的闪避描述（%{user} 闪避者、%{objector} 出手者）；原版 009 表里没有的轻功用这里的，再没有就用基本轻功的
  def defend_words(skill_id, entries)
    DEFEND_WORDS[skill_id] = entries
  end

  def skill_words(perform_id, entries)
    SKILL_WORDS[perform_id] = entries
  end

  def requirement(perform_id, list)
    REQUIREMENTS[perform_id] = list
  end

  # stun：连击后的定身效果，{ state: 状态编号, text: '描述' }。
  #   至少一下打中、对方没倒下时，再按原版乱环诀的内力比拼（hit_result?）判定是否定住。
  #   状态用原版的“木鸡”：1 木鸡3（最多 3 回合，每次挨打 15% 机会醒来）、2 木鸡5、19 木鸡8
  def combo(perform_id, moves_of:, times:, stun: nil)
    COMBOS[perform_id] = [moves_of, times]
    COMBO_STUNS[perform_id] = stun if stun
  end

  # 025 skill_effect 在连击结束后调用
  def after_combo(perform_id, user, target, window, hp_before)
    st = COMBO_STUNS[perform_id] or return
    return unless target.hp < hp_before && target.hp > 0
    return unless target.hit_result?(user, target)
    # 先显示最后一下的结果，再显示定身（战斗流程随后会显示 $defend_text）
    window.draw_words($defend_text)
    31.times { Graphics.update }
    target.add_state(st[:state])
    objector = user.is_a?(Game_Actor) ? target.name : '你'
    $defend_text = fill(st[:text], objector: objector)
  end

  def fill(text, vars)
    text.gsub(/%\{(\w+)\}/) { vars[$1.to_sym].to_s }
  end

  # 008 draw_atk_text 在原版表里查不到时调用；查不到返回 nil（与原版行为相同）。
  # original 是原版这一次出手已填好人称的招式表（武功编号 => 招式），扩展内容可以借用别派招式（例如 040 天山折梅手）。
  # 招式第 6 项起可以附加标记（例如特效名），原版只读前 5 项，不受影响。
  def attack_words_for(skill_id, user, objector, weapon, sp, original = nil)
    list = ATTACK_WORDS[skill_id] or return nil
    vars = { user: user, objector: objector, weapon: weapon, sp: sp }
    list.map { |lv, text, *rest| [lv, fill(text, vars), *rest] }
  end

  # 009 draw_defend_text 在原版表里查不到时调用
  def defend_words_for(skill_id, user, objector)
    list = DEFEND_WORDS[skill_id] or return nil
    list.map { |text| fill(text, user: user, objector: objector) }
  end

  # 011 get_skill_words 在原版表里查不到时调用
  def skill_words_for(perform_id, user, objector, weapon)
    list = SKILL_WORDS[perform_id] or return nil
    vars = { user: user, objector: objector, weapon: weapon }
    list.map { |text| fill(text, vars) }
  end

  def category(id)
    s = SKILLS[id]
    s && s[0]
  end

  # 进阶武功对应的基础武功；基础武功本身和未登记的编号返回 nil
  def base_of(id)
    s = SKILLS[id]
    s && s[1]
  end

  def point_var(id)
    POINT_VARS[id] || id + 60
  end

  # 某分类在技能窗口里的武功（含基础武功），按显示顺序
  def in_category(cat)
    SKILLS.keys.select { |id| SKILLS[id][0] == cat }
  end

  # 某分类的进阶武功
  def advanced(cat)
    in_category(cat).select { |id| SKILLS[id][1] }
  end

  def all_ids
    SKILLS.keys.sort
  end

  # 武器编号对应的基础武功；空手或未登记返回 nil
  def weapon_base(weapon_id)
    WEAPON_OF[weapon_id]
  end
end

#--------------------------------------------------------------------------
# 004 Methods
#--------------------------------------------------------------------------
# 兵刃武功对应的基础武功
def weapon_skill_base(skill_number)
  WebSkill.category(skill_number) == WebSkill::WEAPON ? WebSkill.base_of(skill_number) : nil
end

# 拳脚、轻功、兵刃对应的基础武功（原版不含内功，保持不变）
def get_all_skill_base(skill_id)
  case WebSkill.category(skill_id)
  when WebSkill::FIST, WebSkill::MOVE then WebSkill.base_of(skill_id)
  else weapon_skill_base(skill_id)
  end
end

# 当前武器对应的基础武功
def get_weapon_base_skill
  WebSkill.weapon_base($game_party.actors[0].weapon_id)
end

# 当前武器能否配合该兵刃武功
def weapon_matching_skill?(skill_number = $game_variables[30])
  base = get_weapon_base_skill
  !base.nil? && base == weapon_skill_base(skill_number)
end

#--------------------------------------------------------------------------
# 006 Study_Skill：按当前启用的武功重建已学绝招
#--------------------------------------------------------------------------
def study_skill
  actor = $game_party.actors[0]
  actor.skills = []
  learn = lambda do |id|
    (WebSkill::PERFORMS[id] || []).each do |sk|
      if sk.is_a?(Array)
        actor.learn_skill(sk[0]) if $game_variables[29] == sk[1]
      else
        actor.learn_skill(sk)
      end
    end
  end
  learn.call($game_variables[32])
  learn.call($game_variables[31])    # 原版轻功没有绝招；扩展的轻功可以带（例如 140 攀山步的斧法）
  if actor.weapon_id == 0
    learn.call($game_variables[29])
  elsif weapon_matching_skill?
    learn.call($game_variables[30])
  end
end

#--------------------------------------------------------------------------
# 029 Game_Enemy：NPC 的武器与兵刃武功
#--------------------------------------------------------------------------
class Game_Enemy
  def npc_weapon?(id)
    base = WebSkill.weapon_base(id)
    !base.nil? && base == weapon_skill_base($npc_data[5])
  end

  def npc_base_skill(id)
    WebSkill.weapon_base(id) || 0
  end
end

#--------------------------------------------------------------------------
# 057 Window_Skill：技能窗口按注册表列出武功
#--------------------------------------------------------------------------
class Window_Skill
  def refresh
    if self.contents != nil
      self.contents.dispose
      self.contents = nil
    end
    @category = self.category
    @data = WebSkill.in_category(@category).select { |i| $game_variables[i] > 0 }
    if @category == WebSkill::PARRY
      # 招架：基本招架 + 当前启用的拳脚、兵刃（原版逻辑）
      for i in 29..30
        a = $game_variables[i]
        @data.push a if $game_variables[a] > 0
      end
    end
    @item_max = @data.size
    if @item_max > 0
      self.contents = Bitmap.new(width - 32, row_max * 32)
      for i in 0...@item_max
        draw_item(i)
      end
    end
  end

  def update_help
    id = @data[self.index]
    if id != nil
      @help_window.set_text($data_system.variables[id] + "  " +
        $game_variables[id].to_s + "/" +
        $game_variables[WebSkill.point_var(id)].to_s + "  " +
        $levels[$game_variables[id] / 5])
    else
      @help_window.set_text("")
    end
  end
end
