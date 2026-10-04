// 在 Node 里无界面载入游戏，供测试和工具使用。
//
//   import { bootGame } from './headless-game.mjs';
//   const rb = await bootGame();     // rb('Ruby 代码') -> 结果字符串
//
// 用线上同一个 public/ruby.wasm 载入构建产物 public/game/scripts.json（不含 117 Main），
// 渲染层 RG 用空桩代替，并初始化数据库和常用游戏对象（$game_variables、$game_party、$game_map 等）。
// 修改 game-src/scripts 或 src/game 后要先运行 python3 tools/build.py。
import fs from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import { WASI } from 'node:wasi';
import { RubyVM } from '@ruby/wasm-wasi';

const ROOT = new URL('../', import.meta.url);

export async function bootGame() {
  const module = await WebAssembly.compile(await fs.readFile(new URL('public/ruby.wasm', ROOT)));
  const wasi = new WASI({ version: 'preview1', args: ['ruby'], preopens: {
    '/game': new URL('public/game', ROOT).pathname,
    '/work': await fs.mkdtemp(path.join(os.tmpdir(), 'headless-game-')),   // 116 容错脚本载入时会在当前目录建 errors.txt
  } });
  const { vm } = await RubyVM.instantiateModule({ module, wasip1: wasi });
  globalThis.RG = new Proxy({}, { get: () => () => 0 });
  globalThis.RGScripts = JSON.parse(await fs.readFile(new URL('public/game/scripts.json', ROOT), 'utf8'))
    .filter(([name]) => name !== '117:Main');
  for (const f of ['rgss_core', 'rgss_kernel', 'rpg']) vm.eval(await fs.readFile(new URL(`src/ruby/${f}.rb`, ROOT), 'utf8'));
  vm.eval(String.raw`
    Dir.chdir('/work')
    s = JS.global[:RGScripts]
    s[:length].to_i.times { |i| TOPLEVEL_BINDING.eval(s[i][1].to_s, s[i][0].to_s, 1) }
    Dir.chdir('/game')    # 脚本载完后再切到游戏目录：Game_Map#setup 等按相对路径读 Data/
    def data_path(name) = "/game/Data/#{name}"
    $data_system        = load_data(data_path('System.rxdata'))
    $data_actors        = load_data(data_path('Actors.rxdata'))
    $data_classes       = load_data(data_path('Classes.rxdata'))
    $data_skills        = load_data(data_path('Skills.rxdata'))
    $data_items         = load_data(data_path('Items.rxdata'))
    $data_weapons       = load_data(data_path('Weapons.rxdata'))
    $data_armors        = load_data(data_path('Armors.rxdata'))
    $data_enemies       = load_data(data_path('Enemies.rxdata'))
    $data_troops        = load_data(data_path('Troops.rxdata'))
    $data_states        = load_data(data_path('States.rxdata'))
    $data_tilesets      = load_data(data_path('Tilesets.rxdata'))
    $data_common_events = load_data(data_path('CommonEvents.rxdata'))
    $data_mapinfos      = load_data(data_path('MapInfos.rxdata'))
    $game_temp          = Game_Temp.new
    $game_system        = Game_System.new
    $game_switches      = Game_Switches.new
    $game_variables     = Game_Variables.new
    $game_self_switches = Game_SelfSwitches.new
    $game_actors        = Game_Actors.new
    $game_party         = Game_Party.new
    $game_party.actors.push($game_actors[1])
    $game_map           = Game_Map.new
    nil
  `);
  return (code) => vm.eval(code).toString();
}
