#==============================================================================
# ■ Game_Actor
#------------------------------------------------------------------------------
# 　处理角色的类。本类在 Game_Actors 类 ($game_actors)
# 的内部使用、Game_Party 类请参考 ($game_party) 。
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_reader   :name                     # 名称
  attr_reader   :character_name           # 角色 文件名
  attr_reader   :character_hue            # 角色 色相
  attr_reader   :class_id                 # 职业 ID
  attr_reader   :weapon_id                # 武器 ID
  attr_reader   :armor1_id                # 鞋子 ID
  attr_reader   :armor2_id                # 头饰 ID
  attr_reader   :armor3_id                # 外衣 ID
  attr_reader   :armor4_id                # 盔甲 ID
  attr_reader   :armor5_id                # 披风 ID
  attr_reader   :armor6_id                # 腰带 ID
  attr_reader   :armor7_id                # 钓竿 ID
  attr_reader   :level                    # 等级
  attr_reader   :exp                      # EXP
  attr_accessor :skills                   # 特技
  #力量，灵巧，速度，魔力，攻击力
  #百姓，八卦，花间，红莲，尹贺，太极，雪山，逍遥
  @@class_parameter=[[1,1,1,1,1],[1.3,1.1,1,0.85,1.15],[0.9,1.4,1,1.1,1],
    [1.2,1.1,1,0.8,1.3],[1,1,1,1.4,1],[0.9,1.05,1,1.45,1],
    [1.25,1.2,1,0.8,1.15],[1.2,1.8,1,0.9,1.2]]
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     actor_id : 角色 ID
  #--------------------------------------------------------------------------
  def initialize(actor_id)
    super()
    setup(actor_id)
  end
  #--------------------------------------------------------------------------
  # ● 设置
  #     actor_id : 角色 ID
  #--------------------------------------------------------------------------
  def setup(actor_id)
    @actor = $data_actors[1]
    @actor_id = actor_id
    @name = @actor.name
    @character_name = @actor.character_name
    @character_hue = @actor.character_hue
    @battler_name = @actor.battler_name
    @battler_hue = @actor.battler_hue
    @class_id = @actor.class_id
    @weapon_id = @actor.weapon_id
    @armor1_id = @actor.armor1_id
    @armor2_id = @actor.armor2_id
    @armor3_id = @actor.armor3_id
    @armor4_id = @actor.armor4_id
    @armor5_id = 0
    @armor6_id = 0#@actor.armor6_id
    @armor7_id = 0#@actor.armor7_id
    @level = @actor.initial_level
    @exp_list = Array.new(101)
    make_exp_list
    @exp = @exp_list[@level]
    @skills = []
    @hp = maxhp
    @sp = maxsp
    @states = []
    @states_turn = {}
    @maxhp_plus = 0
    @maxsp_plus = 0
    @str_plus = 0
    @dex_plus = 0
    @agi_plus = 0
    @int_plus = 0
    # 学会特技
    for i in 1..@level
      for j in $data_classes[@class_id].learnings
        if j.level == i
          learn_skill(j.skill_id)
        end
      end
    end
    # 刷新自动状态
    update_auto_state(nil, $data_armors[@armor1_id])
    update_auto_state(nil, $data_armors[@armor2_id])
    update_auto_state(nil, $data_armors[@armor3_id])
    update_auto_state(nil, $data_armors[@armor4_id])
    update_auto_state(nil, $data_armors[@armor5_id])
    update_auto_state(nil, $data_armors[@armor6_id])
    update_auto_state(nil, $data_armors[@armor7_id])
  end
  #--------------------------------------------------------------------------
  # ● 获取角色 ID 
  #--------------------------------------------------------------------------
  def id
    return @actor_id
  end
  #--------------------------------------------------------------------------
  # ● 获取角色最大生命值
  #--------------------------------------------------------------------------
  def full_hp
    full=100+$game_variables[24]/4
    full+=[($game_variables[157]-14)*20,300].min
    return full
  end
  #--------------------------------------------------------------------------
  # ● 获取角色最大内力值
  #--------------------------------------------------------------------------
  def full_fp
    full=$game_variables[45]/2*10+$game_variables[$game_variables[32]]*10
    full+=$game_variables[19]/1000
    full+=[20*($game_variables[157]-14),920].min
    full=[full,65535].min
    return full
  end
  #--------------------------------------------------------------------------
  # ● 获取索引
  #--------------------------------------------------------------------------
  def index
    return $game_party.actors.index(self)
  end
  #--------------------------------------------------------------------------
  # ● 计算 EXP
  #--------------------------------------------------------------------------
  def make_exp_list
    actor = $data_actors[@actor_id]
    @exp_list[1] = 0
    pow_i = 2.4 + actor.exp_inflation / 100.0
    for i in 2..100
      if i > actor.final_level
        @exp_list[i] = 0
      else
        n = actor.exp_basis * ((i + 3) ** pow_i) / (5 ** pow_i)
        @exp_list[i] = @exp_list[i-1] + Integer(n)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 取得属性修正值
  #     element_id : 属性 ID
  #--------------------------------------------------------------------------
  def element_rate(element_id)
    # 获取对应属性有效度的数值
    table = [0,200,150,100,50,0,-100]
    result = table[$data_classes[@class_id].element_ranks[element_id]]
    # 防具能防御本属性的情况下效果减半
    for i in [@armor1_id, @armor2_id, @armor3_id, @armor4_id, @armor5_id, 
              @armor6_id, @armor7_id]
      armor = $data_armors[i]
      if armor != nil and armor.guard_element_set.include?(element_id)
        result /= 2
      end
    end
    # 状态能防御本属性的情况下效果减半
    for i in @states
      if $data_states[i].guard_element_set.include?(element_id)
        result /= 2
      end
    end
    # 过程结束
    return result
  end
  #--------------------------------------------------------------------------
  # ● 获取属性有效度
  #--------------------------------------------------------------------------
  def state_ranks
    return $data_classes[@class_id].state_ranks
  end
  #--------------------------------------------------------------------------
  # ● 判定防御属性
  #     state_id : 属性 ID
  #--------------------------------------------------------------------------
  def state_guard?(state_id)
    for i in [@armor1_id, @armor2_id, @armor3_id, @armor4_id, @armor5_id,
              @armor6_id, @armor7_id]
      armor = $data_armors[i]
      if armor != nil
        if armor.guard_state_set.include?(state_id)
          return true
        end
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 获取普通攻击属性
  #--------------------------------------------------------------------------
  def element_set
    weapon = $data_weapons[@weapon_id]
    return weapon != nil ? weapon.element_set : []
  end
  #--------------------------------------------------------------------------
  # ● 获取普通攻击状态变化 (+)
  #--------------------------------------------------------------------------
  def plus_state_set
    weapon = $data_weapons[@weapon_id]
    return weapon != nil ? weapon.plus_state_set : []
  end
  #--------------------------------------------------------------------------
  # ● 获取普通攻击状态变化 (-)
  #--------------------------------------------------------------------------
  def minus_state_set
    weapon = $data_weapons[@weapon_id]
    return weapon != nil ? weapon.minus_state_set : []
  end
  #--------------------------------------------------------------------------
  # ● 获取 MaxHP
  #--------------------------------------------------------------------------
  def maxhp
    n = [[base_maxhp + @maxhp_plus, 1].max, 65535].min
    for i in @states
      n *= $data_states[i].maxhp_rate / 100.0
    end
    n = [[Integer(n), 1].max, 65535].min
    return n
  end
 #--------------------------------------------------------------------------
  # ● 获取基本 MaxHP
  #--------------------------------------------------------------------------
  def base_maxhp
    return $data_actors[@actor_id].parameters[0, @level]
  end
  #--------------------------------------------------------------------------
  # ● 获取基本 MaxSP
  #--------------------------------------------------------------------------
  def base_maxsp
    return $game_variables[24]*2
  end
  #--------------------------------------------------------------------------
  # ● 获取基本力量
  #--------------------------------------------------------------------------
  def base_str
    if @weapon_id==0
      sk_1=$game_variables[40]*2+$game_variables[45]
      sk_1+=[$game_variables[$game_variables[29]],get_actor_level].min*4
    else
      if weapon_matching_skill?
        sk_1=$game_variables[get_weapon_base_skill]*2+$game_variables[45]
        sk_1+=[$game_variables[$game_variables[30]],get_actor_level].min*4
      else
        sk_1=$game_variables[get_weapon_base_skill]*2+$game_variables[45]
      end
    end
    n=[$game_variables[11]*7/2+$game_variables[91],225].min+$game_variables[14]*3/2+3*sk_1/7
    n *= @@class_parameter[$game_variables[21]][0]
    n=n.truncate
    weapon = $data_weapons[@weapon_id]
    armor1 = $data_armors[@armor1_id]
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    armor5 = $data_armors[@armor5_id]
    armor6 = $data_armors[@armor6_id]
    armor7 = $data_armors[@armor7_id]
    n += weapon != nil ? weapon.str_plus : 0
    n += armor1 != nil ? armor1.str_plus : 0
    n += armor2 != nil ? armor2.str_plus : 0
    n += armor3 != nil ? armor3.str_plus : 0
    n += armor4 != nil ? armor4.str_plus : 0
    n += armor5 != nil ? armor5.str_plus : 0
    n += armor6 != nil ? armor6.str_plus : 0
    n += armor7 != nil ? armor7.str_plus : 0
    n += $game_variables[94]
    return [[n, 1].max, 9999].min
  end
  #--------------------------------------------------------------------------
  # ● 获取基本灵巧
  #--------------------------------------------------------------------------
  def base_dex
    sk_2=$game_variables[46]*2+get_actor_level
    sk_2+=[$game_variables[$game_variables[31]],get_actor_level].min*4
    n = $game_variables[12]*5+3*sk_2/5+$game_variables[92]
    n *= @@class_parameter[$game_variables[21]][1]
    n=n.truncate
    weapon = $data_weapons[@weapon_id]
    armor1 = $data_armors[@armor1_id]
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    armor5 = $data_armors[@armor5_id]
    armor6 = $data_armors[@armor6_id]
    armor7 = $data_armors[@armor7_id]
    n += weapon != nil ? weapon.dex_plus : 0
    n += armor1 != nil ? armor1.dex_plus : 0
    n += armor2 != nil ? armor2.dex_plus : 0
    n += armor3 != nil ? armor3.dex_plus : 0
    n += armor4 != nil ? armor4.dex_plus : 0
    n += armor5 != nil ? armor5.dex_plus : 0
    n += armor6 != nil ? armor6.dex_plus : 0
    n += armor7 != nil ? armor7.dex_plus : 0
    n += [$game_variables[95],255].min
    return [[n, 1].max, 9999].min
  end
  #--------------------------------------------------------------------------
  # ● 获取基本速度
  #--------------------------------------------------------------------------
  def base_agi
    n = $game_variables[48]+$game_variables[13]*10
    n *= @@class_parameter[$game_variables[21]][2]
    n=n.truncate
    weapon = $data_weapons[@weapon_id]
    armor1 = $data_armors[@armor1_id]
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    armor5 = $data_armors[@armor5_id]
    armor6 = $data_armors[@armor6_id]
    armor7 = $data_armors[@armor7_id]
    n += weapon != nil ? weapon.agi_plus : 0
    n += armor1 != nil ? armor1.agi_plus : 0
    n += armor2 != nil ? armor2.agi_plus : 0
    n += armor3 != nil ? armor3.agi_plus : 0
    n += armor4 != nil ? armor4.agi_plus : 0
    n += armor5 != nil ? armor5.agi_plus : 0
    n += armor6 != nil ? armor6.agi_plus : 0
    n += armor7 != nil ? armor7.agi_plus : 0
    return [[n, 1].max, 9999].min
  end
  #--------------------------------------------------------------------------
  # ● 获取基本魔力
  #--------------------------------------------------------------------------
  def base_int
    sk_4=$game_variables[45]*2+$game_variables[$game_variables[32]]*4
    n = $game_variables[14]*5+sk_4/3
    n *= @@class_parameter[$game_variables[21]][3]
    n=n.truncate
    weapon = $data_weapons[@weapon_id]
    armor1 = $data_armors[@armor1_id]
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    armor5 = $data_armors[@armor5_id]
    armor6 = $data_armors[@armor6_id]
    armor7 = $data_armors[@armor7_id]
    n += weapon != nil ? weapon.int_plus : 0
    n += armor1 != nil ? armor1.int_plus : 0
    n += armor2 != nil ? armor2.int_plus : 0
    n += armor3 != nil ? armor3.int_plus : 0
    n += armor4 != nil ? armor4.int_plus : 0
    n += armor5 != nil ? armor5.int_plus : 0
    n += armor6 != nil ? armor6.int_plus : 0
    n += armor7 != nil ? armor7.int_plus : 0
    return [[n, 1].max, 9999].min
  end
  #--------------------------------------------------------------------------
  # ● 获取基本攻击力
  #--------------------------------------------------------------------------
  def base_atk
    atk=$game_variables[11]+$game_variables[23]/2+$game_variables[40]/10+$game_variables[91]
    atk *= @@class_parameter[$game_variables[21]][4]
    atk=atk.truncate
    weapon = $data_weapons[@weapon_id]
    return weapon != nil ? weapon.atk+atk : atk
  end
  #--------------------------------------------------------------------------
  # ● 获取基本物理防御
  #--------------------------------------------------------------------------
  def base_pdef
    n=($game_variables[11]*3+$game_variables[14]*7)/2
    weapon = $data_weapons[@weapon_id]
    armor1 = $data_armors[@armor1_id]
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    armor5 = $data_armors[@armor5_id]
    armor6 = $data_armors[@armor6_id]
    armor7 = $data_armors[@armor7_id]
    pdef1 = weapon != nil ? weapon.pdef : 0
    pdef2 = armor1 != nil ? armor1.pdef : 0
    pdef3 = armor2 != nil ? armor2.pdef : 0
    pdef4 = armor3 != nil ? armor3.pdef : 0
    pdef5 = armor4 != nil ? armor4.pdef : 0
    pdef6 = armor5 != nil ? armor5.pdef : 0
    pdef7 = armor6 != nil ? armor6.pdef : 0
    pdef8 = armor7 != nil ? armor7.pdef : 0
    n +=[$game_variables[96],255].min
    n += (pdef1 + pdef2 + pdef3 + pdef4 + pdef5 + pdef6 + pdef7 + pdef8)
    return [[n, 1].max, 255].min
  end
  #--------------------------------------------------------------------------
  # ● 获取基本魔法防御
  #--------------------------------------------------------------------------
  def base_mdef
    sk_4=$game_variables[45]*2+$game_variables[47]+$game_variables[$game_variables[32]]*2
    n = base_int+sk_4/5
    weapon = $data_weapons[@weapon_id]
    armor1 = $data_armors[@armor1_id]
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    armor5 = $data_armors[@armor5_id]
    armor6 = $data_armors[@armor6_id]
    armor7 = $data_armors[@armor7_id]
    mdef1 = weapon != nil ? weapon.mdef : 0
    mdef2 = armor1 != nil ? armor1.mdef : 0
    mdef3 = armor2 != nil ? armor2.mdef : 0
    mdef4 = armor3 != nil ? armor3.mdef : 0
    mdef5 = armor4 != nil ? armor4.mdef : 0
    mdef6 = armor5 != nil ? armor5.mdef : 0
    mdef7 = armor6 != nil ? armor6.mdef : 0
    mdef8 = armor7 != nil ? armor7.mdef : 0
    return mdef1 + mdef2 + mdef3 + mdef4 + mdef5 + mdef6 + mdef7 +mdef8+n
  end
  #--------------------------------------------------------------------------
  # ● 获取基本回避修正
  #--------------------------------------------------------------------------
  def base_eva
    armor1 = $data_armors[@armor1_id]
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    armor5 = $data_armors[@armor5_id]
    armor6 = $data_armors[@armor6_id]
    armor7 = $data_armors[@armor7_id]
    eva1 = armor1 != nil ? armor1.eva : 0
    eva2 = armor2 != nil ? armor2.eva : 0
    eva3 = armor3 != nil ? armor3.eva : 0
    eva4 = armor4 != nil ? armor4.eva : 0
    eva5 = armor5 != nil ? armor5.eva : 0
    eva6 = armor6 != nil ? armor6.eva : 0
    eva7 = armor7 != nil ? armor7.eva : 0
    return eva1 + eva2 + eva3 + eva4 + eva5 + eva6 +eva7
  end
  #--------------------------------------------------------------------------
  # ● 普通攻击 获取攻击方动画 ID
  #--------------------------------------------------------------------------
  def animation1_id
    weapon = $data_weapons[@weapon_id]
    return weapon != nil ? weapon.animation1_id : 0
  end
  #--------------------------------------------------------------------------
  # ● 普通攻击 获取对像方动画 ID
  #--------------------------------------------------------------------------
  def animation2_id
    weapon = $data_weapons[@weapon_id]
    return weapon != nil ? weapon.animation2_id : 0
  end
  #--------------------------------------------------------------------------
  # ● 获取类名
  #--------------------------------------------------------------------------
  def class_name
    return $data_classes[@class_id].name
  end
  #--------------------------------------------------------------------------
  # ● 获取 EXP 字符串
  #--------------------------------------------------------------------------
  def exp_s
    return @exp_list[@level+1] > 0 ? @exp.to_s : "-------"
  end
  #--------------------------------------------------------------------------
  # ● 获取下一等级的 EXP 字符串
  #--------------------------------------------------------------------------
  def next_exp_s
    return @exp_list[@level+1] > 0 ? @exp_list[@level+1].to_s : "-------"
  end
  #--------------------------------------------------------------------------
  # ● 获取离下一等级还需的 EXP 字符串
  #--------------------------------------------------------------------------
  def next_rest_exp_s
    return @exp_list[@level+1] > 0 ?
      (@exp_list[@level+1] - @exp).to_s : "-------"
  end
  #--------------------------------------------------------------------------
  # ● 更新自动状态
  #     old_armor : 卸下防具
  #     new_armor : 装备防具
  #--------------------------------------------------------------------------
  def update_auto_state(old_armor, new_armor)
    # 强制解除卸下防具的自动状态
    if old_armor != nil and old_armor.auto_state_id != 0
      remove_state(old_armor.auto_state_id, true)
    end
    # 强制附加装备防具的自动状态
    if new_armor != nil and new_armor.auto_state_id != 0
      add_state(new_armor.auto_state_id, true)
    end
  end
  #--------------------------------------------------------------------------
  # ● 装备固定判定
  #     equip_type : 装备类型
  #--------------------------------------------------------------------------
  def equip_fix?(equip_type)
    case equip_type
    when 0  # 武器
      return $data_actors[@actor_id].weapon_fix
    when 1  # 鞋子
      return $data_actors[@actor_id].armor1_fix
    when 2  # 头饰
      return $data_actors[@actor_id].armor2_fix
    when 3  # 外衣
      return $data_actors[@actor_id].armor3_fix
    when 4  # 盔甲
      return $data_actors[@actor_id].armor4_fix
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 变更装备
  #     equip_type : 装备类型
  #     id    : 武器 or 防具 ID  (0 为解除装备)
  #--------------------------------------------------------------------------
  def equip(equip_type, id)
    case equip_type
    when 0  # 武器
      return $data_actors[@actor_id].weapon_fix
    when 1  # 盾
      return $data_actors[@actor_id].armor1_fix
    when 2  # 头
      return $data_actors[@actor_id].armor2_fix
    when 3  # 身体
      return $data_actors[@actor_id].armor3_fix
    when 4  # 装饰品
      return $data_actors[@actor_id].armor4_fix
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 卸下所有装备
  #--------------------------------------------------------------------------
  def unequipall
    @weapon_id=0
    @armor1_id=0
    @armor2_id=0
    @armor3_id=0
    @armor4_id=0
    @armor5_id=0
    @armor6_id=0
    @armor7_id=0
  end
  #--------------------------------------------------------------------------
  # ● 可以装备判定
  #     item : 物品
  #--------------------------------------------------------------------------
  def equippable?(item)
    # 武器的情况
    if item.is_a?(RPG::Weapon)
      # 包含当前的职业可以装备武器的场合
      if $data_classes[@class_id].weapon_set.include?(item.id)
        return true
      end
    end
    # 防具的情况
    if item.is_a?(RPG::Armor)
      # 不包含当前的职业可以装备武器的场合
      if $data_classes[@class_id].armor_set.include?(item.id)
        return true
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 更改 EXP
  #     exp : 新的 EXP
  #--------------------------------------------------------------------------
  def exp=(exp)
    @exp = [[exp, 9999999].min, 0].max
    # 升级
    while @exp >= @exp_list[@level+1] and @exp_list[@level+1] > 0
      @level += 1
      # 学会特技
      for j in $data_classes[@class_id].learnings
        if j.level == @level
          learn_skill(j.skill_id)
        end
      end
    end
    # 降级
    while @exp < @exp_list[@level]
      @level -= 1
    end
    # 修正当前的 HP 与 SP 超过最大值
    @hp = [@hp, self.maxhp].min
    @sp = [@sp, self.maxsp].min
  end
  #--------------------------------------------------------------------------
  # ● 更改等级
  #     level : 新的等级
  #--------------------------------------------------------------------------
  def level=(level)
    # 检查上下限
    level = [[level, $data_actors[@actor_id].final_level].min, 1].max
    # 更改 EXP
    self.exp = @exp_list[level]
  end
  #--------------------------------------------------------------------------
  # ● 觉悟特技
  #     skill_id : 特技 ID
  #--------------------------------------------------------------------------
  def learn_skill(skill_id)
    if skill_id > 0 and not skill_learn?(skill_id)
      @skills.push(skill_id)
      @skills.sort!
    end
  end
  #--------------------------------------------------------------------------
  # ● 遗忘特技
  #     skill_id : 特技 ID
  #--------------------------------------------------------------------------
  def forget_skill(skill_id)
    @skills.delete(skill_id)
  end
  #--------------------------------------------------------------------------
  # ● 已经学会的特技判定
  #     skill_id : 特技 ID
  #--------------------------------------------------------------------------
  def skill_learn?(skill_id)
    return @skills.include?(skill_id)
  end
  #--------------------------------------------------------------------------
  # ● 可以使用特技判定
  #     skill_id : 特技 ID
  #--------------------------------------------------------------------------
  def skill_can_use?(skill_id)
    if not skill_learn?(skill_id)
      return false
    end
    return super
  end
  #--------------------------------------------------------------------------
  # ● 更改名称
  #     name : 新的名称
  #--------------------------------------------------------------------------
  def name=(name)
    @name = name
  end
  #--------------------------------------------------------------------------
  # ● 更改职业 ID
  #     class_id : 新的职业 ID
  #--------------------------------------------------------------------------
  def class_id=(class_id)
    if $data_classes[class_id] != nil
      @class_id = class_id
      # 避开无法装备的物品
      unless equippable?($data_weapons[@weapon_id])
        equip(0, 0)
      end
      unless equippable?($data_armors[@armor1_id])
        equip(1, 0)
      end
      unless equippable?($data_armors[@armor2_id])
        equip(2, 0)
      end
      unless equippable?($data_armors[@armor3_id])
        equip(3, 0)
      end
      unless equippable?($data_armors[@armor4_id])
        equip(4, 0)
      end
      unless equippable?($data_armors[@armor5_id])
        equip(5, 0)
      end
      unless equippable?($data_armors[@armor6_id])
        equip(6, 0)
      end
      unless equippable?($data_armors[@armor7_id])
        equip(7, 0)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 更改图形
  #     character_name : 新的角色 文件名
  #     character_hue  : 新的角色 色相
  #     battler_name   : 新的战斗者 文件名
  #     battler_hue    : 新的战斗者 色相
  #--------------------------------------------------------------------------
  def set_graphic(character_name, character_hue, battler_name, battler_hue)
    @character_name = character_name
    @character_hue = character_hue
    @battler_name = battler_name
    @battler_hue = battler_hue
  end
  #--------------------------------------------------------------------------
  # ● 取得战斗画面的 X 坐标
  #--------------------------------------------------------------------------
  def screen_x
      return 160
  end
  #--------------------------------------------------------------------------
  # ● 取得战斗画面的 Y 坐标
  #--------------------------------------------------------------------------
  def screen_y
    return 160
  end
  #--------------------------------------------------------------------------
  # ● 更换装备
  #    type：0-武器
  #--------------------------------------------------------------------------
  def equip(type,id)
    case type
    when 0 # 武器
      @weapon_id=id
    when 1 # 鞋子
      @armor1_id=id
    when 2 # 头饰
      update_auto_state($data_armors[@armor2_id], $data_armors[id])
      @armor2_id=id
    when 3 # 外衣
      @armor3_id=id
    when 4 # 盔甲
      @armor4_id=id
    when 5 # 披风
      @armor5_id=id
    when 6 # 腰带
      @armor6_id=id
    when 7 # 钓竿
      @armor7_id=id
    end
  end
  #--------------------------------------------------------------------------
  # ● 判定是否装备某件防具
  #--------------------------------------------------------------------------
  def armor_equiped?(id)
    chk=[@armor1_id, @armor2_id, @armor3_id, @armor4_id, @armor5_id,
         @armor6_id, @armor7_id]
    for i in chk
      if id==i
        return true
        break
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 取得战斗画面的 Z 坐标
  #--------------------------------------------------------------------------
  def screen_z
    # 返回计算后的队伍 Z 坐标的排列顺序
    if self.index != nil
      return 4 - self.index
    else
      return 0
    end
  end
end
