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

  # 去掉“交谈”分支的内容（保留选项本身），用于比较用 talk 改过台词的 NPC 其余部分是否原样
  def without_talk(event)
    e = Marshal.load(Marshal.dump(event))
    e.pages.each do |pg|
      l = pg.list
      i = l.index { |c| c.code == 402 && c.parameters[1] == '交谈' } or next
      j = i + 1
      j += 1 while j < l.size && l[j].indent > l[i].indent
      l.slice!(i + 1...j)
    end
    e
  end

  # 去掉商品（605），用于比较用 goods 添过货的商人其余部分是否原样
  def without_goods(event)
    e = Marshal.load(Marshal.dump(event))
    e.pages.each { |pg| pg.list.reject! { |c| c.code == 605 } }
    e
  end

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
      b = WebMod::Builder.new(WebMod.raw_load(path(id)), id, WebMod::FIRST_EDIT_EVENT_ID)
      WebMod.edits[id].each { |blk| blk.call(b) }
      raw.events.each do |eid, e|
        if b.stocked_events.include?(eid)
          errors << "地图 #{id} 的原版事件 #{eid}（#{e.name}）除商品外被改动" unless cur.events[eid] && dump(without_goods(cur.events[eid])) == dump(without_goods(e))
        elsif b.touched_events.include?(eid)
          errors << "地图 #{id} 的原版事件 #{eid}（#{e.name}）除交谈内容外被改动" unless cur.events[eid] && dump(without_talk(cur.events[eid])) == dump(without_talk(e))
        else
          errors << "地图 #{id} 的原版事件 #{eid} 被改动" unless cur.events[eid] && dump(cur.events[eid]) == dump(e)
        end
      end
      (cur.events.keys - raw.events.keys).each do |eid|
        errors << "地图 #{id} 新增事件编号 #{eid} 小于 #{WebMod::FIRST_EDIT_EVENT_ID}" if eid < WebMod::FIRST_EDIT_EVENT_ID
      end
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
      map.events.each_value do |e|
        e.pages.each do |pg|
          n = pg.graphic.character_name.to_s
          errors << "地图 #{id} 事件 #{e.id}（#{e.name}）的行走图 #{n} 不存在" unless n.empty? || File.exist?("/game/Graphics/Characters/#{n}.png")
        end
      end
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
    errors.concat(enemy_errors)
    errors
  end

  # 能战斗的 NPC：敌人、敌群、数值表、战斗图
  def enemy_errors
    errors = []
    enemies = load_data('/game/Data/Enemies.rxdata')
    troops = load_data('/game/Data/Troops.rxdata')
    WebMod.enemies.each do |id, d|
      e = enemies[id]
      t = troops[id]
      errors << "敌人 #{id} 没有生成" unless e && e.id == id && e.name == d[:name]
      errors << "敌群 #{id} 的成员不是敌人 #{id}" unless t && t.members.map(&:enemy_id) == [id]
      errors << "敌人 #{id} 的战斗图 #{e&.battler_name} 不存在" unless e && File.exist?("/game/Graphics/Battlers/#{e.battler_name}.png")
      row = get_npc_data(id)
      unless row.is_a?(Array) && row.size == 31
        errors << "敌人 #{id} 的数值表不是 31 项"
        next
      end
      errors << "敌人 #{id} 的武器 #{row[9]} 不存在" if row[9] != 0 && !$data_weapons[row[9]]
      [10, 11].each { |i| errors << "敌人 #{id} 的装备 #{row[i]} 不存在" if row[i] != 0 && !$data_armors[row[i]] }
      row[12, 12].each do |sk, lv|
        errors << "敌人 #{id} 的武功 #{sk} 没有在武功注册表登记" if sk != 0 && !WebSkill::SKILLS.key?(sk)
      end
      (4..8).each do |i|
        sk = row[i]
        errors << "敌人 #{id} 启用的武功 #{sk} 不在它的武功列表里" if sk != 0 && row[12, 12].none? { |s, _| s == sk }
      end
    end
    used = []
    (WebMod.maps.keys | WebMod.edits.keys).each do |mid|
      load_data(path(mid)).events.each_value do |ev|
        ev.pages[0].list.each { |c| used << c.parameters[0] if c.code == 301 && c.parameters[0] >= WebMod::FIRST_ENEMY_ID }
      end
    end
    # 江湖奇遇等公共事件里的战斗也算
    load_data('/game/Data/CommonEvents.rxdata').compact.each do |ce|
      ce.list.each { |c| used << c.parameters[0] if c.code == 301 && c.parameters[0] >= WebMod::FIRST_ENEMY_ID }
    end
    (WebMod.enemies.keys - used).each { |id| errors << "敌人 #{id} 定义了，但没有放到任何地图或公共事件里" }
    (used - WebMod.enemies.keys).each { |id| errors << "地图上的战斗用到敌群 #{id}，但没有定义" }
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

// 一（续）、扩展层加的事件都要真的走得到：从地图的每个入口出发按真实通行规则走（不踩出口），
//   踩上去触发的事件要能站上去，确定键触发的要能走到它旁边。只“传送”过去测是发现不了的。
{
  const errors = rb(String.raw`
    errors = []
    maps = WebMod.maps.keys | WebMod.edits.keys
    transfers = Hash.new { |h, k| h[k] = [] }
    ($data_mapinfos.keys | WebMod.maps.keys).each do |id|
      load_data(format('/game/Data/Map%03d.rxdata', id)).events.each_value do |e|
        e.pages.each { |pg| pg.list.each { |c| transfers[c.parameters[1]] << c.parameters[2..3] if c.code == 201 && c.parameters[0] == 0 } }
      end
    end
    maps.sort.each do |mid|
      first = WebMod.maps.key?(mid) ? 1 : WebMod::FIRST_EDIT_EVENT_ID
      $game_map.setup(mid)
      $game_player = Game_Player.new
      added = $game_map.events.values.select { |e| e.id >= first && e.list.none? { |c| c.code == 201 } }
      next if added.empty?
      exits = $game_map.events.values.select { |e| [1, 2].include?(e.trigger) && e.list.any? { |c| c.code == 201 } }.map { |e| [e.x, e.y] }
      entries = transfers[mid].uniq
      errors << "地图 #{mid} 没有入口" if entries.empty?
      entries.each do |entry|
        $game_player.moveto(*entry)
        seen = { entry => true }; queue = [entry]
        until queue.empty?
          x, y = queue.shift
          [[2, 0, 1], [4, -1, 0], [6, 1, 0], [8, 0, -1]].each do |d, dx, dy|
            xy = [x + dx, y + dy]
            next if seen[xy] || exits.include?(xy) || !$game_player.passable?(x, y, d)
            seen[xy] = true; queue << xy
          end
        end
        added.each do |e|
          name = e.instance_variable_get(:@event).name
          ok = if e.trigger == 0
                 [[0, 1], [0, -1], [1, 0], [-1, 0]].any? { |dx, dy| seen[[e.x + dx, e.y + dy]] } || seen[[e.x, e.y]]
               else
                 seen[[e.x, e.y]]
               end
          errors << "地图 #{mid} 的#{name}（#{e.x},#{e.y}）从入口 #{entry.inspect} 走不到" unless ok
        end
      end
    end
    errors.uniq.join("\n")
  `).split('\n').filter(Boolean);
  console.log(`一（续）、事件可到达：${errors.length ? `${errors.length} 个问题` : '通过'}`);
  for (const e of errors) console.log('  ' + e);
  failures.push(...errors);
}

// 二、示例内容：用地图 6（老婆婆家）的地形做一张新地图，北郊加一个入口
rb(String.raw`
# 先清空实际内容，示例不受它们影响（第一部分已检查过）
WebMod.maps.clear
WebMod.edits.clear
WebMod.enemies.clear
WebMod.instance_variable_get(:@auto_events).clear      # 江湖奇遇的公共事件
WebMod.enemy 144, name: '测试武师', tile: 852, like: 30, maxhp: 300, gold: 50,
             stats: { 膂力: 30, 闪避: 20, 拳脚: 58, 经验: 50000 }, skills: { 40 => 80, 58 => 60, 47 => 50 }
WebMod.map 90, name: '测试地图', parent: 21, base: 6 do |m|
  m.npc 11, 8, fight: { enemy: 144, loot: [[:armor, 4], [:item, 16, 2]], morality: [-10, -5], switch: 103 },
        talk: ['来比划比划？'], look: '一个精壮的武师。'
  m.npc 9, 6, name: '测试老人', tile: 850, talk: ['第一页。', '第二页。'], look: { age: 6, text: '一位测试用的老人。' }
  m.npc 5, 6, name: '分支老人', tile: 851 do |c|
    c.if_switch(102) { c.text '开关已开。' }.else { c.text '开关未开。'; c.switch(102) }
  end
  m.door 9, 13, to: [21, 9, 3], dir: 2
end
WebMod.edit 21 do |m|
  m.door 9, 3, to: [90, 9, 12], dir: 8
  m.tile 5, 5, 1, 0
  m.talk('采花大盗') { |c| c.one_of('第一句。', '第二句。', '第三句。') }
end
WebMod.edit 15 do |m|
  m.talk('小商贩', override: true) { |c| c.if_good { c.text '好人。' }.else { c.text '坏人。' } }
end
nil
`);
rb('$data_enemies = load_data("/game/Data/Enemies.rxdata"); $data_troops = load_data("/game/Data/Troops.rxdata"); nil');
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
  out << "新地图事件编号应从 1 开始：#{m.events.keys.sort.inspect}" unless m.events.keys.sort == [1, 2, 3, 4]
  # 能战斗的 NPC：与原版道德和尚（地图 3 事件 4）的战斗分支对照，原版多出的“平一指任务”判断不生成
  fighter = m.events.values.find { |e| e.name == '测试武师' }
  fl = fighter.pages[0].list
  got = shape.call(fl)
  want = '0:355 0:102 0:402 1:101 1:0 0:402 1:355 1:0 0:402 1:355 1:655 1:655 1:655 1:655 1:301 1:601 ' +
         '2:111 3:111 4:122 4:0 3:411 4:122 4:0 3:412 3:123 3:121 3:355 3:655 3:0 2:412 2:128 2:126 2:121 2:0 ' +
         '1:602 2:0 1:603 2:117 2:0 1:604 1:0 0:403 1:0 0:404 0:355 0:0'
  out << "战斗 NPC 指令骨架不对：#{got}" unless got == want
  p = lambda { |code| fl.find { |c| c.code == code }.parameters }
  out << "战斗参数错误：#{p.call(301).inspect}" unless p.call(301) == [144, true, true]
  out << "战利品名字错误：#{fl.select { |c| c.code == 655 }.map { |c| c.parameters[0] }.inspect}" unless fl.select { |c| c.code == 655 }.map { |c| c.parameters[0] }.first(2) == ['$trea1=$data_armors[4].name', '$trea2=$data_items[16].name']
  out << "道德变化错误" unless fl.select { |c| c.code == 122 }.map(&:parameters) == [[160, 160, 2, 0, 10], [160, 160, 2, 0, 5]]
  out << "掉落指令错误" unless [p.call(128), p.call(126)] == [[4, 0, 0, 1], [16, 0, 0, 2]]
  out << "选项错误：#{p.call(102).inspect}" unless p.call(102) == [%w[交谈 查看 战斗], 5]
  pg2 = fighter.pages[1]
  out << '尸体页错误' unless pg2 && pg2.condition.self_switch_valid && pg2.condition.self_switch_ch == 'A' && pg2.graphic.tile_id == 508
  # 敌人数据
  en = $data_enemies[144]
  out << "敌人数据错误：#{[en.name, en.battler_name, en.maxhp, en.gold].inspect}" unless [en.name, en.battler_name, en.maxhp, en.gold] == ['测试武师', 'NPC_Tile_29', 300, 50]
  row = get_npc_data(144)
  out << "数值表错误：#{row.inspect}" unless row[0] == 30 && row[25] == 20 && row[4] == 58 && row[26] == 50000 && row[12, 3] == [[40, 80], [58, 60], [47, 50]] && row[15] == [0, 0] && row[1] == get_npc_data(30)[1]
  out << '模板 30 的数值表被改动' unless get_npc_data(30)[0] == 21
  # talk：只替换“一般交谈”那一条，任务判断原样保留
  raw21 = WebMod.raw_load('/game/Data/Map021.rxdata').events[1].pages[0].list
  cur21 = load_data('/game/Data/Map021.rxdata').events[1].pages[0].list
  k = raw21.index { |c| c.code == 117 && c.parameters[0] == 3 }
  ind = raw21[k].indent
  got = cur21[k, 13].map { |c| "#{c.indent - ind}:#{c.code}" }.join(' ')
  out << "talk 替换结构错误：#{got}" unless got == '0:355 0:111 1:101 1:0 0:412 0:111 1:101 1:0 0:412 0:111 1:101 1:0 0:412'
  out << "talk 替换后其余指令不一致" unless Marshal.dump(cur21[k + 13..].map { |c| [c.code, c.indent, c.parameters] }) == Marshal.dump(raw21[k + 1..].map { |c| [c.code, c.indent, c.parameters] })
  out << "talk 前面的指令不一致" unless Marshal.dump(cur21[0, k].map { |c| [c.code, c.indent, c.parameters] }) == Marshal.dump(raw21[0, k].map { |c| [c.code, c.indent, c.parameters] })
  # override：保留平一指任务判断，只换 else 里的台词
  l15 = load_data('/game/Data/Map015.rxdata').events[2].pages[0].list
  i = l15.index { |c| c.code == 402 && c.parameters[1] == '交谈' }
  seg = l15[i + 1, 12].map { |c| "#{c.indent - l15[i].indent}:#{c.code}" }.join(' ')
  out << "override 结构错误：#{seg}" unless seg == '1:111 2:101 2:121 2:122 2:0 1:411 2:111 3:101 3:0 2:411 3:101 3:0'
  out << 'override 丢了任务判断参数' unless l15[i + 1].parameters == [1, 2, 0, 15, 0]
  begin
    WebMod::Builder.new(WebMod.raw_load('/game/Data/Map015.rxdata'), 15, 1001).talk('小商贩') { |c| c.text 'x' }
    out << '对有自己台词的 NPC 不加 override 没有报错'
  rescue ArgumentError
  end
  out << '流星飞掷免疫判断错误' unless [WebMod.finisher_immune?(144), WebMod.finisher_immune?(126), WebMod.finisher_immune?(30)] == [false, true, false]
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
