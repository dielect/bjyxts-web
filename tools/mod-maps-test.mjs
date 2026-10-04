// 地图扩展层的回归测试。
//
//   node tools/mod-maps-test.mjs
//
// 一、检查 src/game/mods 里实际登记的内容：
//   - 没有声明修改的原版地图，经过 load_data 后与原版完全一致；
//   - 声明修改的原版地图：原有事件不变，地形只在 tile 声明的格子变化，新事件编号从 1001 起；
//   - 新地图都登记了地图名，父地图存在；
//   - 传送点：目标地图存在，落点在范围内且可以走；传送点本身站得上去；
//     通往新地图的传送点，目标地图上要有回到原地图的传送点；
//   - 同一格不放两个事件。
// 二、用测试内置的示例内容检查引擎本身：NPC 指令与原版模板一致、条件分支结构正确、
//   示例内容也通过第一部分的全部检查。
// 读的是构建产物，修改 src/game 后先运行 python3 tools/build.py。
import { bootGame } from './headless-game.mjs';

const rb = await bootGame();

rb(String.raw`
module ModCheck
  module_function

  def path(id) = format('/game/Data/Map%03d.rxdata', id)
  def dump(o) = Marshal.dump(o)

  def map_exists?(id) = WebMod::ORIGINAL_MAPS.include?(id) || WebMod.maps.key?(id)

  def passable?(map_id, x, y)
    $game_map.setup(map_id)                   # Game_Event 初始化时读全局 $game_map，不能另建实例
    $game_map.events.clear                    # 只看地形
    $game_map.valid?(x, y) && $game_map.passable?(x, y, 0)
  end

  def doors(map)
    map.events.values.flat_map do |e|
      e.pages[0].list.select { |c| c.code == 201 && c.parameters[0] == 0 }.map { |c| [e, c.parameters[1..3]] }
    end
  end

  def run
    errors = []
    infos = load_data('/game/Data/MapInfos.rxdata')
    WebMod::ORIGINAL_MAPS.each do |id|
      raw = WebMod.raw_load(path(id))
      cur = load_data(path(id))
      unless WebMod.edits.key?(id)
        errors << "地图 #{id} 没有声明修改，但载入结果与原版不同" unless dump(raw) == dump(cur)
        next
      end
      raw.events.each do |eid, e|
        errors << "地图 #{id} 的原版事件 #{eid} 被改动" unless cur.events[eid] && dump(cur.events[eid]) == dump(e)
      end
      (cur.events.keys - raw.events.keys).each do |eid|
        errors << "地图 #{id} 新增事件编号 #{eid} 小于 #{WebMod::FIRST_EDIT_EVENT_ID}" if eid < WebMod::FIRST_EDIT_EVENT_ID
      end
      declared = []
      b = WebMod::Builder.new(WebMod.raw_load(path(id)), id, WebMod::FIRST_EDIT_EVENT_ID)
      WebMod.edits[id].each { |blk| blk.call(b) }
      declared = b.tile_edits
      (0...raw.width).each do |x|
        (0...raw.height).each do |y|
          (0...3).each do |z|
            next if raw.data[x, y, z] == cur.data[x, y, z] || declared.include?([x, y, z])
            errors << "地图 #{id} 的地形 (#{x},#{y}) 第 #{z} 层被改动，但没有用 tile 声明"
          end
        end
      end
    end
    WebMod.maps.each do |id, d|
      errors << "新地图 #{id} 没有登记到 MapInfos" unless infos[id] && infos[id].name == d[:name]
      errors << "新地图 #{id} 的父地图 #{d[:parent]} 不存在" if d[:parent] != 0 && !map_exists?(d[:parent])
    end
    touched = WebMod.edits.keys | WebMod.maps.keys
    touched.each do |id|
      map = load_data(path(id))
      cells = map.events.values.group_by { |e| [e.x, e.y] }
      cells.each { |xy, es| errors << "地图 #{id} 的 (#{xy.join(',')}) 有 #{es.size} 个事件" if es.size > 1 }
      doors(map).each do |e, (to, x, y)|
        # 只检查扩展层加的传送点
        next if WebMod.edits.key?(id) && e.id < WebMod::FIRST_EDIT_EVENT_ID
        where = "地图 #{id} 事件 #{e.id} (#{e.x},#{e.y})"
        errors << "#{where}：传送点所在格子走不上去" if e.pages[0].trigger == 1 && !passable?(id, e.x, e.y)
        unless map_exists?(to)
          errors << "#{where}：目标地图 #{to} 不存在"
          next
        end
        errors << "#{where}：落点 (#{x},#{y}) 在地图 #{to} 上走不了或超出范围" unless passable?(to, x, y)
        if WebMod.maps.key?(to) && doors(load_data(path(to))).none? { |_, t| t[0] == id }
          errors << "#{where}：新地图 #{to} 上没有回到地图 #{id} 的传送点"
        end
      end
    end
    errors
  end
end
nil
`);

const failures = [];
const check = (label) => {
  const errors = rb('ModCheck.run.join("\n")').split('\n').filter(Boolean);
  console.log(`${label}：${errors.length ? `${errors.length} 个问题` : '通过'}`);
  for (const e of errors) console.log('  ' + e);
  failures.push(...errors);
};

// 一、实际登记的内容
console.log(rb('"已登记：新地图 #{WebMod.maps.keys.sort.inspect}，修改的原版地图 #{WebMod.edits.keys.sort.inspect}"'));
check('一、实际内容');

// 二、示例内容：用地图 6（老婆婆家）的地形做一张新地图，北郊加一个入口
rb(String.raw`
# 先清空实际内容，示例不受它们影响（第一部分已检查过）
WebMod.maps.clear
WebMod.edits.clear
WebMod.map 90, name: '测试地图', parent: 21, base: 6 do |m|
  m.npc 9, 6, name: '测试老人', tile: 850, talk: ['第一页。', '第二页。'], look: { age: 6, text: '一位测试用的老人。' }
  m.npc 5, 6, name: '分支老人', tile: 851 do |c|
    c.if_switch(102) { c.text '开关已开。' }.else { c.text '开关未开。'; c.switch(102) }
  end
  m.door 9, 13, to: [21, 9, 3], dir: 2
end
WebMod.edit 21 do |m|
  m.door 9, 3, to: [90, 9, 12], dir: 8
  m.tile 5, 5, 1, 0
end
nil
`);
check('二、示例内容');

// 引擎结构检查
const structure = rb(String.raw`
  out = []
  m = load_data('/game/Data/Map090.rxdata')
  shape = lambda { |list| list.map { |c| "#{c.indent}:#{c.code}" }.join(' ') }
  npc = m.events.values.find { |e| e.name == '测试老人' }
  # 原版道德和尚（地图 3 事件 4）去掉“战斗”分支后的骨架
  expected = '0:355 0:102 0:402 1:101 1:101 1:0 0:402 1:355 1:0 0:403 1:0 0:404 0:355 0:0'
  out << "NPC 指令骨架与原版模板不同：#{shape.call(npc.pages[0].list)}" unless shape.call(npc.pages[0].list) == expected
  out << "NPC 查看参数错误：#{npc.pages[0].list[7].parameters[0]}" unless npc.pages[0].list[7].parameters[0] == '$scene=Lookover.new("测试老人","6",$levels[0],$attacks[0],"布衣","一位测试用的老人。")'
  ref = WebMod.raw_load('/game/Data/Map003.rxdata').events[4].pages[0].list
  out << '原版模板首尾指令不同' unless [ref[0], ref[-2]].map(&:parameters) == [npc.pages[0].list[0], npc.pages[0].list[-2]].map(&:parameters)
  branch = m.events.values.find { |e| e.name == '分支老人' }.pages[0].list
  got = shape.call(branch[3, 8])   # 交谈分支内的条件分歧
  out << "条件分支结构错误：#{got}" unless got == '1:111 2:101 2:0 1:411 2:101 2:121 2:0 1:412'
  out << "新地图事件编号应从 1 开始：#{m.events.keys.sort.inspect}" unless m.events.keys.sort == [1, 2, 3]
  e21 = load_data('/game/Data/Map021.rxdata').events.keys.sort
  out << "北郊新增事件编号应为 1001：#{e21.inspect}" unless e21.last == 1001
  begin
    WebMod.map 91, name: '越界', base: 6 do |mm| mm.npc 99, 99, name: 'x', tile: 850 end
    load_data('/game/Data/Map091.rxdata')
    out << '坐标越界没有报错'
  rescue ArgumentError => e
    out << "越界报错信息不对：#{e.message}" unless e.message.include?('超出地图范围')
  end
  WebMod.maps.delete(91)
  out.join("\n")
`).split('\n').filter(Boolean);
console.log(`引擎结构：${structure.length ? `${structure.length} 个问题` : '通过'}`);
for (const e of structure) console.log('  ' + e);
failures.push(...structure);

if (failures.length) process.exit(1);
