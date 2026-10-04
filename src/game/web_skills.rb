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

  module_function

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
