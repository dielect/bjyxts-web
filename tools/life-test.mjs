// 生活玩法（src/game/web_life.rb、mods/110）的回归测试：日历、钓鱼、钓竿、鱼谱、熟客、订单、存档。
//   node tools/life-test.mjs
// 对话流程在浏览器里验证。读的是构建产物，改完先运行 python3 tools/build.py --fast。
import { bootGame } from './headless-game.mjs';

const rb = await bootGame();
const out = rb(String.raw`
errs = []
check = lambda { |cond, msg| errs << msg unless cond }
L = WebLife
a = $game_actors[1]
fresh = lambda do
  $game_system.instance_variable_set(:@web_life, nil)
  $game_variables[157] = 14; $game_variables[158] = 0
  a.equip(7, 0)
end

# ---------------------------------------------------------------- 日历（原版：一年 3000，一季 750）
fresh.call
check.call(L.day == 0 && L.season == 0 && L.season_name == '春', '14 岁年初是第 0 天、春')
$game_variables[158] = 750
check.call(L.season == 1 && L.day == 90, "睡一觉（+750）正好换季：第 #{L.day} 天、#{L.season_name}")
$game_variables[158] = 2999
check.call(L.season == 3, '年末是冬')
$game_variables[157] = 15; $game_variables[158] = 0
check.call(L.day == 360 && L.season == 0, '满一年是第 360 天')

# ---------------------------------------------------------------- 鱼的数据
check.call(L::FISH.size == 22 && L::WATERS.size == 5, "鱼的种类：#{L::FISH.size}")
L::FISH.each_key { |id| check.call($data_items[id] && $data_items[id].name == L::FISH[id][:name], "鱼 #{id} 没有对应物品") }
((28..38).to_a + (42..51).to_a).each { |id| check.call($data_items[id].common_event_id != 18, "新鱼 #{id} 不能用鲤鱼的公共事件（它写死扣鲤鱼）") }
check.call([32, 33, 37, 38].all? { |id| $data_items[id].common_event_id.between?(30, 33) } && $data_items[28].common_event_id == 0, '稀罕鱼能吃（各有自己的公共事件），普通鱼不能')
[:pond, :sea, :lotus, :stream].each do |w|
  4.times { |s| $game_variables[158] = s * 750; check.call(!L.candidates(w).empty?, "#{w} 在#{L.season_name}季没有鱼") }
end
4.times { |s| $game_variables[158] = s * 750; check.call(L.candidates(:ice).empty? == (s != 3), "冰溪只有冬天有鱼（#{L.season_name}）") }

# ---------------------------------------------------------------- 钓竿
check.call(L.rod.nil?, '没装钓竿')
a.equip(7, 31)
check.call(L.rod && L.rod_entry == {} && L.rod_lines(31) == ['【钓竿】普通'], '原版钓竿')
(107..112).each { |id| check.call($data_armors[id].kind == 6 && L::RODS[id], "钓竿 #{id} 的部位或效果") }
fresh.call; a.equip(7, 31)
base = L.bite_chance(false)
a.equip(7, 108)
check.call(L.bite_chance(false) == base + 8, '柳木钓竿咬钩 +8')
a.equip(7, 110)
L.instance_variable_set(:@water, :sea);  sea = L.bite_chance(false)
L.instance_variable_set(:@water, :pond); pond = L.bite_chance(false)
check.call(sea == base + 10 && pond == base - 10, "海竿：海上 #{sea}，鱼塘 #{pond}")
# 龙须钓竿：难得一见的鱼明显变多（统计）
count_legend = lambda { |rod| a.equip(7, rod); $game_variables[158] = 0; 3000.times.count { (f = L.roll(:pond)) && f[:rarity] == 3 } }
plain = count_legend.call(31); dragon = count_legend.call(112)
check.call(dragon > plain * 2, "龙须钓竿的金鲤：#{plain} → #{dragon}")
# 乌金钓竿：鱼更大
a.equip(7, 111); f = L::FISH[28]
sizes = 200.times.map { L.land(f)[1] }
check.call(sizes.max > 10, "乌金钓竿的鲫鱼最大 #{sizes.max} 两（原本最多 10 两）")

# ---------------------------------------------------------------- 钓鱼流程与鱼谱
fresh.call; a.equip(7, 31)
L.start_cast(:pond, false)
check.call([0, 1].include?($game_variables[9]), '下竿后变量 9 是 0 或 1')
srand(1)
landed = 0
200.times do
  L.data[:stock] = {}                                         # 只测流程，不让鱼情影响
  L.start_cast(:pond, false)
  next unless $game_variables[9] == 1
  L.hook(false)
  next unless $game_variables[9] == 2
  L.land_and_text; landed += 1
end
check.call(landed > 60, "两百竿钓上 #{landed} 条")
check.call(L.species_caught >= 2 && L.skill > 0, "鱼谱 #{L.species_caught} 种，熟练度 #{L.skill}")
check.call(L.data[:fish].values.all? { |n, w| n > 0 && w > 0 }, '鱼谱记了条数和最大重量')
check.call(L::FISH.keys.sum { |id| $game_party.item_number(id) } >= landed * 0.8, '钓上来的鱼大都进了背包（少数被水鸟叼走）')
# 香饵：用一个少一个
$game_party.gain_item(39, 2)
L.start_cast(:pond, true)
check.call($game_party.item_number(39) == 1, '用香饵扣一个')

# ---------------------------------------------------------------- 熟客荷西
fresh.call
29.upto(38) { |id| $game_party.lose_item(id, 99) }
$game_party.lose_item(28, 99); $game_party.lose_item(17, 99)
check.call(L.jose_title == '客官', '一开始叫客官')
check.call(L.show_jose.include?('一条鱼也没有'), '身上没鱼时说没鱼，不是“都见过”')
$game_party.gain_item(28, 1); $game_party.gain_item(29, 1)
L.show_jose
check.call(L.jose[:favor] == 2 && L.jose_gift? && L.jose_title =~ /小(兄弟|姑娘)/, "给看两种新鱼：交情 #{L.jose[:favor]}，称呼 #{L.jose_title}")
check.call(L.jose_gift_text.include?('厨子') && L.flag?(:cook_intro), '交情 2 介绍厨师')
check.call(L.jose[:favor] == 2, '看过的鱼不再加交情')
check.call(L.show_jose.include?('都见过'), '身上的鱼都给他看过了才说“都见过”')
[30, 31, 32].each { |id| $game_party.gain_item(id, 1) }
n = $game_party.item_number(39); L.show_jose; L.jose_gift_text
check.call(L.jose[:favor] == 5 && $game_party.item_number(39) == n + 10, '交情 5 送十个香饵')
[33, 34, 35].each { |id| $game_party.gain_item(id, 1) }
L.show_jose
check.call(L.jose_gift? && L.jose_gift_text.include?('斑竹') && L.jose_rod == 107 && L.jose_rod.nil?, '交情 8 送斑竹钓竿（事件里发放，取一次就清掉）')
check.call(!L.dragon_rod_due?, '还没给看全十二种')
# 一次跨过好几档：每档的礼物都要给到（之前只给最高一档，漏了介绍厨师）
L::FISH.each_key { |id| $game_party.lose_item(id, 99) }
saved = L.jose.dup; L.jose[:favor] = 0; L.jose[:shown] = []; L.data[:flags].delete(:cook_intro)
[28, 29, 30, 31, 32].each { |id| $game_party.gain_item(id, 1) }
L.show_jose
texts = []; texts << L.jose_gift_text while L.jose_gift?
check.call(texts.size == 2 && L.flag?(:cook_intro), "交情 0→5：应依次给介绍厨师和香饵，实际 #{texts.size} 档")
L.data[:clients][:jose] = saved
[36, 37, 38, 17, *(42..51)].each { |id| $game_party.gain_item(id, 1) }
L.show_jose
check.call(L.dragon_rod_due?, '所有鱼都看过，该送龙须钓竿')
L.set_flag(:dragon_rod)
check.call(!L.dragon_rod_due?, '龙须钓竿只送一次')

# ---------------------------------------------------------------- 客栈订单
fresh.call
check.call(L.new_order(:cook).nil?, '没钓到过鱼时不出单')
L.land(L::FISH[28])
L.new_order(:cook)
o = L.order
check.call(o && o[:item] == 28 && o[:qty].between?(5, 6) && o[:pay] > 0, "订单：#{o.inspect}")
$game_party.lose_item(28, 99)
check.call(!L.order_ready?, '鱼不够不能交')
$game_party.gain_item(28, o[:qty])
check.call(L.order_ready?, '鱼够了可以交')
g = $game_party.gold
L.cook_done_text
check.call(L.order.nil? && $game_party.gold == g + o[:pay] && $game_party.item_number(28) == 0 && L.cook[:done] == 1, '交单：收鱼、给钱、计数')
check.call(L.cook[:served] == [28], '记下供过的鱼（菜牌用）')
L.new_order(:cook); L.cancel_order
check.call(L.order.nil?, '可以退单')
L.cook[:done] = 3
check.call(L.menu_ready? && L.menu_text.include?('鲫鱼'), "菜牌：#{L.menu_text}")

# ---------------------------------------------------------------- 存档：随 $game_system 保存；旧存档没有数据时自动建好
fresh.call
L.land(L::FISH[33]); L.set_flag(:x)
copy = Marshal.load(Marshal.dump($game_system))
d = copy.instance_variable_get(:@web_life)
check.call(d[:fish][33][0] == 1 && d[:flags][:x], '存档往返后鱼谱和标记都在')
check.call(Marshal.dump(d) !~ /WebLife/, '存档数据里只有基本类型（导回 PC 原版也能读）')
$game_system.instance_variable_set(:@web_life, nil)
check.call(L.data[:v] == L::VERSION && L.data[:fish] == {}, '旧存档：第一次用时建好空数据')

# ---------------------------------------------------------------- 摆摊的奇遇：碰过以后留在原地，货郎的货不变
$game_map.setup(1); $game_player = Game_Player.new; $game_player.moveto(10, 10)
WebEncounter.spawn(WebEncounter.list[11])
s1 = WebJianghu.peddler_stock
WebEncounter.claim(11)
WebEncounter.update
check.call(WebEncounter.figure && $game_map.events[WebEncounter::FIGURE_ID] && !$game_map.events[WebEncounter::FIGURE_ID].instance_variable_get(:@erased), '货郎碰过以后还在')
check.call(WebJianghu.peddler_stock == s1, '同一次出现的货不变')
t = WebEncounter.total
WebEncounter.claim(11)
check.call(WebEncounter.total == t, '再找货郎不重复计数')
60.times { WebEncounter.step }
$game_player.moveto(30, 30); WebEncounter.update
check.call(WebEncounter.figure, '摆摊的走远、走久都不回收')
$game_map.setup(12); WebEncounter.update
check.call(WebEncounter.figure.nil?, '换了地图回收')

# ---------------------------------------------------------------- 鱼情：连着钓会钓怕，过日子恢复，睡一觉全恢复
fresh.call; a.equip(7, 31)
L.instance_variable_set(:@water, :pond)
full = L.bite_chance(false)
12.times { L.land(L::FISH[28]) }
check.call(L.stock(:pond) < 10 && L.bite_chance(false) < full / 2, "连钓十二条鲫鱼：鱼情 #{L.stock(:pond)}，咬钩 #{full} → #{L.bite_chance(false)}")
check.call(L.no_bite_text.include?('钓怕'), '鱼情差时提示换地方')
check.call(L.stock(:sea) == 100, '海里不受鱼塘影响')
$game_variables[158] += 83                                    # 过十天
check.call(L.stock(:pond).between?(40, 50), "过十天恢复：#{L.stock(:pond)}")
$game_variables[158] += 750                                   # 睡一觉
check.call(L.stock(:pond) == 100, '睡一觉全恢复')

# ---------------------------------------------------------------- 小插曲
fresh.call; a.equip(7, 31)
L.instance_variable_set(:@water, :pond)
srand(3)
seen = Hash.new(0)
600.times { L.data[:stock] = {}; L.start_cast(:pond, false); seen[L.interlude] += 1 if L.interlude }
check.call(seen.values.sum.between?(80, 160), "六百竿里小插曲 #{seen.values.sum} 次：#{seen.inspect}")
check.call(!seen.key?(:gulls) && !seen.key?(:crack), '鱼塘没有海鸥、冰面')
L.data[:stock] = {}
L.instance_variable_set(:@interlude, :tangle)
# 缠线：这一竿一定没鱼
100.times { L.data[:stock] = {}; L.start_cast(:pond, false); check.call($game_variables[9] == 0, '缠住水草时不会咬钩') if L.interlude == :tangle }
# 下雨：咬钩更多，管一天
L.instance_variable_set(:@rain_until, -1); dry = L.bite_chance(false)
L.instance_variable_set(:@rain_until, L.ticks + 8); wet = L.bite_chance(false)
check.call(wet > dry, "下雨咬钩 #{dry} → #{wet}")
$game_variables[158] += 9
check.call(L.bite_chance(false) == dry, '过了一天雨停了')
# 喂猫
$game_party.gain_item(46, 1); $game_party.gain_item(45, 1); m0 = $game_variables[160]; k0 = $game_party.item_number(45); w0 = $game_party.item_number(46)
t = L.feed_cat
check.call(t.include?('白条') && $game_party.item_number(45) == k0 && $game_party.item_number(46) == w0 - 1 && $game_variables[160] == [m0 + 1, 255].min, "喂猫给最便宜的鱼：#{t}")
# 冰溪不在冬天
$game_variables[158] = 0; L.start_cast(:ice, false)
check.call($game_variables[9] == 5 && L.off_season_text.include?('冬天'), '冰溪春天钓不了')

# ---------------------------------------------------------------- 渔隐
fresh.call
# 钓出东西：水贼要渔技 3 级以上
L.data[:skill][:fishing] = 0
kinds = 2000.times.map { L.junk_roll(:pond) }.compact
check.call(!kinds.empty? && !kinds.include?(:bandit), "渔技 1 级不会钓上水贼：#{kinds.tally.inspect}")
L.data[:skill][:fishing] = 30
kinds = 3000.times.map { L.junk_roll(:pond) }.compact
check.call(kinds.include?(:bandit) && kinds.size.between?(250, 470), "渔技 3 级的杂物：共 #{kinds.size} 次 #{kinds.tally.inspect}")
n = $game_party.weapon_number(20)
L.instance_variable_set(:@junk, :sword); L.junk_text
check.call($game_party.weapon_number(20) == n + 1, '钓上锈剑')
L.instance_variable_set(:@junk, :bottle); L.junk_text
check.call($game_party.item_number(41) >= 1, '钓上漂流瓶')
# 漂流瓶：一条没听过的传闻
RUMORS.each { |sw, *| $game_switches[sw] = false }
$game_variables[19] = 10000
t = L.bottle_text
check.call(t.start_with?('纸条上') && RUMORS.count { |sw, *| $game_switches[sw] } == 1, "漂流瓶：#{t}")
# 经验：稀罕鱼给实战经验，并同步校验值
$game_variables[19] = 100000; $game_variables[152] = Zlib.crc32('100000', 51)
L.land(L::FISH[32])
check.call($game_variables[19] == 100040 && $game_variables[152] == Zlib.crc32('100040', 51), "鳜鱼给 40 经验：#{$game_variables[19]}")
# 钓鱼练功：只有拿着兵器鱼竿、学过太公钓法才长；规则同原版，受经验上限
$game_variables[90] = 0; $game_variables[150] = 0
a.equip(0, 0); L.land(L::FISH[28])
check.call($game_variables[150] == 0, '没学太公钓法不长')
$game_variables[90] = 1
L.land(L::FISH[28])
check.call($game_variables[150] == 0, '没拿兵器鱼竿不长')
a.equip(0, 74); $game_variables[13] = 20; $game_variables[48] = 0; $game_variables[93] = 0
check.call(L.rod && L.rod_fx(:bite) == 5, '兵器鱼竿也能钓鱼')
30.times { L.land(L::FISH[28]) }
check.call($game_variables[90] > 1, "钓三十条鲫鱼，太公钓法 1 → #{$game_variables[90]}")
$game_variables[19] = 0
lv = $game_variables[90]
200.times { L.land(L::FISH[28]) }
check.call($game_variables[90] == lv, "经验不够时太公钓法不再升级（原版的经验上限）：#{lv} → #{$game_variables[90]}")
a.equip(0, 0)
# 称号与结局
L.data[:skill][:fishing] = 0
check.call(L.title == '渔童', '渔技 1 级叫渔童')
L.data[:skill][:fishing] = 250
check.call(L.title == '钓圣' && L.skill_level == 9, "渔技 9 级：#{L.title}")
L::FISH.each_key { |id| L.data[:fish][id] = [1, 1] }
(142..149).each { |i| $game_switches[i] = false }
check.call($end_com[WebRoute.title_index(0)] == '钓圣', '渔技 9 级、十二种鱼：结局称号钓圣')
$game_switches[142] = true; $game_switches[145] = true
check.call($end_com[WebRoute.title_index(0)] == '天下名捕', '走完正邪路线的仍用路线称号')
$game_switches[142] = false; $game_switches[145] = false
# 渔樵套 4 件：太公钓法战斗中 +20
a.equip(2, 32); a.equip(3, 72); a.equip(7, 31); a.equip(0, 74)
check.call(WebGear.set_count(WebGear.sets[:渔樵]) == 4, '斗笠、蓑衣、钓竿、兵器鱼竿算 4 件')
check.call(WebGear.of(:level).any? { |e| e[:skill] == 90 && e[:n] == 20 }, '4 件：太公钓法 +20')
a.equip(2, 0); a.equip(3, 0); a.equip(7, 0); a.equip(0, 0)
# 吃鱼
$game_variables[24] = 100; $game_variables[15] = 0; $game_variables[16] = 500
L.eat(:gold)
check.call($game_variables[24] == 130 && $game_variables[15] > 0, '吃金鲤：内力修为 +30、填饱肚子')
# 绝招数据
check.call($data_skills[30].name == '愿者上钩' && $data_skills[31].name == '鲤跃龙门' && WebSkill::PERFORMS[90] == [30, 31], '太公钓法的绝招')
check.call([32, 33, 37, 38].all? { |id| $data_items[id].type == 0 } && $data_items[28].type == 2, '能吃的鱼在物品栏的“食物”里')
check.call(WebSkill.category(90) == WebSkill::WEAPON && WebSkill.base_of(90) == 44, '太公钓法是鞭类兵刃')

# ---------------------------------------------------------------- 厨子
fresh.call
check.call(L::RECIPES.size == 14 && [*52..63, 80, 81].all? { |id| $data_items[id].type == 0 && $data_common_events[$data_items[id].common_event_id].name.start_with?('吃-') }, '十二道菜：归食物，各有吃的公共事件')
check.call(L::RECIPES.values.all? { |r| r[:needs].keys.all? { |i| $data_items[i] } && r[:fx].all? { |e| !WebGear.describe(e).empty? } }, '菜谱的食材和增益都有效')
# 入行：交满三单鱼
check.call(!L.kitchen? && !L.kitchen_offer_due?, '没交单不能入行')
L.cook[:done] = 3
check.call(L.kitchen_offer_due?, '交满三单可以入行')
t = L.open_kitchen
check.call(L.kitchen? && [52, 53, 54, 55].all? { |id| L.known?(id) } && t.include?('鸡汤'), "入行学会四道家常菜：#{t}")
# 做菜：都对 → 极品两份；都不对 → 普通一份；食材扣掉
$game_party.gain_item(5, 4)
srand(7)
L.data[:skill][:cooking] = 0
q, n, text = L.cook_dish(54, 2, 2)
check.call(q == 2 && n == 2 && $game_party.item_number(54) == 2 && $game_party.item_number(5) == 2, "红烧肉先武后文、重口：#{text}")
q, n, = L.cook_dish(54, 0, 0)
check.call(q == 0 && n == 1 && $game_party.item_number(5) == 0, '都不对出普通一份')
check.call(!L.can_cook?(54), '猪肉用完就不能做了')
check.call(L.cook_skill > 0 && L.cook_title == '学徒', "厨艺：#{L.cook_skill}")
# 吃菜：增益接进战斗，按场数用完，后吃的覆盖
a.equip(0, 0); a.instance_variable_set(:@armor1_id, 0)
before = WebGear.of(:power).size
t = L.eat_dish(54)
check.call(WebGear.of(:power).size == before + 1 && t.include?('2场'), "吃红烧肉：#{t}")
L.meal_battle_done
check.call(WebGear.of(:power).size == before + 1, '打完一场还剩一场')
L.meal_battle_done
check.call(WebGear.of(:power).size == before && L.cook_data[:meal].nil?, '两场后增益用完')
L.eat_dish(54); L.eat_dish(55)
check.call(WebGear.of(:power).size == before && WebGear.of(:regen).any?, '后吃的鸡汤覆盖红烧肉')
L.cook_data[:meal] = nil
# 其他菜谱来源
check.call(L.jose_recipes_due? && L.jose_recipes.include?('干煎带鱼') && !L.jose_recipes_due?, '荷西教海鲜，只一次')
L.cook[:dishes] = 2
check.call(L.cook_advanced_due? && L.cook_advanced.include?('清蒸鳜鱼') && L.known?(62), '交过两单菜，厨师教清蒸鳜鱼、酥油茶煮雪鱼')
# 订单收菜（先钓一条，让收鱼单也开得出来）
L.land(L::FISH[28])
srand(1)
dish_orders = 20.times.map { L.cook_offer_text; o = L.order; L.cancel_order; o[:dish] }.count(true)
check.call(dish_orders.between?(4, 16), "入行后订单约一半是菜：#{dish_orders}/20")
L.new_dish_order; o = L.order
$game_party.gain_item(o[:item], o[:qty])
L.cook_done_text
check.call(L.cook[:dishes] == 3 && L.menu_text.include?($data_items[o[:item]].name), "交菜计数、菜牌上有你做的菜：#{L.menu_text}")
# 熟客独行大侠：不点辣的；三次后远行，二十天后带香料；六次后介绍朋友
L.learn(56, 61)
check.call(30.times.all? { L.sword[:want] = nil; !L::RECIPES[L.sword_want][:spicy] }, '独行大侠从不点辣菜')
L.cook_data[:recipes] -= [56, 61]
3.times do
  w = L.sword_want; $game_party.gain_item(w, 1)
  check.call(L.sword_can_serve?, '有他想吃的菜就能端上去')
  L.serve_sword
end
check.call(L.sword[:away] && !L.sword_can_serve? && L.sword_line.include?('出趟远门'), '吃了三次后出远门')
$game_variables[158] += 170                                    # 二十天
t = L.sword_line
check.call(t.include?('香料') && L.known?(56) && L.known?(61) && $game_party.item_number(64) >= 3, "回来带香料、学会香辣菜：#{t}")
check.call(L.sword_line.include?('不要辣'), '记得他不吃辣')
3.times { w = L.sword_want; $game_party.gain_item(w, 1); L.serve_sword }
check.call(L.flag?(:sword_friends), '吃了六次后介绍朋友')
L.new_dish_order
check.call(L.order[:pay] >= $data_items[L.order[:item]].price * L.order[:qty] * 2, '介绍朋友后菜单报酬更高')
L.cancel_order
# 漂流瓶里的方子
srand(5)
40.times { break if L.known?(63); L.bottle_text }
check.call(L.known?(63), '漂流瓶偶尔有八宝鱼翅的方子')

# ---------------------------------------------------------------- 钓位一定挨着水（之前误把柳树当成水塘）
WATER = [697, 570, 808, 686, 677, 683, 691, 693, 675, 685, 694]
spots = []
$data_mapinfos.keys.each do |mid|
  m = load_data(format('/game/Data/Map%03d.rxdata', mid))
  m.events.each_value do |e|
    is_spot = e.name == '钓位' || (mid == 13 && [8, 9].include?(e.id))
    spots << [mid, e.x, e.y] if is_spot
  end
end
spots.each do |mid, x, y|
  m = load_data(format('/game/Data/Map%03d.rxdata', mid))
  near = [[0, 0], [0, 1], [0, -1], [1, 0], [-1, 0]].any? { |dx, dy| (0..2).any? { |z| WATER.include?(m.data[x + dx, y + dy, z]) } }
  check.call(near, "地图 #{mid} 的钓位（#{x},#{y}）旁边没有水")
end
check.call(spots.size >= 10, "钓位数量 #{spots.size}")

# ---------------------------------------------------------------- 樵夫
fresh.call
L.data[:stock] = {}
a.equip(0, 0)
check.call(!L.axe?, '没拿斧头')
a.equip(0, 76)
check.call(L.axe?, '柴刀是斧头')
L::FORESTS.each_key { |f| 4.times { |s| $game_variables[158] = s * 750; check.call(L::WOODS.values.any? { |w| w[:forest] == f && w[:seasons].include?(L.season) }, "#{f} 在#{L.season_name}季没有树") } }
$game_variables[158] = 0
srand(2)
L.start_chop(:wudang)
check.call($game_variables[9] == 1 && L.tree_prompt.include?('怎么下斧'), '武当山脚可以砍')
w = L.instance_variable_get(:@tree)
n0 = $game_party.item_number(w[:item])
L.chop(w[:cut])
check.call($game_party.item_number(w[:item]) == n0 + 2 && L.wood_skill > 0, "下对斧多得一根：#{w[:name]}")
L.start_chop(:wudang); w = L.instance_variable_get(:@tree); n0 = $game_party.item_number(w[:item])
L.chop((w[:cut] + 1) % 3)
check.call($game_party.item_number(w[:item]) == n0 + 1, '下错斧只得一根')
20.times { L.start_chop(:wudang); L.chop(0) if $game_variables[9] == 1 }
L.start_chop(:wudang)
check.call($game_variables[9] == 5 && L.bald_text.include?('砍秃'), '砍多了林子秃了')
L.data[:stock] = {}
# 山货：樵夫套 5 件多一份
got = 300.times.map { L.instance_variable_set(:@forest, :wudang); L.gather }.reject(&:empty?)
check.call(got.size > 30, "砍三百次采到山货 #{got.size} 次")
a.equip(1, 39); a.equip(3, 113); a.equip(2, 115); a.equip(5, 114)
check.call(WebGear.set_count(WebGear.sets[:樵夫]) == 5 && WebGear.value(:gather_more) > 0, '樵夫套 5 件：采山货多一份')
a.equip(1, 0); a.equip(3, 0); a.equip(2, 0); a.equip(5, 0)
# 攀山步：学过、拿着斧头砍柴才长；绝招要拿斧头
$game_variables[19] = 2000000; $game_variables[71] = 1; $game_variables[131] = 0
10.times { L.data[:stock] = {}; L.start_chop(:basin); L.chop(0) if $game_variables[9] == 1 }
check.call($game_variables[71] > 1, "砍柴练攀山步：#{$game_variables[71]}")
check.call(WebSkill.category(71) == WebSkill::MOVE && WebSkill.base_of(71) == 46 && WebSkill::PERFORMS[71] == [32, 33, 34], '攀山步是轻功，带三个斧法绝招')
$game_variables[31] = 71
dt = draw_defend_text($game_actors[1], Struct.new(:name).new("山豹")) rescue "ERR #{$!.message}"
check.call(dt.start_with?('你') && dt.include?('|'), "启用攀山步时有闪避描述：#{dt}")
$game_variables[71] = 80; $game_variables[42] = 80; $game_actors[1].equip(0, 77)
study_skill
check.call($game_actors[1].skills.include?(32) && $game_actors[1].skills.include?(33), "启用攀山步学会斧法绝招：#{$game_actors[1].skills.inspect}")
$game_variables[31] = 0
study_skill
check.call(WebSkill.requirements_for(32, nil).none? { |_, lv| lv == 9999 }, '拿着斧头时开山一斧没有额外限制')
a.equip(0, 0)
check.call(WebSkill.requirements_for(32, nil).any? { |_, lv| lv == 9999 }, '没拿斧头使不出开山一斧')
a.equip(0, 76)
# 入行：老婆婆劈柴满三次送柴刀
L.data[:chores] = 2
n0 = $game_party.weapon_number(76)
Object.class_eval { def __wood_task3; end; def __wood_finishtask; end }   # 原版那部分会开窗口画字，这里只测新加的逻辑
class Window_Base; def initialize(*) ; end; def contents=(*); end; def contents; Bitmap.new(1, 1); end; def dispose; end; end
def Graphics.update; end
task3
finishtask
check.call(L.data[:chores] == 3 && L.flag?(:axe) && $game_party.weapon_number(76) == n0 + 1, "劈柴满三次送柴刀（劈了 #{L.data[:chores]} 次）")
# 好柴入厨
L.learn(54); $game_party.gain_item(5, 2); $game_party.gain_item(67, 1); fuel0 = $game_party.item_number(67)
q, n, t = L.cook_dish(54, 2, 2)
check.call($game_party.item_number(67) == fuel0 - 1 && t.include?('松木'), "做菜添好柴：#{t}")
# 客栈收木柴
L.set_flag(:kitchen)
orders = 40.times.map { L.cook_offer_text; o = L.order; L.cancel_order; o && o[:wood] }.count(true)
check.call(orders.between?(4, 20), "砍过柴后约四分之一是收木柴：#{orders}/40")
# 称号
L.data[:skill][:wood] = 250
check.call(L.wood_title == '樵隐', "樵技 9 级：#{L.wood_title}")
# ---- 护林：开头、一个月后神木倒下
$game_variables[71] = 1
check.call(L.grove_start_due?, '学了攀山步、樵技 6 级以上，歌樵子说起护林')
L.grove_start
check.call(L.grove_stage == :crew && $game_switches[151] && !L.grove_start_due? && L.tree_text.include?('锯出'), '护林开始：伐木队上山')
L.grove_tick
check.call(L.grove_stage == :crew, '一个月内神木还在')
$game_variables[158] += 251
L.grove_tick
check.call(L.grove_stage == :fallen && !$game_switches[151] && $game_switches[152] && L.grove_fallen_due? && !L.grove_reward_due?, '一个月没人管，神木倒了')
# ---- 凑梁木：护林（生活）
L.data[:grove] = {}; L.data[:flags].delete(:tiefu); $game_switches[152] = false
L.grove_start
check.call(!L.beams_ready?, '梁木不够')
$game_party.gain_item(70, 3); $game_party.gain_item(71, 2)
g0 = $game_party.gold
t = L.grove_beams
check.call(L.grove_stage == :beams && !$game_switches[151] && !$game_switches[152] && $game_party.gold - g0 == (150 * 3 + 200 * 2) * 3 / 2 && $game_party.item_number(70) == 0, "凑够梁木：#{t}")
check.call(L.grove_reward_due? && L.grove_praise.include?('楠木'), '护住神木后歌樵子传功')
# 铁斧断岳：传了才有，要拿斧头
$game_variables[31] = 71; $game_variables[71] = 130; $game_variables[42] = 130; a.equip(0, 77)
study_skill
check.call(!a.skills.include?(34), '没传之前学不到铁斧断岳')
L.grove_reward
check.call(a.skills.include?(34) && $game_party.item_number(82) == 1 && !L.grove_reward_due?, '传铁斧断岳、给铁木心')
check.call(WebSkill.requirements_for(34, nil).none? { |_, lv| lv == 9999 }, '拿斧头能使铁斧断岳')
a.equip(0, 0)
check.call(WebSkill.requirements_for(34, nil).any? { |_, lv| lv == 9999 }, '空手使不出铁斧断岳')
$game_variables[31] = 0; study_skill
# 管事收好木料（凑过梁木的多给两成）
$game_party.gain_item(73, 1); g0 = $game_party.gold
t = L.steward_buy
check.call($game_party.gold - g0 == 1800 && $game_party.item_number(73) == 0, "管事高价收沉香木：#{t}")
# 铁木神斧：铁木心 + 斧头，三天
check.call(L.forge_offer?, '有铁木心，歌樵子提出打斧')
$game_party.gain_weapon(77, 1)
check.call(L.forge_axe == 77, '开山斧当胚子')
L.forge_start
check.call(L.forging? && !L.forge_ready? && !L.forge_offer? && $game_party.item_number(82) == 0, '斧子在打')
$game_variables[158] += 26
check.call(L.forge_ready?, '三天后打好')
w0 = $game_party.weapon_number(79)
L.forge_give
check.call($game_party.weapon_number(79) == w0 + 1 && !L.forge_offer? && !L.forge_ready? && L.axe? == false, '得到铁木神斧')
a.equip(0, 79)
check.call(L.axe? && WebGear.set_count(WebGear.sets[:樵夫]) >= 1, '铁木神斧算斧头、算樵夫套')
a.equip(0, 0)
# ---- 帮商家堡砍树
L.data[:grove] = {}; L.data[:flags].delete(:tiefu); $game_switches[152] = false
L.grove_start
g0 = $game_party.gold
L.grove_sell
check.call(L.grove_stage == :sold && $game_switches[152] && $game_party.gold - g0 == 5000 && L.steward_rate == 1.5 && !L.grove_reward_due?, '帮商家堡砍树：五千两，以后高价收木料，不传功')
check.call(L.tree_text.include?('树墩') && L.geqiao_cold.size > 0, '只剩树墩，歌樵子不理人')
# ---- 宣花大斧奇遇的条件
a.equip(0, 77)
e29 = WebEncounter.list[29]
check.call(e29 && e29[:cond].call, '拿斧头、学过攀山步时可能遇到宣花大斧')
L.set_flag(:xuanhua)
check.call(!e29[:cond].call, '拿到宣花大斧后不再遇到')
a.equip(0, 0)
a.equip(0, 0)

# ---------------------------------------------------------------- 书生
fresh.call
$game_switches.instance_variable_get(:@data).fill(false) rescue nil
$game_variables[48] = 1; $game_variables[13] = 20; $game_variables[19] = 3000000
check.call(!L.scholar?, '没入行')
L.enter_scholar
check.call(L.scholar? && $game_party.item_number(102) == 1 && $game_party.item_number(83) >= 1, '入行：书目、三字经')
check.call(L::BOOKS.size == 21 && L::BOOKS.values.all? { |b| b[:quiz].all? { |q, o| o.size == 3 && WebMod.message_rows(q) == 1 } }, '二十一本书，小题都是一行三个选项')
check.call(L::BOOKS.keys.all? { |id| $data_items[id].common_event_id == 53 && !$data_items[id].consumable }, '书在物品栏里打开就读，不会读掉')
# 读一章
$web_used_item = 85
L.start_read
L.instance_variable_set(:@read_interlude, nil); L.instance_variable_set(:@quiz, nil)
art0 = $game_variables[48]
t = L.read_chapter
check.call(L.books_read[85] == 1 && L.book_skill > 0 && t.include?('第1章'), "读一章：#{t}")
check.call($game_variables[48] > art0, "读书长读书识字：#{art0} → #{$game_variables[48]}")
# 小题：选项打乱，答对多读一章
L.instance_variable_set(:@quiz, L::BOOKS[85][:quiz][0])
q = L.quiz_text
right = WebMod.choice_labels.index('不亦说乎')
check.call(q.include?('学而时习之') && WebMod.choice_labels.sort == %w[不亦说乎 不亦乐乎 人不知而不愠].sort, '小题的选项')
check.call(L.answer(right).include?('对了'), '答对了')
L.instance_variable_set(:@read_interlude, nil)
L.read_chapter
check.call(L.books_read[85] == 3, "答对多读一章：#{L.books_read[85]}")
L.instance_variable_set(:@quiz, L::BOOKS[85][:quiz][1]); L.quiz_text
check.call(L.answer((WebMod.choice_labels.index('必有我师焉') + 1) % 3).include?('必有我师焉'), '答错告诉你答案')
# 一天六章
check.call(L.eyes_used == 2, "今天读了 #{L.eyes_used} 章")
4.times { L.start_read; L.instance_variable_set(:@read_interlude, nil); L.read_chapter if $game_variables[9] == 1 }
L.start_read
check.call($game_variables[9] == 2 && L.tired_text.include?('明天'), '一天最多六章')
$game_variables[158] += 9
L.start_read
check.call($game_variables[9] == 1, '第二天又能读了')
# 读通的收获：每本都试一遍
L::BOOKS.each do |id, b|
  data_eyes = L.data[:eyes] = nil
  $web_used_item = id
  L.books_read[id] = b[:chapters] - 1
  L.start_read; L.instance_variable_set(:@read_interlude, nil); L.instance_variable_set(:@quiz, nil)
  pot0, moral0, wit0 = $game_variables[20], $game_variables[160], $game_variables[13]
  t = L.read_chapter
  check.call(L.book_done?(id) && t.size > 20, "读通《#{b[:name]}》：#{t}")
  case b[:reward][0]
  when :tale, :pot then check.call($game_variables[20] - pot0 == b[:reward][1], "《#{b[:name]}》给潜能")
  when :wit then check.call($game_variables[13] == wit0 + 1, '易经加悟性')
  when :moral then check.call($game_variables[160] >= moral0, '经书加道德')
  end
end
check.call(L.books_done == L::BOOKS.size, '全部读通')
# 读书识字只读到 100 级
$game_variables[48] = 100
L.data[:eyes] = nil; $web_used_item = 95; L.start_read; L.instance_variable_set(:@read_interlude, nil); L.read_chapter
check.call($game_variables[48] == 100, '读书识字读到 100 级为止')
$game_variables[48] = 1
# 本草纲目读通后草药能用（公共事件 55 判断）
check.call(L.book_done?(92) && $data_items[74].common_event_id == 55, '草药接公共事件 55')
# 书生套 4 件多读两章（原有三件 + 云头履）
a.equip(0, 68); a.equip(2, 49); a.equip(3, 64); a.equip(1, 116)
check.call(L.eyes_max == 8, "书生套 4 件：一天 #{L.eyes_max} 章")
a.equip(0, 0); a.equip(2, 0); a.equip(3, 0); a.equip(1, 0)
# ---- 代写
fresh.call
L.enter_scholar
$game_variables[158] = 0
3.times { L.start_write; check.call($game_variables[9] == 1, '有客人'); L.writ_question; L.write(0) }
L.start_write
check.call($game_variables[9] == 2, '一天最多三位客人')
srand(3)
kinds = 200.times.map { $game_variables[158] += 9; L.start_write; w = L.instance_variable_get(:@writ)[0]; (L.writ_question; L.write(0)) if w == :wang; w }
check.call(!kinds.include?(:couplet1) && !kinds.include?(:love), '不是冬天没有春联，没读诗经没有情书')
check.call(L.wang[:favor] >= 5 && $game_party.armor_number(117) == 1, "王大娘写满五封，儿子回来送玉佩（#{L.wang[:favor]} 封）")
$game_variables[158] = 3 * 750 + 10
L.books_read[87] = L::BOOKS[87][:chapters]
kinds = 200.times.map { $game_variables[158] += 1; L.data[:writes] = nil; L.start_write; L.instance_variable_get(:@writ)[0] }
check.call(kinds.include?(:couplet1) && kinds.include?(:love), '冬天有春联，读过诗经有情书')
L.data[:writes] = nil
L.start_write
q = L.writ_question
right = WebMod.choice_labels.index(L.instance_variable_get(:@writ)[4][0])
g0 = $game_party.gold
L.write(right)
full = $game_party.gold - g0
L.data[:writes] = nil; L.start_write; L.writ_question
L.instance_variable_set(:@writ, L.instance_variable_get(:@writ))
wrong = (L.instance_variable_get(:@writ_answer) + 1) % 3
g0 = $game_party.gold
t = L.write(wrong)
check.call(full > 0 && t.include?('该写'), "写对全价 #{full}，写错打折：#{t}")
check.call(WebMod.message_rows(L::WRITS.map { |w| w[3] }.max_by(&:size)) == 1, '代写的题目都在一行内')
# ---- 一阳书指：代写满十五回送笔阵图，读通学会；代写练功
check.call(WebSkill.category(62) == WebSkill::FIST && WebSkill.base_of(62) == 40 && WebSkill::PERFORMS[62] == [35, 36], '一阳书指是拳脚，带两个绝招')
fresh.call; L.enter_scholar
$game_switches[153] = false
L.data[:writ_total] = 14
check.call(!L.brush_due?, '代写不满十五回')
L.data[:writ_total] = 15
check.call(L.brush_due?, '代写满十五回，顾先生送笔阵图')
L.give_brush
check.call($game_party.item_number(105) == 1 && !L.brush_due?, '得到笔阵图')
$game_variables[62] = 0
L.data[:eyes] = nil; $web_used_item = 105; L.books_read[105] = 3
L.start_read; L.instance_variable_set(:@read_interlude, nil); L.instance_variable_set(:@quiz, nil)
t = L.read_chapter
check.call($game_variables[62] == 1 && t.include?('一阳书指'), "读通笔阵图学会一阳书指：#{t}")
$game_variables[19] = 3000000; $game_variables[122] = 0
10.times { L.data[:writes] = nil; L.start_write; L.writ_question; L.write(L.instance_variable_get(:@writ_answer)) }
check.call($game_variables[62] > 1, "代写练一阳书指：#{$game_variables[62]}")
# 力透纸背：护住先生才传
$game_variables[29] = 62; $game_variables[62] = 130; $game_variables[40] = 130; a.equip(0, 0)
study_skill
check.call(a.skills.include?(35) && !a.skills.include?(36), "空手启用一阳书指学会笔走龙蛇，力透纸背还没传：#{a.skills.inspect}")
# ---- 科举
fresh.call; L.enter_scholar
check.call(!L.exam_ready? && L.exam_info.include?('学识3级'), '学识不够不能考')
L.data[:skill][:book] = 30
$game_variables[158] = 0
check.call(L.exam_ready? && !L.exam_open?, '春天不开考')
$game_variables[158] = 2 * 750
check.call(L.exam_open? && L.exam_kind == '县试' && L.exam_fee == 100, '秋天开县试')
L::BOOKS.values.flat_map { |b| b[:quiz] }.each { |q, _| check.call(WebMod.message_rows("第5题：#{q}") == 1, "考题一行以内：#{q}") }
L::POLICY.each { |q, o| check.call(WebMod.message_rows("第5题：#{q}") == 1 && o.size == 3, "策论题一行以内：#{q}") }
$game_party.gain_gold(1000)
g0 = $game_party.gold
L.exam_begin
5.times { L.exam_question; L.exam_answer(L.instance_variable_get(:@exam_answer)) }
t = L.exam_result
check.call(L.rank_name == '秀才' && $game_party.gold == g0 - 100 && !L.exam_open?, "县试中秀才：#{t}")
$game_variables[158] += 3000
check.call(!L.exam_ready?, '乡试要学识 7 级')
L.data[:skill][:book] = 200
check.call(L.exam_open? && L.exam_kind == '乡试' && L.exam_need == 4, '第二年秋天开乡试，要对四题')
L.exam_begin
5.times { |k| L.exam_question; L.exam_answer(k < 3 ? L.instance_variable_get(:@exam_answer) : (L.instance_variable_get(:@exam_answer) + 1) % 3) }
t = L.exam_result
check.call(L.rank == 1 && t.include?('名落孙山'), "乡试只对三题落榜：#{t}")
L.set_flag(:recommend)
check.call(L.exam_need == 3, '有荐书对三题就行')
$game_variables[158] += 3000
L.exam_begin
5.times { |k| L.exam_question; L.exam_answer(k < 3 ? L.instance_variable_get(:@exam_answer) : (L.instance_variable_get(:@exam_answer) + 1) % 3) }
L.exam_result
check.call(L.rank_name == '举人' && L.rank_rate == 1.6 && !L.stipend_due?, '中举人，当季不领廪银')
$game_variables[158] += 750 * 2
g0 = $game_party.gold
L.take_stipend if L.stipend_due?
check.call($game_party.gold - g0 == 600 && !L.stipend_due?, '过了两季领六百两廪银')
# ---- 禁书
setup_ban = lambda do
  fresh.call; L.enter_scholar
  $game_switches[153] = false; L.data[:flags].delete(:lituo)
  L.data[:skill][:book] = 80
  L::BOOKS.keys.first(6).each { |id| L.books_read[id] = L::BOOKS[id][:chapters] }
end
setup_ban.call
check.call(L.ban_due?, '学识 5 级、读通六本，顾先生说起禁书')
L.ban_start
check.call(L.ban_stage == :search && L.ban_hint.include?('20天'), '二十天后来搜')
# 1 藏书稿：躲过搜查，还给先生
L.ban_carry
check.call($game_party.item_number(103) == 1 && WebEncounter.list[31][:cond].call, '带着书稿，可能被搜身')
$game_variables[158] += 170; L.ban_tick
check.call(L.ban_stage == :searched && L.ban_reward_due? && !$game_switches[153], '搜查扑空')
t = L.ban_reward
check.call(L.ban_stage == :hidden && L.flag?(:lituo) && L.flag?(:recommend) && $game_party.item_number(103) == 0, "还书稿：传力透纸背、写荐书：#{t}")
$game_variables[29] = 62; $game_variables[62] = 130; $game_variables[40] = 130; a.equip(0, 0); study_skill
check.call(a.skills.include?(36), '学会力透纸背')
# 2 抄一份
setup_ban.call; L.ban_start
w0 = $game_variables[164]
L.ban_copy
check.call($game_party.item_number(104) == 1 && L.bookstall_goods.include?([:item, 104]), '抄书：得到日知录，书摊也卖')
$game_variables[158] += 170; L.ban_tick
check.call(L.ban_stage == :spread && L.ban_reward_due?, '先生烧了原稿，官府扑空')
L.ban_reward
check.call(L.flag?(:lituo) && !L.flag?(:recommend), '抄书的也传力透纸背，没有荐书')
# 3 告发
setup_ban.call; L.ban_start
$game_variables[164] = 3; m0 = $game_variables[160]; g0 = $game_party.gold
L.ban_inform
check.call($game_switches[153] && $game_variables[164] == 0 && $game_party.gold - g0 == 2000 && $game_variables[160] == [m0 - 10, 0].max && !L.ban_reward_due?, '告发：两千两，通缉清零，先生被带走')
check.call(!L.ban_ended_line.empty? && !L.yijing_due? && !L.brush_due?, '告发以后书童躲着你，先生不再送书')
$game_variables[158] += 260; L.ban_tick
check.call(!$game_switches[153], '一个月后先生回来了')
# 4 不管
setup_ban.call; L.ban_start
$game_variables[158] += 170; L.ban_tick
check.call(L.ban_stage == :ignored && $game_switches[153] && !L.ban_reward_due?, '不管：到期书稿被搜出，先生被带走')
# 搜身被搜走
setup_ban.call; L.ban_start; L.ban_carry
L.ban_seized
check.call(L.ban_stage == :seized && $game_party.item_number(103) == 0 && $game_switches[153], '搜身被搜走书稿')
$game_switches[153] = false
# ---- 选项文字可以运行时决定；c.say 后面的选项并进同一个对话框
$game_temp.message_text = ''
WebMod.choice_labels = %w[甲 乙 丙]
it = Interpreter.new
it.instance_variable_set(:@list, [RPG::EventCommand.new(355, 0, ['x']), RPG::EventCommand.new(102, 0, [%w[{0} {1} {2}], 5])])
it.instance_variable_set(:@index, 0)
it.web_say('一行的问题？')
check.call($game_temp.choice_max == 3 && $game_temp.message_text.include?("乙\n") && it.instance_variable_get(:@index) == 1, "问题和选项在同一个对话框：#{$game_temp.message_text.inspect}")
$game_temp.message_text = nil; $game_temp.choice_max = 0

errs.empty? ? 'ok' : errs.join("\n")
`);
if (out !== 'ok') { console.log(out); process.exit(1); }
console.log('生活玩法：通过');
