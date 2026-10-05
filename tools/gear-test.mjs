// 装备、装备特效与套装（src/game/web_gear.rb、mods/050、070）的回归测试。
//   node tools/gear-test.mjs
// 战斗里的实际表现在浏览器里验证；这里逐个检查数据、每种特效的结算、套装档位和武学精进的读写规则。
// 读的是构建产物，改完先运行 python3 tools/build.py --fast。
import { bootGame } from './headless-game.mjs';

const rb = await bootGame();
const out = rb(String.raw`
errs = []
check = lambda { |cond, msg| errs << msg unless cond }
a = $game_party.actors[0]
strip = lambda { a.equip(0, 0); (1..7).each { |i| a.instance_variable_set(:"@armor#{i}_id", 0) } }

# ---------------------------------------------------------------- 数据
(34..73).each do |w|
  d = $data_weapons[w]
  check.call(d && WebSkill.weapon_base(w), "武器 #{w} 不存在或没登记类型")
  check.call(d.nil? || (d.atk <= 99 && d.int_plus == 0 && d.agi_plus == 0), "武器 #{w} 数值越界或带了模板的加成")
end
(32..102).each do |i|
  d = $data_armors[i]
  check.call(d && d.auto_state_id == 0 && d.int_plus == 0 && d.pdef <= 60 && (0..5).include?(d.kind), "防具 #{i} 不存在或数据不对")
end
check.call($data_weapons.size == 74 && $data_armors.size == 103, "编号范围：武器到 #{$data_weapons.size - 1}，防具到 #{$data_armors.size - 1}")
[[39, 0], [49, 1], [63, 2], [75, 3], [85, 4], [94, 5]].each { |i, k| check.call($data_armors[i].kind == k, "防具 #{i} 部位应为 #{k}") }
($data_weapons.compact + $data_armors.compact).each do |d|
  check.call(d.description.bytesize <= 75, "#{d.name} 的描述超过一页（特效说明另起一页）") if d.id >= 32
end

# 每件装备的说明都能生成，每页不超过一行
($data_weapons.compact + $data_armors.compact).each do |d|
  pages = WebGear.help_pages(d)
  pages.each { |p| check.call(p.bytesize <= 75 + 8, "#{d.name} 的说明有一页太长：#{p}") }
  [WebGear.weapons, WebGear.armors].each { |t| }
end
WebGear.weapons.merge(WebGear.armors).each_value { |list| list.each { |e| check.call(!WebGear.describe(e).empty?, "特效 #{e.inspect} 没有说明") } }
WebGear.sets.each_value do |s|
  s[:pieces].flatten(1).each { |k, i| check.call((k == :weapon ? $data_weapons : $data_armors)[i], "套装 #{s[:name]} 的部件 #{k} #{i} 不存在") }
  s[:tiers].each { |n, list| check.call(n <= s[:pieces].size, "套装 #{s[:name]} 的 #{n} 件档超过部件数") }
end
pages = WebGear.help_pages($data_armors[41])
check.call(pages.any? { |p| p.include?('乾坤套 0/6') } && pages.any? { |p| p.include?('游龙身法战斗中+10级') }, "游龙靴的说明：#{pages.inspect}")

# 商人与军需官
shop = lambda { |map, name| load_data(format('/game/Data/Map%03d.rxdata', map)).events.values.find { |e| e.name == name }.pages[0].list.select { |c| [302, 605].include?(c.code) }.map { |c| c.parameters } }
check.call(shop.call(7, '小裁缝').include?([2, 94]) && shop.call(7, '小裁缝')[0] == [2, 4], "小裁缝的货：#{shop.call(7, '小裁缝').inspect}")
check.call(shop.call(19, '何铁手').include?([1, 59]), '何铁手没有镔铁杖')
qm = load_data('/game/Data/Map030.rxdata').events.values.find { |e| e.name == '八卦门军需' }
lists = qm.pages[0].list.select { |c| [302, 605].include?(c.code) }.map { |c| c.parameters }
check.call(lists.count { |c| c == [1, 40] } == 1 && lists.count { |c| c == [2, 41] } == 4, "八卦门军需的分档：#{lists.inspect}")

# ---------------------------------------------------------------- 套装件数与条件
strip.call
$game_variables[21] = 1
a.equip(0, 40); a.equip(1, 41)
s = WebGear.sets[:乾坤]
check.call(WebGear.set_count(s) == 2, '乾坤套应计 2 件')
check.call(WebGear.of(:power).size == 1, '2 件应有武学威力（条件：用八卦系武功，此时启用的兵刃为空，不满足）') if false
$game_variables[30] = 80; $game_variables[80] = 50
check.call(WebGear.of(:power).size == 1, '启用八卦刀、拿着八卦紫金刀时，乾坤 2 件的伤害加成应生效')
$game_variables[30] = 0
check.call(WebGear.of(:power).empty?, '没启用八卦刀时，乾坤 2 件的加成不生效')
a.equip(2, 50); a.equip(3, 65)
check.call(WebGear.cost_rate(2) == 0.7 && WebGear.cost_rate(22) == 1.0, "4 件后化掌为刀耗内力 70%：#{WebGear.cost_rate(2)}")
# 任选其一的部件
strip.call
a.equip(0, 54); a.equip(1, 42)
check.call(WebGear.set_count(WebGear.sets[:落英]) == 2, '花团锦鞭算落英套的兵器')
strip.call

# ---------------------------------------------------------------- 武学精进
reset_vars = lambda { (1..300).each { |i| $game_variables[i] = 0 } }
reset_vars.call
$game_variables[85] = 50; $game_variables[58] = 0
a.equip(0, 46)                                      # 真武剑：太极剑 +15
WebGear.battle_start
check.call($game_variables[85] == 65, "战斗中太极剑应视为 65 级，实际 #{$game_variables[85]}")
check.call($game_variables[58] == 0, '没学的武功不加')
$game_variables[85] = $game_variables[85]          # 原样写回（小无相功化用时就这样）
check.call($game_variables.raw(85) == 50, "写回时应扣掉加成，存档里仍是 50，实际 #{$game_variables.raw(85)}")
WebGear.levels_off
check.call($game_variables[85] == 50, '战斗结束后加成撤掉')
# 上限 20
a.equip(1, 45); $game_variables[68] = 10
WebGear.instance_variable_set(:@level_bonus, nil)
WebGear.battle_start
check.call($game_variables[68] == 20, "云履：万流归一 +10，实际 #{$game_variables[68]}")
WebGear.levels_off
strip.call

# ---------------------------------------------------------------- 逐个特效（把当前生效的特效直接换成测试用的）
real_active = WebGear.method(:active)
use = lambda { |*list| fx = list.map { |t, o| (o || {}).merge(type: t) }; WebGear.define_singleton_method(:active) { fx } }
get_npc_data(145)
en = Game_Enemy.new(145, 0)
fresh = lambda { en.hp = 300; en.sp = 300; en.remove_state(1); en.instance_variable_set(:@gear_poison, 0); $defend_text = '' }
a.hp = 100; a.sp = 10
hit = lambda { |dmg| fresh.call; en.damage = dmg; en.hp = 300 - dmg; WebGear.after_hit(a, en) }

use.call([:crit, chance: 100, ratio: 0.5]); hit.call(40)
check.call(en.damage == 60 && en.hp == 240 && $defend_text.include?('暴击'), "暴击：#{en.damage} #{en.hp}")
use.call([:power, ratio: 0.25]); hit.call(40)
check.call(en.damage == 50, "武学威力：#{en.damage}")
use.call([:execute, ratio: 0.5])
fresh.call; en.hp = 50; en.damage = 20; WebGear.after_hit(a, en)
check.call(en.damage == 30, "斩杀：#{en.damage}")
$npc_data[28] = 60; use.call([:pierce]); hit.call(100)
check.call(en.damage == 140, "破甲（防御 60 → +40%）：#{en.damage}")
use.call([:drain, ratio: 0.2]); a.hp = 100; hit.call(100)
check.call(a.hp == [120, a.maxhp].min, "吸血：#{a.hp}")
use.call([:steal_sp, ratio: 0.1]); a.sp = 10; hit.call(100)
check.call(a.sp == [20, a.maxsp].min, "吸内：#{a.sp}")
use.call([:chase, chance: 100]); hit.call(40)
check.call(en.damage == 60, "连击：#{en.damage}")
use.call([:poison, chance: 100, turns: 3, name: '灼烧']); hit.call(40)
check.call(en.instance_variable_get(:@gear_poison) == 3, '中毒 3 回合')
WebGear.before_action(en, nil)
check.call(en.hp < 260 && en.instance_variable_get(:@gear_poison) == 2, "中毒发作：#{en.hp}")
en.hp = 3; WebGear.before_action(en, nil)
check.call(en.hp >= 1, '中毒不致死')
use.call([:stun, chance: 100]); hit.call(40)
check.call(en.state?(1), '点穴')
$npc_data[9] = 8; n8 = $game_party.weapon_number(8)
use.call([:disarm, chance: 100]); hit.call(40)
check.call($npc_data[9] == 0 && $game_party.weapon_number(8) == n8 + 1, '缴械')
$npc_data[25] = 20; use.call([:slow, chance: 100]); hit.call(40)
check.call($npc_data[25] == 15, "迟滞：#{$npc_data[25]}")

# 防御
use.call([:dodge, chance: 100])
hits = 300.times.count { a.damage = 0; WebGear.dodge?(a) && a.damage == 'Miss' }
check.call(hits.between?(80, 160), "闪避最多 40%：300 次里躲开 #{hits} 次")
use.call([:dodge, chance: 0])
check.call(!WebGear.dodge?(a), '闪避 0% 不触发')
hurt = lambda { |dmg| a.hp = 500 - dmg; a.damage = dmg; en.hp = 300; $defend_text = ''; WebGear.after_hurt(en, a) }
use.call([:reduce, ratio: 0.2]); hurt.call(100)
check.call(a.hp == 420 && a.damage == 80, "减伤：#{a.hp} #{a.damage}")
use.call([:cap, ratio: 0.1]); a.maxhp = 500; hurt.call(200)
check.call(a.hp == 450, "金刚（上限 50）：#{a.hp}")
use.call([:reflect, ratio: 0.3]); hurt.call(100)
check.call(en.hp == 270, "反震：#{en.hp}")
use.call([:counter, chance: 100]); hurt.call(100)
check.call(en.hp == 250, "反击：#{en.hp}")
use.call([:skill_reduce, ratio: 0.5]); a.hp = 400
WebGear.after_skill_hurt(a, 100)
check.call(a.hp == 450, "化劲：#{a.hp}")
use.call([:guard]); WebGear.battle_start; a.hp = 0
WebGear.guard(a)
check.call(a.hp == 1, '护心')
use.call([:steady]); a.remove_state(1); a.add_state(1)
check.call(!a.state?(1), '定心：不会被定身')
use.call([:regen, pct: 10], [:sp_regen, pct: 10]); a.hp = 1; a.sp = 0
WebGear.before_action(a, nil)
check.call(a.hp > 1 && (a.maxsp == 0 || a.sp > 0), "回春回内：#{a.hp} #{a.sp}")
use.call([:cost, ratio: 0.3, skills: [22]], [:cost, ratio: 0.5, skills: [22]])
check.call(WebGear.cost_rate(22) == 0.4, "绝招省力最多 60%：#{WebGear.cost_rate(22)}")
check.call(WebSkill.sp_cost(a, 22) == 160 && WebSkill.sp_cost(en, 22) == 400, "省力只对玩家：#{WebSkill.sp_cost(a, 22)}")
use.call([:escape]); check.call(WebGear.escape?, '神行')
use.call([:gold, ratio: 0.5]); check.call(en.gold == ($data_enemies[145].gold * 1.5).to_i, "财运：#{en.gold}")
use.call
check.call(en.gold == $data_enemies[145].gold, '没有财运时银两照旧')
WebGear.define_singleton_method(:active, real_active)

# 逍遥套接到小无相功、折梅手
strip.call; $game_variables[78] = 0
base = WebXwx.mimic
a.equip(1, 47); a.equip(2, 56); a.equip(3, 71)
check.call((WebXwx.mimic - base - 0.2).abs < 1e-9, "逍遥套 3 件模仿度 +20%：#{WebXwx.mimic}")
check.call(WebGear.value(:zhemei_chase) == 10, '逍遥套折梅手追加几率 +10')
strip.call

errs.empty? ? 'ok' : errs.join("\n")
`);
if (out !== 'ok') { console.log(out); process.exit(1); }
console.log('装备、特效与套装：通过');
