// 查看地图的通行表和事件，用来确定 NPC 和传送点的摆放坐标。
//
//   node tools/mapview.mjs 3            查看地图 3（含扩展层的修改）
//   node tools/mapview.mjs 3 --raw      查看原版地图 3（不经过扩展层）
//   node tools/mapview.mjs list         列出全部地图（含扩展层新增的）
//
// 图例：. 可走  X 不可走（只看地形）  事件用 A、B、C… 标出，下方列出明细。
// 读的是构建产物，修改 src/game/mods 后先运行 python3 tools/build.py。
import { bootGame } from './headless-game.mjs';

const arg = process.argv[2];
if (!arg) {
  console.log('用法：node tools/mapview.mjs 地图编号 [--raw] | list');
  process.exit(1);
}
const rb = await bootGame();

if (arg === 'list') {
  console.log(rb(String.raw`
    $data_mapinfos.keys.sort.map { |id|
      i = $data_mapinfos[id]
      "#{id.to_s.rjust(3)} #{i.name}#{i.parent_id > 0 ? "（属于 #{i.parent_id} #{$data_mapinfos[i.parent_id]&.name}）" : ''}#{WebMod.maps[id] ? '  [扩展]' : ''}"
    }.join("\n")
  `));
  process.exit(0);
}

const id = Number(arg);
const raw = process.argv.includes('--raw');
console.log(rb(String.raw`
  id = ${id}
  map = ${raw ? `WebMod.raw_load(format('/game/Data/Map%03d.rxdata', id))` : `load_data(format('/game/Data/Map%03d.rxdata', id))`}
  $game_map.setup(id) unless ${raw}
  # 只看地形：临时去掉事件再判断通行
  saved = $game_map.events.dup
  $game_map.events.clear
  marks = {}
  letters = ('A'..'Z').to_a + ('a'..'z').to_a
  map.events.keys.sort.each_with_index { |eid, i| marks[[map.events[eid].x, map.events[eid].y]] = letters[i % letters.size] }
  out = []
  name = $data_mapinfos[id] ? $data_mapinfos[id].name : '（未登记）'
  out << "地图 #{id} #{name}  #{map.width}×#{map.height}  #{${raw} ? '原版' : '含扩展层'}"
  out << '    ' + (0...map.width).map { |x| (x % 10).to_s }.join(' ')
  (0...map.height).each do |y|
    row = (0...map.width).map do |x|
      marks[[x, y]] || (${raw} ? '?' : ($game_map.passable?(x, y, 0) ? '.' : 'X'))
    end
    out << y.to_s.rjust(3) + ' ' + row.join(' ')
  end
  saved.each { |k, v| $game_map.events[k] = v }
  out << ''
  map.events.keys.sort.each_with_index do |eid, i|
    e = map.events[eid]
    pg = e.pages[0]
    trig = %w[确定键 接触 事件接触 自动 并行][pg.trigger]
    desc = pg.list.select { |c| c.code == 201 }.map { |c| p = c.parameters; "→ 地图#{p[1]} (#{p[2]},#{p[3]})" }.join(' ')
    out << "#{letters[i % letters.size]}  事件#{eid.to_s.ljust(4)} (#{e.x},#{e.y})  #{e.name}  头像#{pg.graphic.tile_id}  #{trig}  #{e.pages.size}页 #{desc}"
  end
  out.join("\n")
`));
