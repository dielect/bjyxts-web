// 小无相功（src/game/mods/030_小无相功.rb）的规则回归测试。战斗中的实际流程在浏览器里验证。
//   node tools/xwx-test.mjs
// 读的是构建产物，改完先运行 python3 tools/build.py --fast。
import { bootGame } from './headless-game.mjs';

const rb = await bootGame();
const out = rb(String.raw`
errs = []
check = lambda { |cond, msg| errs << msg unless cond }
a = $game_party.actors[0]
reset = lambda { (1..300).each { |i| $game_variables[i] = 0 }; WebXwx.battle_start; a.skills = [] }

check.call($data_system.variables[78] == '小无相功', "武功 78 的名字：#{$data_system.variables[78].inspect}")
check.call(WebSkill.category(78) == WebSkill::INNER && WebSkill.base_of(78) == 45, '小无相功应登记为内功，基础为基本内功')

# 等级相关的数值
reset.call
[[1, 0.501, 1, 1], [100, 0.6, 3, 2], [250, 0.75, 6, 3], [500, 1.0, 11, 6], [900, 1.0, 12, 10]].each do |lv, mimic, cap, free|
  $game_variables[78] = lv
  WebXwx.battle_start
  check.call((WebXwx.mimic - mimic).abs < 1e-9, "#{lv} 级模仿度应为 #{mimic}，实际 #{WebXwx.mimic}")
  check.call(WebXwx.capacity == cap, "#{lv} 级记忆上限应为 #{cap}，实际 #{WebXwx.capacity}")
  check.call(WebXwx.instance_variable_get(:@free_left) == free, "#{lv} 级免费次数应为 #{free}")
end

# 没启用小无相功：一切照旧
reset.call
$game_variables[78] = 150; $game_variables[241] = 22
study_skill
check.call(a.skills.empty?, '没启用小无相功时不应出现记下的绝招')
check.call(WebSkill.sp_cost(a, 22) == 400, '没启用时耗费应为原值')
check.call(WebSkill.requirements_for(22, [[32, 76]]) == [[32, 76]], '没启用时使用条件应为原版')

# 启用：记下的绝招进列表，耗费按模仿度，使用条件豁免
$game_variables[32] = 78
study_skill
check.call(a.skills == [22], "启用后绝招列表应为 [22]，实际 #{a.skills.inspect}")
check.call(WebSkill.sp_cost(a, 22) == 260, "150 级化用三环套月应耗 400×0.65=260，实际 #{WebSkill.sp_cost(a, 22)}")
check.call(WebSkill.requirements_for(22, [[32, 76]]) == [], '化用时应豁免使用条件')
$game_variables[78] = 200
check.call(WebSkill.sp_cost(a, 22) == 140, "200 级万法归宗应再减半为 140，实际 #{WebSkill.sp_cost(a, 22)}")
$game_variables[78] = 150

# 本身学会的绝招不算化用（太极剑 + 太极神功学会三环套月时，按原版规则）
reset.call
$game_variables[78] = 150; $game_variables[241] = 22
$game_variables[32] = 78; $game_variables[30] = 85; $game_variables[85] = 120
a.instance_variable_set(:@weapon_id, 15)            # 长剑
study_skill
check.call(a.skills.include?(22) && WebXwx.borrowed?(a, 22), '练了太极剑、但内功是小无相功时，三环套月不满足原版条件，应按化用')
check.call(WebSkill.sp_cost(a, 22) == 260, '此时应按化用收费')
# 满足原版条件时按原版：天下无狗只要求启用打狗棒法、打狗棒法和基本棍法 60 级，不要求内功
reset.call
$game_variables[78] = 150; $game_variables[32] = 78; $game_variables[241] = 28
$game_variables[30] = 84; $game_variables[84] = 60; $game_variables[39] = 60
check.call(!WebXwx.borrowed?(a, 28) && WebSkill.sp_cost(a, 28) == 450, '满足原版条件的绝招应按原版规则、原价')
$game_variables[84] = 10
check.call(WebXwx.borrowed?(a, 28) && WebSkill.sp_cost(a, 28) == (450 * 0.65).round, '不满足时应按化用')

# 现学现用：本场看过的绝招免费一次
reset.call
$game_variables[78] = 150; $game_variables[32] = 78
WebXwx.seen << 14; WebXwx.instance_variable_get(:@free_ids) << 14
study_skill
check.call(a.skills.include?(14), '本场看过的绝招应进列表')
check.call(WebSkill.sp_cost(a, 14) == 0, '现学现用应显示耗费 0')
check.call(WebSkill.consume_sp(a, 14) == 0, '现学现用应不扣内力')
check.call(WebSkill.sp_cost(a, 14) == (350 * 0.65).round, "免费用过后应按模仿度收费，实际 #{WebSkill.sp_cost(a, 14)}")

# 借用时临时提升相关武功等级、借足内力，用完还原
reset.call
$game_variables[78] = 150; $game_variables[32] = 78; $game_variables[241] = 22
$game_variables[85] = 3; a.instance_variable_set(:@sp, 10)
study_skill
saved = WebXwx.boost(a, $data_skills[22])
check.call($game_variables[30] == 85 && $game_variables[32] == 76, '借用时应临时启用三环套月要求的太极剑、太极神功')
check.call($game_variables[85] == 97 && $game_variables[76] == 97 && $game_variables[41] == 97, "借用时相关武功应临时视为 150×0.65=97 级，实际 #{[85, 76, 41].map { |v| $game_variables[v] }.inspect}")
check.call(a.sp == 260, "借用时内力应临时借足到 260，实际 #{a.sp}")
a.instance_variable_set(:@sp, a.sp - 30)            # 假设招式里又耗了 30
WebXwx.restore(a, saved)
check.call($game_variables[30] == 0 && $game_variables[32] == 78 && $game_variables[85] == 3 && $game_variables[76] == 0, '用完应还原武功等级和启用状态')
check.call(a.sp == 0, "用完内力应扣回借的部分（10 - 30 → 0），实际 #{a.sp}")

# 观招：只在启用时、对手使出时记下；记忆不会超过上限
reset.call
$game_variables[78] = 150; $game_variables[32] = 78
win = Object.new; def win.draw_words(*); end
enemy = Game_Enemy.allocate
def Graphics.update; end
WebXwx.observe(enemy, $data_skills[6], win)
WebXwx.observe(enemy, $data_skills[6], win)
WebXwx.observe(a, $data_skills[9], win)
WebXwx.observe(enemy, $data_skills[26], win)
check.call(WebXwx.memory == [6], "观招后记忆应为 [6]，实际 #{WebXwx.memory.inspect}")
check.call(WebXwx.seen == [6], '自己用的、左右互搏都不应观到')
# 获取：无相残卷 → 公共事件 26 → 逍遥派秘籍 6
check.call($data_items[24] && $data_items[24].name == '无相残卷' && $data_items[24].common_event_id == 26, '物品 24 无相残卷应指向公共事件 26')
check.call($data_common_events[26] && $data_common_events[26].list.any? { |c| c.code == 355 && c.parameters[0] == '$scene=Scene_Study.new(7,6)' }, '公共事件 26 应打开逍遥派秘籍 6')
check.call(WebSkill.study_list(7, 6, nil) == [[78, 150]], '逍遥派秘籍 6 应教小无相功到 150 级')
check.call(WebSkill.study_list(7, 4, [[40, 250], [60, 200]]) == [[40, 250], [60, 200]], '原版秘籍列表应不变')
errs.empty? ? 'ok' : errs.join("\n")
`);
if (out !== 'ok') { console.log(out); process.exit(1); }
console.log('小无相功规则：通过');
