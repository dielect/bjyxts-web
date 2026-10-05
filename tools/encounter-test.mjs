// 江湖奇遇（src/game/web_encounters.rb、mods/060）的回归测试。装备特效见 gear-test.mjs。
//   node tools/encounter-test.mjs
// 对话和战斗的实际流程在浏览器里验证；这里检查规则、数据和事件指令。
// 读的是构建产物，改完先运行 python3 tools/build.py --fast。
import { bootGame } from './headless-game.mjs';

const rb = await bootGame();
const out = rb(String.raw`
errs = []
check = lambda { |cond, msg| errs << msg unless cond }
reset = lambda do
  (1..300).each { |i| $game_variables[i] = 0 }
  (100..120).each { |i| $game_switches[i] = false }
  $game_variables[160] = 150
  $game_variables[19] = 50000
  $game_variables[157] = 18
end

# ---------------------------------------------------------------- 数据
ces = $data_common_events
WebEncounter.list.each_value do |e|
  id = WebMod.auto_common_event_id(e[:key])
  check.call(id && ces[id] && ces[id].name == "奇遇-#{e[:name]}", "奇遇 #{e[:id]} 没有对应的公共事件")
end
check.call((1...ces.size).all? { |i| ces[i] }, '公共事件编号中间有空位')

# 事件里的脚本和条件都能编译（防止手误）
ces.compact.each do |ce|
  code = []
  ce.list.each do |c|
    case c.code
    when 355 then code << +c.parameters[0]
    when 655 then code[-1] << "\n" << c.parameters[0]
    when 111 then code << c.parameters[1] if c.parameters[0] == 12
    end
  end
  code.each do |src|
    begin
      RubyVM::InstructionSequence.compile(src)
    rescue SyntaxError => ex
      errs << "公共事件 #{ce.id}（#{ce.name}）脚本有语法错误：#{src.inspect}"
    end
  end
  depth = ce.list.map(&:indent)
  check.call(ce.list[-1].code == 0 && ce.list[-1].indent == 0, "公共事件 #{ce.id} 结尾不对")
end

check.call(ces[$data_items[26].common_event_id].name == '使用-武学残页', '武学残页没有接上公共事件')

# ---------------------------------------------------------------- 抽取规则
$game_map.setup(1)
reset.call
avail = lambda { |id, map = 1| WebEncounter.available?(WebEncounter.list[id], map) }
check.call(avail.call(1) && !avail.call(1, 15), '山贼应只在野外出现')
check.call(avail.call(6, 15) && !avail.call(6), '骰子摊应只在镇上出现')
check.call(avail.call(7) && !avail.call(8), '正派遇到恶霸，遇不到落单行商')
$game_variables[160] = 100
check.call(!avail.call(7) && avail.call(8), '邪派遇不到恶霸，能遇到落单行商')
check.call(!avail.call(9), '道德 100、没有追杀数时不该有赏金猎人')
$game_variables[159] = 2
check.call(avail.call(9), '追杀数 2 时应有赏金猎人')
reset.call
$game_variables[19] = 5000
check.call(!avail.call(2), '经验不到一万不该遇到重伤剑客')
$game_variables[19] = 50000

# once / cooldown / after
WebEncounter.start(2); $game_temp.common_event_id = 0
check.call(!avail.call(2), '重伤剑客只发生一次')
$game_switches[107] = true
check.call(!avail.call(3), '刚救完温青，不该马上报恩')
WebEncounter.start(1); WebEncounter.start(5)
check.call(!avail.call(1), '山贼劫道冷却中')
check.call(!avail.call(3), '只过了两段奇遇')
WebEncounter.start(6)
check.call(avail.call(3, 15) && !avail.call(4, 15), '过了三段奇遇，救过的应报恩、不寻仇')
WebEncounter.start(5); WebEncounter.start(6)
check.call(avail.call(1), '山贼劫道冷却已过')
check.call(WebEncounter.total == 6 && $game_variables[254] == 6 && $game_variables[255] == 5, '总次数与最近记录')
$game_temp.common_event_id = 0

# 最近两段不重复（除非只剩它们）
reset.call
50.times do
  e = WebEncounter.pick(15)
  check.call(e.nil? || ![$game_variables[254], $game_variables[255]].include?(e[:id]) || WebEncounter.candidates(15).size <= 2, "镇上抽到了刚发生过的奇遇 #{e && e[:id]}")
  WebEncounter.start(e) if e
  $game_temp.common_event_id = 0
end

# 传闻：听完就不再出现
reset.call
$game_switches[106] = true; $game_switches[104] = true
check.call(avail.call(10, 15), '有没听过的传闻时应出现')
$game_switches[110] = $game_switches[112] = true
check.call(!avail.call(10, 15), '传闻都听过了不该再出现')

# 走路计数：野外每步 2，镇上 1，不在奇遇区域不计
reset.call
WebEncounter.instance_variable_set(:@count, 10)
WebEncounter.instance_variable_set(:@ready, false)
$game_map.setup(1); 5.times { WebEncounter.step }
check.call(WebEncounter.instance_variable_get(:@ready), '野外走 5 步应攒满 10')
WebEncounter.instance_variable_set(:@count, 10); WebEncounter.instance_variable_set(:@ready, false)
$game_map.setup(4); 20.times { WebEncounter.step }
check.call(!WebEncounter.instance_variable_get(:@ready), '家里不该计步')
$game_map.setup(15); 9.times { WebEncounter.step }
check.call(!WebEncounter.instance_variable_get(:@ready), '镇上走 9 步还不够 10')
WebEncounter.step
check.call(WebEncounter.instance_variable_get(:@ready), '镇上走 10 步应攒满')
$game_player = Game_Player.new
$game_player.moveto(5, 5)
$game_temp.common_event_id = 0
WebEncounter.update
check.call($game_temp.common_event_id > 0 && WebEncounter.total == 1, '攒满后应启动一段奇遇')
check.call(!WebEncounter.instance_variable_get(:@ready), '启动后应重新计步')
$game_temp.common_event_id = 0

# ---------------------------------------------------------------- 奖励与掉落
reset.call
$game_variables[19] = 1000; $game_variables[20] = 10; $game_variables[153] = 13
WebMod.gain_exp(500); WebMod.gain_pot(100)
check.call($game_variables[19] == 1500 && $game_variables[152] == Zlib.crc32('1500', 51), '加经验要同步校验值 152')
check.call($game_variables[153] == $game_variables[20] + 3, '加潜能要同步校验值 153')
$game_variables[160] = 250; WebMod.gain_morality(20)
check.call($game_variables[160] == 255, '道德值上限 255')
WebMod.roll_loot([[:armor, 32], [:weapon, 35, 1, 0]])
check.call($trea1 == '斗笠' && $trea2 == '', "掉落名字：#{[$trea1, $trea2].inspect}")
n = $game_party.armor_number(32)
WebMod.give_loot
check.call($game_party.armor_number(32) == n + 1 && $game_party.weapon_number(35) == 0, '掉落应只给掷中的')

errs.empty? ? 'ok' : errs.join("\n")
`);

const fail = [out].filter((r) => r !== 'ok');
if (fail.length) {
  console.log(fail.join('\n'));
  process.exit(1);
}
console.log('江湖奇遇：通过');
