#==============================================================================
# ■ 生活玩法引擎：日历、存档数据、钓鱼、熟客、订单、鱼谱（设计见 docs/职业生活与武林互动设计.md）
#------------------------------------------------------------------------------
#  构建时紧接装备特效载入，内容写在 src/game/mods/110_钓鱼与客栈.rb。
#
#  ■ 日历（按原版规则）
#    原版只有一个时间变量 158：在地图上每 200 帧（约 5 秒）加 1，满 3000 长一岁（公共事件 4）；
#    家里睡一觉（要喝一瓶女儿红，“能醉上三个月”）加 750。所以：
#      一年 3000、一季 750、一月 250、一天约 8.3（3000 ÷ 360）。
#    天数从 14 岁起算：WebLife.day = ((年龄 − 14) × 3000 + 变量158) × 360 ÷ 3000
#    季节 = 变量158 ÷ 750：0 春 1 夏 2 秋 3 冬。睡一觉正好换一季。
#
#  ■ 存档数据
#    生活玩法的数据都放在 $game_system 的一个实例变量 @web_life 里（一个 Hash），随存档一起保存：
#      :v        数据版本（以后改格式时据此迁移）
#      :fish     鱼谱 { 物品编号 => [钓到的条数, 最大的一条（两）] }
#      :skill    { fishing: 熟练度 }
#      :clients  熟客 { :jose => { favor:, shown: [给他看过的鱼] }, :cook => { favor:, done: 完成的订单数 } }
#      :order    当前订单 { client:, item:, qty:, pay:, day: 接单的日子 } 或 nil
#      :flags    杂项开关（Symbol => true）
#    只用 Hash / Array / Integer / Symbol / String，存档导回 PC 原版也能正常读取（多出的实例变量会被忽略）。
#    地图事件的出现条件需要开关时，另用剧情开关（见 110 的编号登记）。
#==============================================================================
module WebLife
  VERSION = 1
  SEASONS = %w[春 夏 秋 冬]

  # ---- 鱼：物品编号 => { name:, water:, seasons:, rarity:, weight: [最小两, 最大两], price: }
  #   water   :pond 南郊鱼塘（淡水） :sea 冰火岛渡口（海）
  #   rarity  0 常见 1 少见 2 稀有 3 难得一见
  FISH = {}
  RARITY = [60, 25, 10, 2]                       # 各档的基础权重
  RARITY_NAME = %w[常见 少见 稀有 难得一见]

  @clients = {}                                  # 熟客定义（称呼档位等），内容文件登记

  # 钓竿（防具，钓竿位）=> 效果：bite 咬钩率 +%，rare 稀罕鱼加成，keep “再等等”留住鱼的几率 +%，
  #   size 鱼的重量 +%，sea 海钓时的额外咬钩率与稀罕加成（负数表示在鱼塘反而差），fast 一次只过 1 个时辰，
  #   legend “难得一见”的鱼的权重倍数。内容文件用 WebLife.rod_effect 登记
  RODS = {}

  # 渔技 1～10：熟练度 0、10、25、45、70、100、140、190、250、320
  SKILL_STEPS = [0, 10, 25, 45, 70, 100, 140, 190, 250, 320]

  class << self
    attr_reader :clients

    def fish(id, name:, water:, seasons: [0, 1, 2, 3], rarity: 0, weight: [4, 16], price: 30)
      FISH[id] = { id: id, name: name, water: water, seasons: seasons, rarity: rarity, weight: weight, price: price }
    end

    # ---------------------------------------------------------------- 存档数据
    def data
      s = $game_system
      d = s.instance_variable_get(:@web_life)
      unless d.is_a?(Hash) && d[:v] == VERSION
        d = migrate(d)
        s.instance_variable_set(:@web_life, d)
      end
      d
    end

    def migrate(old)
      d = { v: VERSION, fish: {}, skill: { fishing: 0 }, clients: {}, order: nil, flags: {} }
      d.merge!(old.reject { |k, _| k == :v }) if old.is_a?(Hash)
      d[:v] = VERSION
      d
    end

    def flag?(k) = data[:flags][k] == true
    def set_flag(k) = (data[:flags][k] = true)

    def client(key)
      data[:clients][key] ||= { favor: 0, shown: [], done: 0 }
    end

    # ---------------------------------------------------------------- 日历
    def ticks
      ($game_variables[157].to_i - 14) * 3000 + $game_variables[158].to_i
    end

    def day
      ticks * 360 / 3000
    end

    def season
      ($game_variables[158].to_i % 3000) / 750
    end

    def season_name
      SEASONS[season]
    end

    def pass_time(n)
      $game_variables[158] += n
    end

    # ---------------------------------------------------------------- 钓鱼

    def rod_effect(id, **fx)
      RODS[id] = fx
    end

    def rod
      a = $game_actors[1]
      RODS.keys.find { |id| a.armor_equiped?(id) }
    end

    # 物品栏说明页里的钓竿效果（web_gear.rb 的 help_pages 调用）
    def rod_lines(id)
      fx = RODS[id] or return []
      t = []
      t << "咬钩+#{fx[:bite]}%" if fx[:bite]
      t << '一次只过1个时辰' if fx[:fast]
      t << "稀罕鱼+#{fx[:rare]}" if fx[:rare]
      t << "“再等等”不易跑+#{fx[:keep]}%" if fx[:keep]
      t << "鱼的重量+#{fx[:size]}%" if fx[:size]
      t << "海钓咬钩+#{fx[:sea]}%（鱼塘−#{fx[:sea]}%）" if fx[:sea]
      t << "难得一见的鱼×#{fx[:legend]}" if fx[:legend]
      ["【钓竿】#{t.empty? ? '普通' : t.join('，')}"]
    end

    def rod_fx(key)
      (RODS[rod] || {})[key].to_i
    end

    def at_sea?
      @water == :sea
    end

    def skill
      data[:skill][:fishing].to_i
    end

    def skill_level
      SKILL_STEPS.count { |n| skill >= n }
    end

    def bite_chance(bait)
      sea = rod_fx(:sea) * (at_sea? ? 1 : -1)
      [45 + skill_level * 3 + (bait ? 10 : 0) + rod_fx(:bite) + sea, 90].min
    end

    def candidates(water)
      FISH.values.select { |f| f[:water] == water && f[:seasons].include?(season) }
    end

    # 抽一条鱼。bait 用了香饵；patient 浮子动了以后“再等等”（稀有的更多，但可能跑掉，由事件判定）
    def roll(water, bait: false, patient: false)
      pool = candidates(water)
      return nil if pool.empty?
      sea = rod_fx(:sea) * (water == :sea ? 1 : -1) / 2
      boost = [rod_fx(:rare) + sea + skill_level + (bait ? 6 : 0) + (patient ? 8 : 0), 0].max
      weights = pool.map do |f|
        w = RARITY[f[:rarity]]
        w += boost * f[:rarity] * (f[:rarity] == 3 ? 0.4 : 1.5)
        w *= [rod_fx(:legend), 1].max if f[:rarity] == 3
        w = w / 2.0 if f[:rarity] == 0 && patient
        [f, w]
      end
      r = rand * weights.sum { |_, w| w }
      weights.each { |f, w| return f if (r -= w) < 0 }
      weights[-1][0]
    end

    # 钓上来了：记进鱼谱，涨熟练度。返回 [鱼, 重量（两）]
    def land(f)
      lo, hi = f[:weight]
      wt = (lo + rand(hi - lo + 1)) * (100 + rod_fx(:size)) / 100
      rec = (data[:fish][f[:id]] ||= [0, 0])
      rec[0] += 1
      rec[1] = [rec[1], wt].max
      data[:skill][:fishing] += 1 + f[:rarity] * 2
      [f, wt]
    end

    def weight_text(liang)
      jin, l = liang.divmod(16)
      jin > 0 ? (l > 0 ? "#{jin}斤#{l}两" : "#{jin}斤") : "#{l}两"
    end

    # 事件里用：抽鱼并写好对话要用的变量（9 鱼的物品编号，0 为没抽到）和文字
    def cast(water, bait: false, patient: false)
      f = roll(water, bait: bait, patient: patient)
      $game_variables[9] = f ? f[:id] : 0
      @last = f
    end

    def landed_text
      f = @last or return ''
      _, wt = land(f)
      big = data[:fish][f[:id]][1] == wt && data[:fish][f[:id]][0] > 1 ? '（比以前钓到的都大！）' : ''
      @last_text = "钓到了一条#{f[:name]}，足有#{weight_text(wt)}！#{big}"
    end

    def caught?(id)
      (data[:fish][id] || [0])[0] > 0
    end

    def species_caught
      FISH.keys.count { |id| caught?(id) }
    end

    # ---------------------------------------------------------------- 订单（客栈收鱼）
    def order
      data[:order]
    end

    # 按钓到过的鱼出单；当季有的优先。数量和报价看稀有程度
    def new_order(client)
      known = FISH.values.select { |f| caught?(f[:id]) }
      return nil if known.empty?
      now = known.select { |f| f[:seasons].include?(season) }
      f = (now.empty? ? known : now).sample
      qty = [5, 3, 2, 1][f[:rarity]] + rand(2)
      pay = (f[:price] * qty * (1.5 + rand * 0.5)).to_i
      data[:order] = { client: client, item: f[:id], qty: qty, pay: pay, day: day }
    end

    def order_text
      o = order or return ''
      "收#{FISH[o[:item]][:name]}#{o[:qty]}条，付#{o[:pay]}两"
    end

    def order_ready?
      o = order
      o && $game_party.item_number(o[:item]) >= o[:qty]
    end

    def finish_order
      o = order or return
      $game_party.lose_item(o[:item], o[:qty])
      $game_party.gain_gold(o[:pay])
      c = client(o[:client])
      c[:done] += 1
      c[:favor] += 1
      data[:order] = nil
    end

    def cancel_order
      data[:order] = nil
    end
  end
end

#--------------------------------------------------------------------------
# 鱼谱画面：各种鱼的产地、季节、条数、最大一条；没钓到过的显示“？？？”
#--------------------------------------------------------------------------
class Scene_FishBook
  def main
    @window = Window_Base.new(0, 0, 640, 480)
    @window.contents = Bitmap.new(608, 448)
    refresh
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      break if Input.trigger?(Input::B) || Input.trigger?(Input::C)
    end
    $game_system.se_play($data_system.cancel_se)
    $scene = Scene_Map.new
    Graphics.freeze
    @window.dispose
  end

  def refresh
    c = @window.contents
    c.clear
    c.font.color.set(0, 0, 0)
    c.font.size = 22
    l = WebLife
    c.draw_text(0, 0, 608, 28, "鱼谱　渔技#{l.skill_level}级　已钓到#{l.species_caught}/#{l.data_size_fish}种　当前#{l.season_name}季", 1)
    c.font.size = 18
    l::FISH.values.sort_by { |f| [f[:water] == :pond ? 0 : 1, f[:rarity], f[:id]] }.each_with_index do |f, i|
      y = 36 + i * 26
      rec = l.data[:fish][f[:id]]
      if rec && rec[0] > 0
        where = f[:water] == :pond ? '南郊鱼塘' : '冰火岛渡口'
        seasons = f[:seasons].size == 4 ? '四季' : f[:seasons].map { |s| l::SEASONS[s] }.join
        c.draw_text(8, y, 120, 26, f[:name])
        c.draw_text(128, y, 120, 26, where)
        c.draw_text(248, y, 80, 26, seasons)
        c.draw_text(328, y, 100, 26, l::RARITY_NAME[f[:rarity]])
        c.draw_text(428, y, 80, 26, "#{rec[0]}条")
        c.draw_text(508, y, 100, 26, "最大#{l.weight_text(rec[1])}")
      else
        c.draw_text(8, y, 120, 26, '？？？')
        c.draw_text(128, y, 400, 26, f[:water] == :pond ? '（淡水）' : '（海里）')
      end
    end
    c.font.size = 16
    c.draw_text(0, 424, 608, 24, '按确定或取消返回', 1)
  end
end

module WebLife
  def self.data_size_fish = FISH.size
end
