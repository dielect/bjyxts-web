#==============================================================================
# ■ 渔隐：钓鱼也是一条武学成长线（设计见 docs/职业生活与武林互动设计.md）
#------------------------------------------------------------------------------
#  不靠潜能任务，也能从钓鱼里长本事：
#    - 稀罕鱼给实战经验（少见 10、稀有 40、难得一见 150，见 WebLife::CATCH_EXP）；
#    - 吃稀罕鱼：鳜鱼、石斑鱼、红鲷补满一半气血；金鲤长内力修为（内力修为又决定气血上限）；
#    - 太公钓法（兵刃 90，基础鞭法）：冰火岛渡口的老渔翁在你渔技 5 级后传授。拿着能当兵器的鱼竿钓鱼，
#      每钓上一条，太公钓法就长修炼进度（规则同原版向师傅学武，只是不花潜能，仍受经验上限限制）；
#      60 级绝招“愿者上钩”（钩走兵器，把人定住），100 级绝招“鲤跃龙门”（连击三次）；
#    - 渔技称号：渔童、渔夫、老渔翁、钓叟、钓圣（鱼谱里显示）；渔技 9 级、十二种鱼都钓到过，结局称号“钓圣”；
#    - 钓上来的不只是鱼：草鞋、锈剑、武学残页、漂流瓶（里面是江湖传闻）、钱袋、木箱，渔技高了还会钓上来水贼、海盗；
#    - 渔樵套（050）：斗笠、蓑衣、任一钓竿、任一兵器鱼竿，4 件时太公钓法战斗中 +20 级、两个绝招省力。
#  时间是代价：每钓一次都要过去两个时辰，人会变老。
#
#  编号：武功 90 太公钓法（修炼进度变量 150）；绝招 30 愿者上钩、31 鲤跃龙门；武器 74 铁骨鱼竿、75 定海神竿；
#        物品 41 漂流瓶；公共事件 29 漂流瓶、30～33 与 36 吃鱼、34～35 放生；敌人 160 水贼、161 海盗
#==============================================================================

#--------------------------------------------------------------------------
# 敌人：钓上来的水贼、海盗
#--------------------------------------------------------------------------
WebMod.enemy 160, name: '水贼', tile: 841, like: 123, maxhp: 380, maxsp: 200, gold: 200,
             stats: NO_STYLE.merge(膂力: 24, 敏捷: 26, 悟性: 18, 根骨: 22, 武器: 2, 经验: 30000),
             skills: { 41 => 60, 46 => 70, 47 => 50, 40 => 50 }
WebMod.enemy 161, name: '海盗', tile: 882, like: 124, maxhp: 480, maxsp: 500, gold: 500,
             stats: NO_STYLE.merge(膂力: 27, 敏捷: 24, 悟性: 18, 根骨: 26, 武器: 9, 经验: 80000),
             skills: { 42 => 100, 46 => 80, 47 => 80, 40 => 70, 45 => 60 }

#--------------------------------------------------------------------------
# 太公钓法与兵器鱼竿
#--------------------------------------------------------------------------
WebSkill.add_skill 90, WebSkill::WEAPON, 44
WebMod.variable_name 90, '太公钓法'
WebSkill.attack_words 90, [
  [0,   '%{user}手腕一抖，%{weapon}上的钓线“嗖”地抛出，鱼钩直取%{objector}的%{sp}', 25, 36, 2],
  [0,   '%{user}使出「收线」，%{weapon}往回一扯，钓线缠向%{objector}的%{sp}', 25, 36, 3],
  [15,  '%{user}一招「钩挂」，鱼钩在空中拐了个弯，勾向%{objector}的%{sp}', 35, 37, 2],
  [30,  '%{user}使出「甩鱼」，%{weapon}抡圆了，竿梢重重抽在%{objector}的%{sp}', 45, 37, 3],
  [50,  '%{user}竿随身转，一招「抖竿」，钓线抖出满天银光罩向%{objector}', 60, 38, 3],
  [70,  '%{user}使出「拖线」，钓线贴地一扫，绊向%{objector}的下盘', 75, 38, 3],
  [90,  '%{user}一招「静水深流」，%{weapon}纹丝不动，鱼钩却悄无声息地到了%{objector}的%{sp}', 95, 40, 2],
  [120, '%{user}使出「太公垂钓」，钓线直如铁杆，一钩点向%{objector}的%{sp}', 120, 42, 2],
]

WebEquip.weapon 74, '铁骨鱼竿', :鞭, 38, 3000, '精钢竿骨的鱼竿，钓鱼打架两相宜', fx: [[:disarm, chance: 10, name: '钩挂']]
WebEquip.weapon 75, '定海神竿', :鞭, 85, 0, '老渔翁的神竿，据说曾钓起过海里的蛟龙', fx: [[:stun, chance: 12, name: '定海'], [:disarm, chance: 10, name: '钩挂']]
WebLife::WEAPON_RODS[74] = { bite: 5, rare: 2 }
WebLife::WEAPON_RODS[75] = { rare: 8, legend: 2, keep: 10, size: 20 }

# 绝招：愿者上钩（钩走兵器、把人定住，不造成伤害）、鲤跃龙门（连击三次）
WebMod.skill 30, like: 29, name: '愿者上钩', sp_cost: 250, description: '太公钓法绝技，钩走兵器，把人定住'
WebMod.skill 31, like: 28, name: '鲤跃龙门', sp_cost: 400, description: '太公钓法绝技，三连击'
WebSkill.perform 90, 30, 31
WebSkill.requirement 30, [[30, 90], [90, 60], [44, 60]]     # 启用太公钓法，太公钓法、基本鞭法都到 60 级
WebSkill.requirement 31, [[30, 90], [90, 100], [44, 100]]
WebSkill.combo 31, moves_of: 90, times: 3
WebSkill.skill_words 30, [
  '%{user}把%{weapon}往前一递，钓线悠悠荡荡地飘向%{objector}，口中念道：“太公钓鱼，愿者上钩。”',
  '鱼钩不偏不倚挂住了%{objector}，被你一扯，手里的家伙脱手飞出，人也僵在原地！',
  '%{objector}侧身一让，钓线落了个空。',
]
WebSkill.skill_words 31, [
  '%{user}身形一纵，%{weapon}划出三道弧线，如鲤鱼跃龙门，一浪高过一浪！',
]

class Game_Battler
  alias __yy_skill_effect skill_effect
  def skill_effect(user, skill, window)
    r = __yy_skill_effect(user, skill, window)
    if skill.id == 30 && user.is_a?(Game_Actor) && is_a?(Game_Enemy)
      words = get_skill_words(user, self, 30)
      if hit_result?(user, self)
        w = $npc_data[9].to_i
        if w != 0
          $game_party.gain_weapon(w, 1)
          $npc_data[9] = 0
        end
        add_state(1)
        $defend_text = words[1]
      else
        $defend_text = words[2]
      end
      self.damage = 0
    end
    r
  end
end

#--------------------------------------------------------------------------
# 老渔翁：冰火岛渡口，渔技 5 级后传太公钓法、送铁骨鱼竿；太公钓法 100 级且渔技 9 级送定海神竿
#--------------------------------------------------------------------------
WebMod.edit 37 do |m|
  m.npc 13, 8, name: '老渔翁', tile: 880,
        look: { age: 7, level: 30, attack: 5, items: '蓑衣、斗笠', text: '一个须发皆白的老渔翁，坐在岸边，钓线垂在海里，半天也不动一下。' } do |c|
    c.if_variable(90, 1, 1) do
      c.if_script('WebLife.skill_level >= 9 && $game_variables[90] >= 100 && !WebLife.flag?(:god_rod)') do
        c.text '老渔翁睁开眼，看了你半晌，哈哈一笑：“好！好！你如今钓的已经不是鱼了。”'
        c.text '“这根定海神竿跟了我五十年，钓起过海里的蛟龙。从今往后，它是你的了。”'
        c.script 'WebLife.set_flag(:god_rod)'
        c.gain(:weapon, 75)
        c.text '得到了定海神竿！'
      end.else do
        c.one_of '钓鱼和练功一样，急不得。浮子不动，你也别动。',
                 '拿着能当兵器的鱼竿去钓，一甩一收之间，功夫自然就长了。',
                 '太公钓法练到六十级，就能使“愿者上钩”；一百级，“鲤跃龙门”。',
                 '海里的鱼比塘里的凶，海竿、香饵都备着点。'
      end
    end.else do
      c.if_script('WebLife.skill_level >= 5') do
        c.text '老渔翁瞥了一眼你的鱼篓，点点头：“嗯，是个会钓鱼的。”'
        c.text '“姜太公钓鱼，愿者上钩。钓鱼的功夫，也能打人。老头子教你一手‘太公钓法’，拿着这根鱼竿慢慢练。”'
        c.variable(90, 1)
        c.gain(:weapon, 74)
        c.text '你学会了太公钓法！得到了铁骨鱼竿。（装备鱼竿、启用太公钓法；拿着它钓鱼，功夫会跟着长）'
      end.else do
        c.text '年轻人，鱼竿都拿不稳，就想学老头子的本事？先去多钓几条鱼吧。（渔技 5 级）'
      end
    end
  end
end

#--------------------------------------------------------------------------
# 漂流瓶与吃鱼
#--------------------------------------------------------------------------
WebMod.item 41, like: 14, common_event_id: 29, name: '漂流瓶', price: 20,
            description: '一只封着口的瓶子，里面卷着一张纸条'

module WebLife
  # 漂流瓶：随机一条还没听过的江湖传闻（同茶摊传闻，060 / 090 的 RUMORS）
  def self.bottle_text
    todo = RUMORS.select { |sw, cond, _| !$game_switches[sw] && (eval(cond) rescue false) }
    if respond_to?(:kitchen?) && kitchen? && !known?(63) && rand(100) < 25        # 130_厨子.rb：八宝鱼翅的方子
      learn(63)
      return '瓶里卷着一张发黄的菜谱，写着“八宝鱼翅”，落款是宫里的御厨。（学会了八宝鱼翅）'
    end
    return '纸条被海水泡烂了，一个字也看不清。' if todo.empty?
    sw, _, text = todo.sample
    $game_switches[sw] = true
    "纸条上歪歪扭扭写着：#{text}"
  end

  def self.eat(kind, name = '金鲤')
    a = $game_actors[1]
    $game_variables[15] = [$game_variables[15] + 250, $game_variables[16]].max if $game_variables[15] < $game_variables[16]
    if kind == :gold
      $game_variables[24] += 30
      a.hp = a.maxhp
      "你把#{name}炖了一锅，喝下去只觉丹田一热，一股暖流走遍四肢百骸。（内力修为+30）"
    else
      heal = [a.maxhp / 2, a.maxhp - a.hp].min
      a.hp += heal
      "鲜美无比！吃完浑身是劲。（气血回复#{heal}）"
    end
  end
end

WebMod.common_event 29, '使用-漂流瓶' do |c|
  c.say 'WebLife.bottle_text'
end
{ 30 => '吃鳜鱼', 31 => '吃石斑鱼', 32 => '吃红鲷' }.each do |id, name|
  WebMod.common_event id, name do |c|
    c.say 'WebLife.eat(:rare)'
  end
end
WebMod.common_event 33, '吃金鲤' do |c|
  c.say 'WebLife.eat(:gold)'
end
# 放生：乌龟、锦鲤（道德 +3 / +5）
{ 34 => ['放生乌龟', 3, '你把老乌龟放回荷塘，它慢吞吞地划了几下水，回头看了你一眼，沉了下去。'],
  35 => ['放生锦鲤', 5, '你把锦鲤放回塘里，它摆了摆尾巴，在你脚边绕了三圈才游走。都说锦鲤报恩，也许会有好运吧。'] }.each do |id, (name, good, text)|
  WebMod.common_event id, name do |c|
    c.reward morality: good
    c.text text
  end
end
WebMod.common_event 36, '吃哲罗鲑' do |c|
  c.say "WebLife.eat(:gold, '哲罗鲑')"
end

#--------------------------------------------------------------------------
# 结局称号“钓圣”：渔技 9 级、十二种鱼都钓到过；走完正邪路线的仍用路线称号
#--------------------------------------------------------------------------
$end_com.push('钓圣') unless $end_com.include?('钓圣')
class << WebRoute
  alias __yy_title_index title_index
  def title_index(i)
    j = __yy_title_index(i)
    return j if j != i
    WebLife.skill_level >= 9 && WebLife.species_caught >= WebLife::FISH.size ? $end_com.index('钓圣') : i
  end
end

#--------------------------------------------------------------------------
# 能吃的稀罕鱼归到物品栏的“食物”里（原版 012 Data_String 按编号分类：1～7、17 是食物，其余新物品都算“其他”）
#--------------------------------------------------------------------------
class RPG::Item
  EDIBLE_FISH = [32, 33, 37, 38, 51]
  alias __yy_type type
  def type
    EDIBLE_FISH.include?(id) ? 0 : __yy_type
  end
end
