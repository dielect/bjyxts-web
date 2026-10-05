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
check.call(L::FISH.size == 12, "鱼的种类：#{L::FISH.size}")
L::FISH.each_key { |id| check.call($data_items[id] && $data_items[id].name == L::FISH[id][:name], "鱼 #{id} 没有对应物品") }
(28..38).each { |id| check.call($data_items[id].common_event_id == 0, "新鱼 #{id} 不该能吃（鲤鱼的公共事件写死扣鲤鱼）") }
[:pond, :sea].each do |w|
  4.times { |s| $game_variables[158] = s * 750; check.call(!L.candidates(w).empty?, "#{w} 在#{L.season_name}季没有鱼") }
end

# ---------------------------------------------------------------- 钓竿
check.call(L.rod.nil?, '没装钓竿')
a.equip(7, 31)
check.call(L.rod == 31 && L.rod_lines(31) == ['【钓竿】普通'], '原版钓竿')
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
  L.start_cast(:pond, false)
  next unless $game_variables[9] == 1
  L.hook(false)
  next unless $game_variables[9] == 2
  L.land_and_text; landed += 1
end
check.call(landed > 60, "两百竿钓上 #{landed} 条")
check.call(L.species_caught >= 2 && L.skill > 0, "鱼谱 #{L.species_caught} 种，熟练度 #{L.skill}")
check.call(L.data[:fish].values.all? { |n, w| n > 0 && w > 0 }, '鱼谱记了条数和最大重量')
check.call(L::FISH.keys.sum { |id| $game_party.item_number(id) } >= landed, '钓上来的鱼进了背包')
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
[36, 37, 38, 17].each { |id| $game_party.gain_item(id, 1) }
L.show_jose
check.call(L.dragon_rod_due?, '十二种都看过，该送龙须钓竿')
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

errs.empty? ? 'ok' : errs.join("\n")
`);
if (out !== 'ok') { console.log(out); process.exit(1); }
console.log('生活玩法：通过');
