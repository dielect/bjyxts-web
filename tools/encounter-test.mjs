// 江湖奇遇（src/game/web_encounters.rb、mods/060）与装备特效（web_gear.rb、mods/050）的回归测试。
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

(34..37).each { |w| check.call($data_weapons[w] && WebSkill.weapon_type_of(w), "武器 #{w} 不存在或没登记类型") } if WebSkill.respond_to?(:weapon_type_of)
(34..37).each { |w| check.call($data_weapons[w], "武器 #{w} 不存在") }
(32..38).each do |a|
  ar = $data_armors[a]
  check.call(ar && ar.auto_state_id == 0 && ar.int_plus == 0, "防具 #{a} 不存在或带了模板的状态加成")
end
check.call($data_armors[32].kind == 1 && $data_armors[33].kind == 0 && $data_armors[34].kind == 2 && $data_armors[36].kind == 3, '防具部位不对')
$data_weapons.compact.each { |w| check.call(w.description.bytesize <= 150, "武器 #{w.id} 描述超过两页") }
$data_armors.compact.each { |w| check.call(w.description.bytesize <= 150, "防具 #{w.id} 描述超过两页") }
check.call(ces[$data_items[26].common_event_id].name == '使用-武学残页', '武学残页没有接上公共事件')

# 商人添货
shop = lambda { |map, name| load_data(format('/game/Data/Map%03d.rxdata', map)).events.values.find { |e| e.name == name }.pages[0].list.select { |c| [302, 605].include?(c.code) }.map { |c| c.parameters } }
check.call(shop.call(7, '小裁缝') == [[2, 4], [2, 32], [2, 33]], "小裁缝的货：#{shop.call(7, '小裁缝').inspect}")
check.call(shop.call(19, '何铁手').last == [1, 37], '何铁手没有铁骨折扇')

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

# ---------------------------------------------------------------- 装备特效
a = $game_actors[1]
a.hp = 100
get_npc_data(145)
en = Game_Enemy.new(145, 0)
hit = lambda { |dmg| en.hp = 300; en.damage = dmg; $defend_text = ''; WebGear.after_attack(a, en) }
force = lambda { |kind, id, **o| (kind == :weapon ? WebGear.weapons : WebGear.armors)[id] = WebGear.send(kind == :weapon ? :weapons : :armors)[id].merge(o) }
force.call(:weapon, 34, chance: 100)
force.call(:weapon, 36, chance: 100)
force.call(:weapon, 37, chance: 100)
a.equip(0, 34); hit.call(40)
check.call(en.damage == 60 && en.hp == 280 && $defend_text.include?('秋水'), "秋水：伤害 #{en.damage}，气血 #{en.hp}")
a.equip(0, 35); a.hp = 100; hit.call(100)
check.call(a.hp == [115, a.maxhp].min, "饮血：气血 #{a.hp}")
a.equip(0, 36); hit.call(40)
check.call(en.instance_variable_get(:@gear_poison) == 3, '蛇毒应让对方中毒 3 回合')
WebGear.before_action(en, nil)
check.call(en.hp < 300 && en.instance_variable_get(:@gear_poison) == 2, '中毒发作应失血')
en.hp = 5; en.instance_variable_set(:@gear_poison, 1); WebGear.before_action(en, nil)
check.call(en.hp == 4 || en.hp == 1, "中毒不致死，气血 #{en.hp}")
en.instance_variable_set(:@gear_poison, 0)
en.remove_state(1)
a.equip(0, 37); hit.call(40)
check.call(en.state?(1), '点穴应定住对方')
a.equip(0, 0)

# 防具：反震、护心、回春
WebGear.battle_start
a.equip(4, 36); a.hp = 100; en.hp = 300; a.damage = 50; $defend_text = ''
WebGear.after_attack(en, a)
check.call(en.hp == 290 && $defend_text.include?('反震'), "反震：对方气血 #{en.hp}")
a.equip(4, 35); a.hp = 0; a.damage = 50
WebGear.after_attack(en, a)
check.call(a.hp == 1, '护心应保住 1 点气血')
a.hp = 0; WebGear.after_attack(en, a)
check.call(a.hp == 0, '护心每场只有一次')
a.equip(4, 0)
a.equip(2, 37); a.hp = 1
WebGear.before_action(a, nil)
check.call(a.hp == 1 + [a.maxhp * 3 / 100, 1].max, "回春：气血 #{a.hp}")
a.equip(2, 0)

errs.empty? ? 'ok' : errs.join("\n")
`);

const fail = [out].filter((r) => r !== 'ok');
if (fail.length) {
  console.log(fail.join('\n'));
  process.exit(1);
}
console.log('江湖奇遇、装备特效：通过');
