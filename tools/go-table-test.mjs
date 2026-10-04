// Check real player movement from every incoming transfer, including exit triggers.
// Rebuild scripts before running: node tools/go-table-test.mjs
import assert from 'node:assert/strict';
import { bootGame } from './headless-game.mjs';

const rb = await bootGame();
const result = rb(String.raw`
  entrances = $data_mapinfos.keys.flat_map do |id|
    load_data(format('/game/Data/Map%03d.rxdata', id)).events.values.flat_map do |e|
      e.pages.flat_map { |pg| pg.list.select { |c| c.code == 201 && c.parameters[0] == 0 && c.parameters[1] == 12 }.map { |c| c.parameters[2..3] } }
    end
  end.uniq
  raise 'No entrances found' if entrances.empty?
  errors = []
  # Test the event both before and after solving the puzzle.
  [false, true].each do |solved|
    $game_switches[106] = solved
    entrances.each do |entry|
      $game_map.setup(12)
      $game_player = Game_Player.new
      $game_player.moveto(*entry)
      table = $game_map.events.values.find { |e| e.character_name == 'Prop_StoneTable' }
      raise 'Stone table missing' unless table
      exits = $game_map.events.values.select { |e| [1,2].include?(e.trigger) && e.list.any? { |c| c.code == 201 } }.map { |e| [e.x,e.y] }
      dirs = [[2,0,1], [4,-1,0], [6,1,0], [8,0,-1]]
      seen = {entry => true}; queue = [entry]; approach = nil
      until queue.empty?
        x,y = queue.shift
        dirs.each do |d,dx,dy|
          xy = [x+dx,y+dy]
          approach ||= [x,y,d] if xy == [table.x,table.y]
          next if seen[xy] || exits.include?(xy) || !$game_player.passable?(x,y,d)
          seen[xy] = true; queue << xy
        end
      end
      unless approach
        errors << "Entrance #{entry.inspect}: cannot reach table at #{[table.x,table.y].inspect} (solved=#{solved})"
        next
      end
      x,y,d = approach
      $game_player.moveto(x,y)
      $game_player.instance_variable_set(:@direction, d)
      errors << 'Table must block walking through it' if $game_player.passable?(x,y,d)
      errors << 'Confirm must start the table event' unless $game_player.check_event_trigger_there([0]) && table.starting
    end
  end
  errors.empty? ? 'ok' : errors.join("\n")
`);
assert.equal(result, 'ok');
console.log('Stone table reachable and interactive from both entrances, before/after solving: PASS');
