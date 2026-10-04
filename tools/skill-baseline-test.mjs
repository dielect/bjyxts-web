// 武功 / 武器分类规则的基准测试（为“武功注册表”重构准备）。
//
//   node tools/skill-baseline-test.mjs            与基准对比，有差异时列出并以非零退出
//   node tools/skill-baseline-test.mjs --update   重新生成基准 tools/fixtures/skill-baseline.json
//
// 在 Node 里用线上同一个 public/ruby.wasm 载入构建产物 public/game/scripts.json（不含 117 Main），
// 渲染层 RG 用空桩代替，然后直接调用游戏里判断武功类别的函数，把所有输入下的结果记下来。
// 修改 game-src/scripts 或 src/game 后要先运行 python3 tools/build.py，再运行本测试。
//
// 覆盖的判断（都是“哪些编号属于哪一类”写死的地方）：
//   weapon     004 get_weapon_base_skill / weapon_matching_skill?：武器 → 基础武功、可配合的兵刃武功
//   base       004 weapon_skill_base / get_all_skill_base：武功 → 基础武功
//   study      006 study_skill：启用的武功 → 自动学会的绝招
//   window     057 Window_Skill#refresh：技能窗口每个分类列出哪些武功
//   help       057 Window_Skill#update_help：学习点数读哪个变量（编号 + 60）
//   practice   099 Scene_Practice#check：能否练功、受哪门基础武功的等级限制
//   npc        029 Game_Enemy#npc_weapon? / npc_base_skill：NPC 的武器与兵刃武功
// 另有不进基准的硬性检查（src/game/web_skills.rb 载入后生效）：数据库里每件武器都登记了类型、
//   登记的武功都有名字、点数变量不与已占用变量冲突。
// 未覆盖（需要跑场景循环或依赖随机数）：099 update_ex、113 Scene_Study#study 的 +60，
//   013 Data_NPC 的 39..89 循环，026 set_turns 的 72..77，009 Data_Defend 的默认 46。
//   重构时这几处要人工核对。
import fs from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import { WASI } from 'node:wasi';
import { RubyVM } from '@ruby/wasm-wasi';

const ROOT = new URL('../', import.meta.url);
const FIXTURE = new URL('tools/fixtures/skill-baseline.json', ROOT);
const update = process.argv.includes('--update');

const module = await WebAssembly.compile(await fs.readFile(new URL('public/ruby.wasm', ROOT)));
const wasi = new WASI({ version: 'preview1', args: ['ruby'], preopens: {
  '/game': new URL('public/game', ROOT).pathname,
  '/work': await fs.mkdtemp(path.join(os.tmpdir(), 'skill-baseline-')),   // 116 容错脚本载入时会在当前目录建 errors.txt
} });
const { vm } = await RubyVM.instantiateModule({ module, wasip1: wasi });
globalThis.RG = new Proxy({}, { get: () => () => 0 });
globalThis.RGScripts = JSON.parse(await fs.readFile(new URL('public/game/scripts.json', ROOT), 'utf8'))
  .filter(([name]) => name !== '117:Main');
for (const f of ['rgss_core', 'rgss_kernel', 'rpg']) vm.eval(await fs.readFile(new URL(`src/ruby/${f}.rb`, ROOT), 'utf8'));

// Ruby 端每行输出 “分组\t键\t值”，由 JS 组装成 JSON（运行时没有 JSON 库）。
const out = vm.eval(String.raw`
Dir.chdir('/work')
s = JS.global[:RGScripts]
s[:length].to_i.times { |i| TOPLEVEL_BINDING.eval(s[i][1].to_s, s[i][0].to_s, 1) }
$data_system  = load_data('/game/Data/System.rxdata')
$data_actors  = load_data('/game/Data/Actors.rxdata')
$data_classes = load_data('/game/Data/Classes.rxdata')
$data_skills  = load_data('/game/Data/Skills.rxdata')
$data_weapons = load_data('/game/Data/Weapons.rxdata')
$data_armors  = load_data('/game/Data/Armors.rxdata')
$data_states  = load_data('/game/Data/States.rxdata')
$game_switches  = Game_Switches.new
$game_variables = Game_Variables.new
$game_actors    = Game_Actors.new
$game_party     = Game_Party.new
$game_party.actors.push($game_actors[1])
ACTOR = $game_party.actors[0]
def ACTOR.maxhp; 10**9; end       # 练功检查要求满血，这里只测类别逻辑
lines = []
emit = lambda { |g, k, v| lines << "#{g}\t#{k}\t#{v}" }
reset = lambda { (1..300).each { |i| $game_variables[i] = 0 } }
equip = lambda { |w| ACTOR.instance_variable_set(:@weapon_id, w) }
WEAPONS = (0..33).to_a                       # 0 空手，1..30 原版，31..33 不存在的新编号
SKILLS  = (39..90).to_a

# weapon / base
reset.call
WEAPONS.each do |w|
  equip.call(w)
  emit.call('weapon', w, "base=#{get_weapon_base_skill.inspect} match=#{SKILLS.select { |n| weapon_matching_skill?(n) }.join(',')}")
end
(0..160).each { |n| emit.call('base', n, "#{weapon_skill_base(n).inspect} #{get_all_skill_base(n).inspect}") }

# study：启用组合 → 学会的绝招。内功（变量 32）与其余部分独立，分开枚举。
v29s = [0, 40] + (53..63).to_a
v30s = [0, 39, 41, 42, 43, 44] + (80..90).to_a
[0, 1, 2, 5, 25, 31].each do |w|
  v29s.each do |a|
    v30s.each do |b|
      reset.call; equip.call(w)
      $game_variables[29] = a; $game_variables[30] = b
      study_skill
      emit.call('study', "w#{w} 拳#{a} 兵#{b}", ACTOR.skills.sort.join(','))
    end
  end
end
([0, 45] + (72..79).to_a).each do |c|
  reset.call; equip.call(0); $game_variables[32] = c
  study_skill
  emit.call('study', "内#{c}", ACTOR.skills.sort.join(','))
end

# window / help
class Window_Skill
  attr_reader :data
  def draw_item(index); end          # 只测 @data，不画
  def width; 320; end
  def row_max; 1; end
  def contents; nil; end
  def contents=(b); end
end
reset.call
SKILLS.each { |n| $game_variables[n] = 1; $game_variables[n + 60] = 1000 + n }
$game_variables[29] = 53; $game_variables[30] = 80
win = Window_Skill.allocate
help = Object.new
def help.set_text(t); @t = t; end
def help.text; @t; end
win.instance_variable_set(:@help_window, help)
(0..5).each do |c|
  win.define_singleton_method(:category) { c }
  win.refresh
  emit.call('window', c, win.data.join(','))
end
SKILLS.each do |n|
  win.instance_variable_set(:@data, [n]); win.instance_variable_set(:@index, 0)
  win.define_singleton_method(:index) { 0 }
  win.update_help
  emit.call('help', n, help.text.to_s[/\/(\d+)/, 1])
end

# practice：ok / E0 超过基础武功等级 / E1 不能用当前武器练 / E2 内力不足（不应出现）/ 异常类名
sc = Scene_Practice.allocate
sc.instance_variable_set(:@err, %w[E0 E1 E2 E3 E4])
WEAPONS.each do |w|
  [100, 0].each do |base|
    r = SKILLS.map do |n|
      reset.call; equip.call(w)
      $game_variables[19] = 10**9; $game_variables[24] = 10**9; $game_variables[157] = 14
      (39..47).each { |i| $game_variables[i] = base }
      $game_variables[n] = base == 0 && (39..47).include?(n) ? 0 : 5
      # 异常也作为结果记录：原版对未登记类型的武器（31 号以后）会在这里抛 NoMethodError
      res = begin
        sc.check(n) ? 'ok' : sc.instance_variable_get(:@msg)
      rescue StandardError => e
        e.class.name
      end
      "#{n}:#{res}"
    end
    emit.call('practice', "w#{w} 基础#{base}", r.join(' '))
  end
end

# npc
en = Game_Enemy.allocate
WEAPONS.each do |w|
  m = SKILLS.select { |n| $npc_data = [0, 0, 0, 0, 0, n]; en.npc_weapon?(w) }
  emit.call('npc', w, "base=#{en.npc_base_skill(w).inspect} match=#{m.join(',')}")
end
# 硬性检查（不进基准，--update 也不能跳过）：注册表接管后才有意义
if defined?(WebSkill)
  $data_weapons.each_with_index do |w, i|
    next if w.nil? || i == 0
    emit.call('check', "weapon#{i}", "武器 #{i}「#{w.name}」没有在 WebSkill::WEAPON_TYPES 登记类型") unless WebSkill.weapon_base(i)
  end
  WebSkill::SKILLS.each_key do |id|
    emit.call('check', "name#{id}", "武功 #{id} 在数据库里没有名字") if $data_system.variables[id].to_s.empty?
    emit.call('check', "point#{id}", "武功 #{id} 的点数变量 #{WebSkill.point_var(id)} 与已占用的变量 91～96 / 151～160 冲突") if (91..96).include?(WebSkill.point_var(id)) || (151..160).include?(WebSkill.point_var(id))
  end
end
lines.join("\n")
`).toString();

const result = {};
for (const line of out.split('\n')) {
  const [group, key, value] = line.split('\t');
  (result[group] ??= {})[key] = value;
}

const checks = Object.values(result.check ?? {});
delete result.check;
if (checks.length) {
  console.log('注册表检查失败：\n  ' + checks.join('\n  '));
  process.exit(1);
}

if (update) {
  await fs.mkdir(new URL('tools/fixtures/', ROOT), { recursive: true });
  await fs.writeFile(FIXTURE, JSON.stringify(result, null, 1) + '\n');
  const n = Object.values(result).reduce((a, g) => a + Object.keys(g).length, 0);
  console.log(`已写入基准 ${FIXTURE.pathname}（${n} 项）`);
  process.exit(0);
}

const expected = JSON.parse(await fs.readFile(FIXTURE, 'utf8'));
const diffs = [];
for (const group of new Set([...Object.keys(expected), ...Object.keys(result)])) {
  const e = expected[group] ?? {}, r = result[group] ?? {};
  for (const key of new Set([...Object.keys(e), ...Object.keys(r)])) {
    if (e[key] !== r[key]) diffs.push(`[${group}] ${key}\n    基准: ${e[key]}\n    现在: ${r[key]}`);
  }
}
if (diffs.length) {
  console.log(diffs.join('\n'));
  console.log(`\n${diffs.length} 处与基准不同。有意的修改请确认后用 --update 更新基准。`);
  process.exit(1);
}
console.log('与基准一致');
