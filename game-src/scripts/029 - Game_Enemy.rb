#==============================================================================
# ■ Game_Enemy
#------------------------------------------------------------------------------
# 　处理敌人的类。本类在 Game_Troop 类 ($game_troop) 的
# 内部使用。
#==============================================================================

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  @@class_parameter=[[1,1,1,1,1],[1.3,1.1,1,0.85,1.15],[0.9,1.4,1,1.1,1],
    [1.2,1.1,1,0.8,1.3],[1,1,1,1.4,1],[0.85,1,1,1.55,1],
    [1.25,1.2,1,0.8,1.15],[1.2,1.3,1,0.9,1.2]]
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     troop_id     : 循环 ID
  #     member_index : 循环成员的索引
  #--------------------------------------------------------------------------
  def initialize(troop_id, member_index)
    super()
    @troop_id = troop_id
    @member_index = member_index
    troop = $data_troops[@troop_id]
    @enemy_id = troop.members[@member_index].enemy_id
    enemy = $data_enemies[@enemy_id]
    @battler_name = enemy.battler_name
    @battler_hue = enemy.battler_hue
    @hp = maxhp
    @sp = maxsp
    @hidden = troop.members[@member_index].hidden
    @immortal = troop.members[@member_index].immortal
  end
  #--------------------------------------------------------------------------
  # ● 获取敌人 ID
  #--------------------------------------------------------------------------
  def id
    return @enemy_id
  end
  #--------------------------------------------------------------------------
  # ● 获取索引
  #--------------------------------------------------------------------------
  def index
    return @member_index
  end
  #--------------------------------------------------------------------------
  # ● 获取名称
  #--------------------------------------------------------------------------
  def name
    return $data_enemies[@enemy_id].name
  end
  #--------------------------------------------------------------------------
  # ● 获取基本 MaxHP
  #--------------------------------------------------------------------------
  def base_maxhp
    return $data_enemies[@enemy_id].maxhp
  end
  #--------------------------------------------------------------------------
  # ● 获取基本 MaxSP
  #--------------------------------------------------------------------------
  def base_maxsp
    return $data_enemies[@enemy_id].maxsp
  end
  #--------------------------------------------------------------------------
  # ● 获取基本力量
  #--------------------------------------------------------------------------
  def base_str
    if $npc_data[9]==0
      sk_1=get_skill_level(40)*2+get_skill_level(45)
      sk_1+=[get_skill_level($npc_data[4]),npc_level].min*4
    else
      if npc_weapon?($npc_data[9])
        sk_1=get_skill_level(npc_base_skill($npc_data[9]))*2+get_skill_level(45)
        sk_1+=[get_skill_level($npc_data[5]),npc_level].min*4
      else
        sk_1=get_skill_level(npc_base_skill($npc_data[9]))*2
        sk_1+=get_skill_level(45)
      end
    end
    n=$npc_data[0]*7/2+$npc_data[3]*3/2+3*sk_1/7
    n+=$npc_data[24]
    n*=@@class_parameter[$npc_data[27]][0]
    n+=$npc_data[29]
    n=n.truncate
    weapon = $data_weapons[$npc_data[9]]
    armor1 = $data_armors[$npc_data[10]]
    armor2 = $data_armors[$npc_data[11]]
    n += weapon != nil ? weapon.str_plus : 0
    n += armor1 != nil ? armor1.str_plus : 0
    n += armor2 != nil ? armor2.str_plus : 0
    return [[n, 1].max, 9999].min
  end
  #--------------------------------------------------------------------------
  # ● 获取基本灵巧
  #--------------------------------------------------------------------------
  def base_dex
    sk_2=get_skill_level(46)*2+npc_level
    sk_2+=[get_skill_level($npc_data[6]),npc_level].min*4
    n=$npc_data[1]*5+3*sk_2/5
    n+=$npc_data[25]
    n*=@@class_parameter[$npc_data[27]][1]
    n+=$npc_data[30]
    n=n.truncate
    weapon = $data_weapons[$npc_data[9]]
    armor1 = $data_armors[$npc_data[10]]
    armor2 = $data_armors[$npc_data[11]]
    n += weapon != nil ? weapon.dex_plus : 0
    n += armor1 != nil ? armor1.dex_plus : 0
    n += armor2 != nil ? armor2.dex_plus : 0
    return [[n, 1].max, 9999].min
  end
  #--------------------------------------------------------------------------
  # ● 获取基本速度
  #--------------------------------------------------------------------------
  def base_agi
    n=get_skill_level(48)+$npc_data[2]*10
    n*=@@class_parameter[$npc_data[27]][3]
    n=n.truncate
    weapon = $data_weapons[$npc_data[9]]
    armor1 = $data_armors[$npc_data[10]]
    armor2 = $data_armors[$npc_data[11]]
    n += weapon != nil ? weapon.agi_plus : 0
    n += armor1 != nil ? armor1.agi_plus : 0
    n += armor2 != nil ? armor2.agi_plus : 0
    return [[n, 1].max, 9999].min
  end
  #--------------------------------------------------------------------------
  # ● 获取基本魔力
  #--------------------------------------------------------------------------
  def base_int
    sk_4=get_skill_level(45)*2+get_skill_level($npc_data[7])*4
    n=$npc_data[3]*5+sk_4/3
    n=n.truncate
    weapon = $data_weapons[$npc_data[9]]
    armor1 = $data_armors[$npc_data[10]]
    armor2 = $data_armors[$npc_data[11]]
    n += weapon != nil ? weapon.int_plus : 0
    n += armor1 != nil ? armor1.int_plus : 0
    n += armor2 != nil ? armor2.int_plus : 0
    return [[n, 1].max, 9999].min
  end
  #--------------------------------------------------------------------------
  # ● 获取基本攻击力
  #--------------------------------------------------------------------------
  def base_atk
    atk=$npc_data[0]+$data_enemies[@enemy_id].exp/2+get_skill_level(40)/10+$npc_data[29]
    if @enemy_id==125 and $game_actors[1].weapon_id !=0
      atk+=$data_weapons[$game_actors[1].weapon_id].atk
    end
    atk*=@@class_parameter[$npc_data[27]][4]
    atk=atk.truncate
    weapon = $data_weapons[$npc_data[9]]
    return weapon != nil ? weapon.atk+atk : atk
  end
  #--------------------------------------------------------------------------
  # ● 获取基本物理防御
  #--------------------------------------------------------------------------
  def base_pdef
    n=($npc_data[0]*3+$npc_data[3]*7)/2
    n+=$npc_data[28]
    n=n.truncate
    weapon = $data_weapons[$npc_data[9]]
    armor1 = $data_armors[$npc_data[10]]
    armor2 = $data_armors[$npc_data[11]]
    pdef1 = weapon != nil ? weapon.pdef : 0
    pdef2 = armor1 != nil ? armor1.pdef : 0
    pdef3 = armor2 != nil ? armor2.pdef : 0
    n+=pdef1 + pdef2 + pdef3
    n=[n,255].min
    return n
  end
  #--------------------------------------------------------------------------
  # ● 获取基本魔法防御
  #--------------------------------------------------------------------------
  def base_mdef
    sk_4=get_skill_level(45)*2+get_skill_level(47)
    sk_4+=(get_skill_level($npc_data[7])*2)
    n=base_int+sk_4/5
    weapon = $data_weapons[$npc_data[9]]
    armor1 = $data_armors[$npc_data[10]]
    armor2 = $data_armors[$npc_data[11]]
    mdef1 = weapon != nil ? weapon.mdef : 0
    mdef2 = armor1 != nil ? armor1.mdef : 0
    mdef3 = armor2 != nil ? armor2.mdef : 0
    return mdef1 + mdef2 + mdef3 +n
  end
  #--------------------------------------------------------------------------
  # ● 获取基本回避修正
  #--------------------------------------------------------------------------
  def base_eva
    return $data_enemies[@enemy_id].eva
  end
  #--------------------------------------------------------------------------
  # ● 普通攻击 获取攻击方动画 ID
  #--------------------------------------------------------------------------
  def animation1_id
    return $data_enemies[@enemy_id].animation1_id
  end
  #--------------------------------------------------------------------------
  # ● 普通攻击 获取对像方动画 ID
  #--------------------------------------------------------------------------
  def animation2_id
    return $data_enemies[@enemy_id].animation2_id
  end
  #--------------------------------------------------------------------------
  # ● 获取属性修正值
  #     element_id : 属性 ID
  #--------------------------------------------------------------------------
  def element_rate(element_id)
    # 获取对应属性有效度的数值
    table = [0,200,150,100,50,0,-100]
    result = table[$data_enemies[@enemy_id].element_ranks[element_id]]
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
    return $data_enemies[@enemy_id].state_ranks
  end
  #--------------------------------------------------------------------------
  # ● 属性防御判定
  #     state_id : 状态 ID
  #--------------------------------------------------------------------------
  def state_guard?(state_id)
    return false
  end
  #--------------------------------------------------------------------------
  # ● 获取普通攻击属性
  #--------------------------------------------------------------------------
  def element_set
    return []
  end
  #--------------------------------------------------------------------------
  # ● 获取普通攻击的状态变化 (+)
  #--------------------------------------------------------------------------
  def plus_state_set
    return []
  end
  #--------------------------------------------------------------------------
  # ● 获取普通攻击的状态变化 (-)
  #--------------------------------------------------------------------------
  def minus_state_set
    return []
  end
  #--------------------------------------------------------------------------
  # ● 获取行动
  #--------------------------------------------------------------------------
  def actions
    return $data_enemies[@enemy_id].actions
  end
  #--------------------------------------------------------------------------
  # ● 获取 EXP
  #--------------------------------------------------------------------------
  def exp
    return $data_enemies[@enemy_id].exp
  end
  #--------------------------------------------------------------------------
  # ● 获取金钱
  #--------------------------------------------------------------------------
  def gold
    return $data_enemies[@enemy_id].gold
  end
  #--------------------------------------------------------------------------
  # ● 获取物品 ID
  #--------------------------------------------------------------------------
  def item_id
    return $data_enemies[@enemy_id].item_id
  end
  #--------------------------------------------------------------------------
  # ● 获取武器 ID
  #--------------------------------------------------------------------------
  def weapon_id
    return $data_enemies[@enemy_id].weapon_id
  end
  #--------------------------------------------------------------------------
  # ● 获取防具 ID
  #--------------------------------------------------------------------------
  def armor_id
    return $data_enemies[@enemy_id].armor_id
  end
  #--------------------------------------------------------------------------
  # ● 获取宝物出现率
  #--------------------------------------------------------------------------
  def treasure_prob
    return $data_enemies[@enemy_id].treasure_prob
  end
  #--------------------------------------------------------------------------
  # ● 取得战斗画面 X 坐标
  #--------------------------------------------------------------------------
  def screen_x
    return 480
    #return $data_troops[@troop_id].members[@member_index].x
  end
  #--------------------------------------------------------------------------
  # ● 取得战斗画面 Y 坐标
  #--------------------------------------------------------------------------
  def screen_y
    return 160
    #return $data_troops[@troop_id].members[@member_index].y
  end
  #--------------------------------------------------------------------------
  # ● 取得战斗画面 Z 坐标
  #--------------------------------------------------------------------------
  def screen_z
    # 返回计算后的队伍 Z 坐标的排列顺序
    if self.index != nil
      return 4 - self.index
    else
      return 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 取得NPC总评等级
  #--------------------------------------------------------------------------
  def npc_level
    if $npc_data[9]==0
      sk_1=get_skill_level(40)*2+get_skill_level($npc_data[4])*4
      sk_2=get_skill_level(46)+get_skill_level($npc_data[6])*2
      sk_3=get_skill_level(47)+get_skill_level($npc_data[8])*2
    else
      sk_2=get_skill_level(46)+get_skill_level($npc_data[6])*2
      sk_3=get_skill_level(47)+get_skill_level($npc_data[8])*2
      if npc_weapon?($npc_data[9])
        sk_1=get_skill_level(npc_base_skill($npc_data[9]))*2
        sk_1+=get_skill_level($npc_data[5])*4
      else
        sk_1=get_skill_level(npc_base_skill($npc_data[9]))*2
      end
    end
    return (sk_1+sk_2+sk_3)/12
  end
  #--------------------------------------------------------------------------
  # ● 判定NPC装备武器是否与兵刃匹配
  #--------------------------------------------------------------------------
  def npc_weapon?(id)
    case id
    when 8,9,10,11,12,13,14,1,28,29
      return true if $npc_data[5]>=80 and $npc_data[5]<=83
    when 2,3,4,6,7,15,16,17,18,19,20,30
      return true if $npc_data[5]>=85 and $npc_data[5]<=87
    when 5,21,22,23,24
      return true if $npc_data[5]==88
    when 25,26,27
      return true if $npc_data[5]==89
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 取得NPC武器对应基本功夫编号
  #--------------------------------------------------------------------------
  def npc_base_skill(id)
    case id
    when 8,9,10,11,12,13,14,1,28,29
      return 42
    when 2,3,4,6,7,15,16,17,18,19,20,30
      return 41
    when 5,21,22,23,24
      return 44
    when 25,26,27
      return 43
    end
    return 0
  end
  #--------------------------------------------------------------------------
  # ● 取得NPC指定编号技能的等级
  #--------------------------------------------------------------------------
  def get_skill_level(sk_id)
    for i in $npc_data
      if i.is_a?(Array)
        return i[1] if i[0]==sk_id
      end
    end
    return 0
  end
  #--------------------------------------------------------------------------
  # ● 逃跑
  #--------------------------------------------------------------------------
  def escape
    # 设置隐藏标志
    @hidden = true
    # 清除当前行动
    self.current_action.clear
  end
  #--------------------------------------------------------------------------
  # ● 变身
  #     enemy_id : 变身为的敌人 ID
  #--------------------------------------------------------------------------
  def transform(enemy_id)
    # 更改敌人 ID
    @enemy_id = enemy_id
    # 更改战斗图形
    @battler_name = $data_enemies[@enemy_id].battler_name
    @battler_hue = $data_enemies[@enemy_id].battler_hue
    # 再生成行动
    make_action
  end
  #--------------------------------------------------------------------------
  # ● 生成行动
  #--------------------------------------------------------------------------
  def make_action
    # 清除当前行动
    self.current_action.clear
    # 无法行动的情况
    unless self.movable?
      # 过程结束
      return
    end
    # 抽取现在有效的行动
    available_actions = []
    rating_max = 0
    for action in self.actions
      # 确认回合条件
      n = $game_temp.battle_turn
      a = action.condition_turn_a
      b = action.condition_turn_b
      if (b == 0 and n != a) or
         (b > 0 and (n < 1 or n < a or n % b != a % b))
        next
      end
      # 确认 HP 条件
      if self.hp * 100.0 / self.maxhp > action.condition_hp
        next
      end
      # 确认等级条件
      if $game_party.max_level < action.condition_level
        next
      end
      # 确认开关条件
      switch_id = action.condition_switch_id
      if switch_id > 0 and $game_switches[switch_id] == false
        next
      end
      # 符合条件 : 添加本行动
      available_actions.push(action)
      if action.rating > rating_max
        rating_max = action.rating
      end
    end
    # 最大概率值作为 3 合计计算(0 除外)
    ratings_total = 0
    for action in available_actions
      if action.rating > rating_max - 3
        ratings_total += action.rating - (rating_max - 3)
      end
    end
    # 概率合计不为 0 的情况下
    if ratings_total > 0
      # 生成随机数
      value = rand(ratings_total)
      # 设置对应生成随机数的当前行动
      for action in available_actions
        if action.rating > rating_max - 3
          if value < action.rating - (rating_max - 3)
            self.current_action.kind = action.kind
            self.current_action.basic = action.basic
            self.current_action.skill_id = action.skill_id
            self.current_action.decide_random_target_for_enemy
            return
          else
            value -= action.rating - (rating_max - 3)
          end
        end
      end
    end
  end
end
