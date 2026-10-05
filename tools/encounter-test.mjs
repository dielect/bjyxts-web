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
  (100..160).each { |i| $game_switches[i] = false }
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
check.call(!avail.call(9), '道德 100、没有通缉时不该有赏金猎人')
$game_variables[159] = 30
check.call(!avail.call(9), '追杀数（杀恶人数）多不该招来赏金猎人')
$game_variables[164] = 2
check.call(avail.call(9), '通缉值 2 时应有赏金猎人')
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
RUMORS.each { |sw, *| $game_switches[sw] = true }
check.call(!avail.call(10, 15), '传闻都听过了不该再出现')

# 第二批：黑风寨、捕头、六扇门差事、比武招亲、货郎
reset.call
check.call(!avail.call(12), '没打过山贼头目，黑风寨不该出现')
$game_variables[162] = 3
check.call(avail.call(12), '打败头目 3 次后黑风寨应出现')
[[:weapon, 44], [:armor, 78], [:armor, 86], [:armor, 100]].each { |k, i| k == :weapon ? $game_party.gain_weapon(i, 1) : $game_party.gain_armor(i, 1) }
check.call(!avail.call(12), '黑风寨套集齐后不再出现')
check.call(!avail.call(13), '行侠不够，捕头不该出现')
$game_variables[163] = 4
check.call(avail.call(13) && !avail.call(14), '行侠 4 次后捕头相邀，差事要等入门')
$game_switches[117] = true
check.call(!avail.call(13) && avail.call(14), '入了六扇门后只有差事')
$game_variables[160] = 100
check.call(!avail.call(14), '变成邪派后不再派差事')
reset.call
check.call(avail.call(15, 15) && !avail.call(15), '比武招亲只在镇上')
$game_variables[157] = 15
check.call(!avail.call(15, 15), '不到 16 岁不能比武招亲')
st = WebJianghu.peddler_stock
check.call(st.size == 3 && st.uniq.size == 3 && st.all? { |k, i| WebJianghu::PEDDLER.include?([k, i]) }, "货郎的货：#{st.inspect}")
WebMod.open_shop(st)
check.call($game_temp.shop_calling && $game_temp.shop_goods.size == 3 && $game_temp.shop_type == 1, '货郎开店')
$game_temp.shop_calling = false
# 掉一件还没有的
$game_party.lose_armor(86, 99)
WebMod.roll_loot([[:missing, [[:armor, 78], [:armor, 86]], 1]])
check.call($trea1 == '黑风大氅', "应掉还没有的黑风大氅，实际 #{$trea1}")

# 第三批：逍遥故人、剑冢、老婆婆、武当老道、神兵传闻要经验 50 万
reset.call
check.call(!avail.call(16), '没破珍珑棋局，逍遥故人不出现')
$game_switches[106] = true; $game_variables[78] = 30
check.call(avail.call(16), '破局且小无相功 30 级后逍遥故人出现')
check.call(!avail.call(17), '没听说剑冢，不出现')
$game_switches[139] = true
check.call(avail.call(17), '听说剑冢后出现')
$game_switches[140] = true
check.call(!avail.call(17), '拔出重剑后不再出现')
check.call(avail.call(19, 26) && !avail.call(19, 1), '武当老道只在武当山脚')
check.call(avail.call(18, 15) && !avail.call(18, 1), '老婆婆在镇上和郊外')
reset.call
$game_switches[106] = $game_switches[104] = true
RUMORS.each { |sw, cond, _| $game_switches[sw] = true unless cond.include?('[19]') }   # 普通传闻都听过了
check.call(!avail.call(10, 15), '经验不到 50 万，神兵传闻听不到')
$game_variables[19] = 600000
check.call(avail.call(10, 15), '经验 50 万后能听到神兵传闻')

# 正邪分支：分岔与邀请
reset.call
$game_variables[19] = 200000; $game_variables[160] = 200
check.call(!R.good_invite? && !avail.call(20), '经验不到 30 万不触发')
$game_variables[19] = 300000
check.call(R.good_invite? && !R.evil_invite?, '道德 200：只有正道邀请')
$game_variables[160] = 60
check.call(!R.good_invite? && R.evil_invite?, '道德 60：只有邪道邀请')
$game_variables[160] = 128
check.call(R.good_invite? && R.evil_invite?, '道德 128：两边都请')
R.decline(:good)
check.call(R.route.nil? && R.evil_invite?, '中间的拒绝了正道，还会有邪道邀请')
R.decline(:evil)
check.call(R.route == :alone && !avail.call(20) && !avail.call(21), '两边都拒绝后独行')
reset.call
$game_variables[19] = 300000; $game_variables[160] = 200
R.decline(:good)
check.call(R.route == :alone, '正派拒绝正道邀请（邪道不会来请）就是独行')
reset.call
$game_variables[19] = 300000; $game_variables[160] = 200; $game_switches[119] = true
check.call(!R.good_invite? && R.evil_invite?, '入伙过黑风寨的，正道不请')
reset.call
$game_variables[19] = 300000; $game_switches[R::GOOD] = true; $game_variables[R::STAGE] = 1
check.call(avail.call(22) && !avail.call(24), '正道第一阶段遇血衣楼杀手')
reset.call
$game_variables[19] = 300000; $game_variables[160] = 50; $game_switches[R::EVIL] = true; $game_variables[R::STAGE] = 2; $game_variables[164] = 9
check.call(avail.call(25) && !avail.call(9), '邪道被总捕追捕时，赏金猎人让位')
check.call(R.feared?, '通缉很重时镇上的人怕你')
$game_switches[R::DONE] = true
check.call($end_com[R.title_index(0)] == '血衣楼主', "邪道结局称号：#{$end_com[R.title_index(0)]}")
$game_switches[R::EVIL] = false; $game_switches[R::GOOD] = true
check.call($end_com[R.title_index(5)] == '天下名捕' && R.hero?, '正道结局称号')
$game_switches[R::DONE] = false
check.call(R.title_index(5) == 5, '没走完路线时用原版称号')
check.call($end_com.count('天下名捕') == 1, '结局称号只追加一次')
reset.call
$game_switches[R::ALONE] = true; $game_variables[R::COUNT] = 5
check.call(avail.call(27) && !avail.call(26), '独行打退 5 次后独行侠来访')

# 战斗奇遇之后，下一段一定不打架；只剩战斗奇遇时空过一次就恢复
reset.call
$game_map.setup(1)
WebEncounter.start(1); $game_temp.common_event_id = 0
check.call(WebEncounter.combat_rest? && !avail.call(7) && avail.call(5), '山贼之后应只有不打架的奇遇')
WebEncounter.start(5); $game_temp.common_event_id = 0
check.call(!WebEncounter.combat_rest? && avail.call(7), '隔了一段残页之后又可以打架')
WebEncounter.start(7); $game_temp.common_event_id = 0
saved = WebEncounter.list.dup
WebEncounter.list.delete_if { |id, e| !e[:combat] }
$game_player = Game_Player.new
WebEncounter.chance = 100
WebEncounter.instance_variable_set(:@ready, true)
$game_temp.common_event_id = 0
WebEncounter.update
check.call($game_temp.common_event_id == 0 && !WebEncounter.combat_rest?, '只剩战斗奇遇时空过一次，并解除限制')
WebEncounter.list.replace(saved)
check.call(%w[1 4 7 9 12 14 15 22 24 25 26].all? { |i| WebEncounter.list[i.to_i][:combat] } && !WebEncounter.list[5][:combat], '战斗奇遇的标记')

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
WebEncounter.chance = 100
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
