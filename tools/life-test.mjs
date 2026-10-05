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
check.call(L.show_jose.include?('都见过'), '身上没鱼时')
$game_party.gain_item(28, 1); $game_party.gain_item(29, 1)
L.show_jose
check.call(L.jose[:favor] == 2 && L.jose_gift? && L.jose_title =~ /小(兄弟|姑娘)/, "给看两种新鱼：交情 #{L.jose[:favor]}，称呼 #{L.jose_title}")
check.call(L.jose_gift_text.include?('厨子') && L.flag?(:cook_intro), '交情 2 介绍厨师')
L.show_jose
check.call(L.jose[:favor] == 2, '看过的鱼不再加交情')
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
check.call(L::RECIPES.size == 12 && (52..63).all? { |id| $data_items[id].type == 0 && $data_common_events[$data_items[id].common_event_id].name.start_with?('吃-') }, '十二道菜：归食物，各有吃的公共事件')
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

errs.empty? ? 'ok' : errs.join("\n")
`);
if (out !== 'ok') { console.log(out); process.exit(1); }
console.log('生活玩法：通过');
