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
#      :stock    鱼情 { 水域 => [0～100, 上次结算的日子] }：钓一条掉一截，过日子慢慢恢复
#      :flags    杂项开关（Symbol => true）
#    只用 Hash / Array / Integer / Symbol / String，存档导回 PC 原版也能正常读取（多出的实例变量会被忽略）。
#    地图事件的出现条件需要开关时，另用剧情开关（见 110 的编号登记）。
#==============================================================================
module WebLife
  VERSION = 1
  SEASONS = %w[春 夏 秋 冬]

  # ---- 水域
  WATERS = { pond: '南郊鱼塘', sea: '冰火岛渡口', lotus: '商家堡荷塘', stream: '西郊小溪', ice: '大雪山冰溪' }

  # ---- 鱼：物品编号 => { name:, water:, seasons:, rarity:, weight: [最小两, 最大两], price: }
  #   water   水域，见 WATERS
  #   rarity  0 常见 1 少见 2 稀有 3 难得一见
  FISH = {}
  RARITY = [60, 25, 10, 2]                       # 各档的基础权重
  RARITY_NAME = %w[常见 少见 稀有 难得一见]

  @clients = {}                                  # 熟客定义（称呼档位等），内容文件登记

  # 钓竿（防具，钓竿位）=> 效果：bite 咬钩率 +%，rare 稀罕鱼加成，keep “再等等”留住鱼的几率 +%，
  #   size 鱼的重量 +%，sea 海钓时的额外咬钩率与稀罕加成（负数表示在鱼塘反而差），fast 一次只过 1 个时辰，
  #   legend “难得一见”的鱼的权重倍数。内容文件用 WebLife.rod_effect 登记
  RODS = {}
  WEAPON_RODS = {}                               # 能当兵器的鱼竿（武器编号 => 效果），拿在手里也能钓鱼

  # 钓出来的不是鱼：[种类, 权重, 最低渔技]。种类见 junk_text
  JUNK = {
    pond:   [[:shoe, 30, 1], [:sword, 15, 1], [:page, 15, 2], [:bottle, 10, 2], [:purse, 20, 1], [:bandit, 10, 3]],
    sea:    [[:shoe, 20, 1], [:page, 10, 2], [:bottle, 20, 1], [:chest, 20, 2], [:bandit, 10, 3]],
    lotus:  [[:shoe, 20, 1], [:purse, 30, 1], [:page, 15, 2], [:bandit, 10, 3]],
    stream: [[:shoe, 25, 1], [:sword, 20, 1], [:page, 15, 2], [:purse, 15, 1]],
    ice:    [[:page, 20, 1], [:chest, 15, 2]],
  }
  JUNK_CHANCE = { pond: 12, sea: 15, lotus: 12, stream: 10, ice: 8 }   # 提竿钓上来东西时，不是鱼的几率（%）
  WATER_BANDIT = { pond: 160, lotus: 160, sea: 161 }                    # 钓上来的人：水贼 / 海盗

  # ---- 钓鱼时的小插曲：[种类, 权重, 只在这些水域（nil 为都有）, 只在这些季节（nil 为都有）]
  INTERLUDES = [
    [:rain,    10, nil, [0, 1, 2]], [:tangle, 10, nil, nil], [:chat, 10, nil, nil], [:cat, 8, [:pond, :lotus, :stream], nil],
    [:drift,    6, [:stream, :pond], nil], [:gulls, 10, [:sea], nil], [:crack, 12, [:ice], nil],
    [:lotus,   10, [:lotus], [1]],
  ]
  INTERLUDE_CHANCE = 20                          # 每一竿遇到小插曲的几率（%）
  BIRD_CHANCE = 6                                # 钓上来的鱼被水鸟叼走的几率（%）

  # 鱼情：钓上一条掉多少（按稀有程度），每过一天恢复多少。连着钓十来条就“钓怕了”，睡一觉（三个月）全恢复
  STOCK_COST = [8, 10, 14, 20]
  STOCK_JUNK = 5
  STOCK_DAILY = 4

  # 渔技称号（按渔技等级）
  TITLES = [nil, '渔童', '渔童', '渔夫', '渔夫', '老渔翁', '老渔翁', '钓叟', '钓叟', '钓圣', '钓圣']
  # 钓到鱼给的实战经验（按稀有程度）
  CATCH_EXP = [0, 10, 40, 150]
  # 钓鱼练功：拿着能当兵器的鱼竿钓到鱼时，太公钓法（武功 90）长修炼进度
  ART = 90

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

    # 正在用的鱼竿：拿在手里的兵器鱼竿优先，其次是钓竿位上的钓竿
    def rod_entry
      a = $game_actors[1]
      return WEAPON_RODS[a.weapon_id] if WEAPON_RODS.key?(a.weapon_id)
      id = RODS.keys.find { |i| a.armor_equiped?(i) }
      id && RODS[id]
    end

    def rod
      rod_entry ? true : nil
    end

    def weapon_rod?
      WEAPON_RODS.key?($game_actors[1].weapon_id)
    end

    def title
      TITLES[skill_level]
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
      (rod_entry || {})[key].to_i
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
      mood = (raining? ? 20 : 0) + (@gulls ? 25 : 0) + (@lotus_mood ? 10 : 0)
      base = [45 + skill_level * 3 + (bait ? 10 : 0) + rod_fx(:bite) + sea + mood, 95].min
      water = @water || :pond
      (base * (0.25 + 0.75 * stock(water) / 100.0)).to_i      # 鱼情差时咬钩少
    end

    # ---- 鱼情
    def stock(water)
      st = (data[:stock] ||= {})
      v, last = st[water] || [100, day]
      v = [v + (day - last) * STOCK_DAILY, 100].min
      st[water] = [v, day]
      v
    end

    def drain_stock(water, n)
      v = stock(water)
      data[:stock][water] = [[v - n, 0].max, day]
    end

    NO_BITE = { pond: '过了很久也没有鱼上钩，你一收钓竿，到树荫下歇着去了。', sea: '潮水涨了又退，一条鱼也没咬钩。',
                lotus: '荷叶下静悄悄的，浮子一动不动。', stream: '溪水哗哗地流，鱼钩上的饵早被冲没了。',
                ice: '冰窟窿里的水慢慢结了一层薄冰，一条鱼也没来。' }

    def no_bite_text
      w = @water || :pond
      return "#{water_name(w)}的鱼都被你钓怕了，半天没有动静。换个地方，或者过些日子再来吧。" if stock(w) < 30
      NO_BITE[w]
    end

    def candidates(water)
      FISH.values.select { |f| f[:water] == water && f[:seasons].include?(season) }
    end

    def water_name(water)
      WATERS[water]
    end

    # ---- 小插曲（下竿时抽，影响这一竿；下雨管一天）
    def raining?
      (@rain_until || -1) >= ticks
    end

    def roll_interlude(water)
      @interlude = nil
      return nil if rand(100) >= INTERLUDE_CHANCE
      pool = INTERLUDES.select { |_, _, ws, ss| (ws.nil? || ws.include?(water)) && (ss.nil? || ss.include?(season)) }
      pool = pool.reject { |k, *| k == :rain && raining? }
      r = rand(pool.sum { |_, w, *| w })
      pool.each do |k, w, *|
        next unless (r -= w) < 0
        @interlude = k
        @rain_until = ticks + 8 if k == :rain        # 下一天都算下雨
        @gulls = k == :gulls
        @lotus_mood = k == :lotus
        return k
      end
      nil
    end

    def interlude?
      !@interlude.nil?
    end

    def interlude
      @interlude
    end

    def interlude_cat?
      @interlude == :cat
    end

    # 小插曲的文字和效果（事件里 c.say 调用一次）
    def interlude_text
      case @interlude
      when :rain
        '天上飘起了小雨，水面泛起一圈圈涟漪——下雨天，鱼最爱咬钩。'
      when :tangle
        pass_time(2)
        '钓线缠在水草上，费了半天劲才解开，日头都偏西了。'
      when :chat
        if rand(2) == 0 && respond_to?(:bottle_text)
          t = bottle_text
          t.start_with?('纸条') ? "一个过路的樵夫在你旁边坐下歇脚，闲聊了几句：#{t.sub(/\A纸条上歪歪扭扭写着：/, '')}" : "一个过路的樵夫在你旁边坐下歇脚，看了会儿你钓鱼，又走了。"
        else
          "一个过路的老汉蹲下来看你钓鱼：“#{respond_to?(:jose_tip) ? jose_tip : '这季节的鱼可不好钓啊。'}”"
        end
      when :drift
        g = 50 + rand(150)
        $game_party.gain_gold(g)
        "上游漂下来一只木盆，你伸竿把它勾到岸边，盆底竟压着#{g}两碎银子。"
      when :gulls
        '一群海鸥在不远处的海面上盘旋俯冲——那下面准有鱼群！'
      when :crack
        a = $game_actors[1]
        lost = [a.maxhp / 10, a.hp - 1].min
        a.hp -= lost if lost > 0
        '脚下的冰面“咔嚓”一声裂开一道缝，你一个趔趄，半条腿浸进了冰水里，冻得直哆嗦。'
      when :lotus
        '一阵风吹过，满塘荷花轻轻摇曳，清香扑鼻。你心里一静，浮子也看得格外清楚。'
      when :cat
        '一只瘦巴巴的野猫蹲在你脚边，眼巴巴地盯着你的鱼篓。'
      else ''
      end
    end

    # 喂猫：给一条最便宜的鱼，道德 +1
    def feed_cat
      id = FISH.values.select { |f| $game_party.item_number(f[:id]) > 0 }.min_by { |f| f[:price] }&.dig(:id)
      return '你的鱼篓里空空的，野猫失望地走了。' unless id
      $game_party.lose_item(id, 1)
      WebMod.gain_morality(1)
      "你丢给它一条#{FISH[id][:name]}。野猫叼着鱼，冲你“喵”了一声，钻进草丛不见了。"
    end

    # 这一季这片水里没有鱼（冰溪只有冬天能钓）
    def off_season_text
      @water == :ice ? '溪水又急又冷，鱼都躲在深处。等冬天冰封了，凿个冰窟窿才好钓。' : '这个时节，这里好像钓不到什么鱼。'
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
      drain_stock(f[:water], STOCK_COST[f[:rarity]])
      WebMod.gain_exp(CATCH_EXP[f[:rarity]]) if CATCH_EXP[f[:rarity]] > 0
      practice(1 + f[:rarity])
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

    # 钓上来了却被水鸟叼走（只在 land_and_text 里判定一次）
    def bird_steal?
      @bird = rand(100) < BIRD_CHANCE
    end

    def landed_text
      f = @last or return ''
      _, wt = land(f)
      return "钓上来一条#{f[:name]}——一只水鸟俯冲下来，一口叼走了！你只来得及看清它足有#{weight_text(wt)}。" if @bird
      big = data[:fish][f[:id]][1] == wt && data[:fish][f[:id]][0] > 1 ? '（比以前钓到的都大！）' : ''
      exp = CATCH_EXP[f[:rarity]] > 0 ? "（实战经验+#{CATCH_EXP[f[:rarity]]}）" : ''
      @last_text = "钓到了一条#{f[:name]}，足有#{weight_text(wt)}！#{big}#{exp}#{practice_note}"
    end

    # ---- 钓鱼练功：规则与原版向师傅学武相同——每次加（读书识字÷10＋悟性＋加成）÷2 的修炼进度，
    #      满（等级＋1）² 升一级，升级前要过原版的经验上限检查（ckeck_exp_maxlv）。只是不花潜能
    def practice(times)
      @leveled = nil
      return unless weapon_rod? && $game_variables[ART].to_i > 0
      pv = WebSkill.point_var(ART)
      agi = ($game_variables[48] / 10 + $game_variables[13] + $game_variables[93]) / 2
      $game_variables[pv] += [agi, 1].max * times
      while $game_variables[pv] >= ($game_variables[ART] + 1)**2 + 1 && ckeck_exp_maxlv(ART)
        $game_variables[pv] -= ($game_variables[ART] + 1)**2 + 1
        $game_variables[ART] += 1
        @leveled = $game_variables[ART]
      end
    end

    def practice_note
      @leveled ? "一甩一收之间，你对太公钓法又有了新的领悟！（太公钓法升到#{@leveled}级）" : ''
    end

    # ---- 钓出来的不是鱼
    def junk_roll(water)
      return nil unless rand(100) < JUNK_CHANCE[water]
      pool = JUNK[water].select { |_, _, lv| skill_level >= lv }
      r = rand(pool.sum { |_, w, _| w })
      pool.each { |k, w, _| return k if (r -= w) < 0 }
      nil
    end

    # 事件里用：变量 9 = 3 钓上来东西（junk_text 发放），4 钓上来一个水贼 / 海盗（要打一架）
    def junk_text
      data[:skill][:fishing] += 1
      drain_stock(@water || :pond, STOCK_JUNK)
      case @junk
      when :shoe   then $game_party.gain_armor(39, 1); '钓上来一只湿漉漉的草鞋……也许还能穿？（得到草鞋）'
      when :sword  then $game_party.gain_weapon(20, 1); '钓线沉甸甸的——竟是一把锈迹斑斑的铁剑！（得到铁剑）'
      when :page   then $game_party.gain_item(26, 1); '钩上挂着一页泡得发软的纸，上面画着人形和经脉。（得到武学残页）'
      when :bottle then $game_party.gain_item(41, 1); '钓上来一只封着口的瓶子，里面卷着一张纸条。（得到漂流瓶）'
      when :purse
        g = 50 + rand(250); $game_party.gain_gold(g); "钓上来一个烂了一半的钱袋，里面还有#{g}两银子！"
      when :chest
        g = 300 + rand(700); $game_party.gain_gold(g); "钓上来一只长满藤壶的小木箱，撬开一看，是#{g}两银子！"
      else '……'
      end
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
    @page = 0
    @waters = WebLife::WATERS.keys
    @window = Window_Base.new(0, 0, 640, 480)
    @window.contents = Bitmap.new(608, 448)
    refresh
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      break if Input.trigger?(Input::B) || Input.trigger?(Input::C)
      if Input.trigger?(Input::RIGHT) || Input.trigger?(Input::LEFT)
        @page = (@page + (Input.trigger?(Input::RIGHT) ? 1 : -1)) % @waters.size
        $game_system.se_play($data_system.cursor_se)
        refresh
      end
    end
    $game_system.se_play($data_system.cancel_se)
    $scene = Scene_Map.new
    Graphics.freeze
    @window.dispose
  end

  # 一页一处水域：鱼名、季节、稀有程度、条数、最大一条；没钓到的显示“？？？”
  def refresh
    c = @window.contents
    c.clear
    c.font.color.set(0, 0, 0)
    l = WebLife
    water = @waters[@page]
    c.font.size = 22
    c.draw_text(0, 0, 608, 28, "鱼谱　#{l.title || '新手'}（渔技#{l.skill_level}级）　已钓到#{l.species_caught}/#{l.data_size_fish}种　当前#{l.season_name}季", 1)
    c.font.size = 20
    c.draw_text(0, 40, 608, 28, "← #{l.water_name(water)}（#{@page + 1}/#{@waters.size}）　鱼情#{l.stock(water)} →", 1)
    c.font.size = 18
    l::FISH.values.select { |f| f[:water] == water }.sort_by { |f| [f[:rarity], f[:id]] }.each_with_index do |f, i|
      y = 84 + i * 30
      rec = l.data[:fish][f[:id]]
      seasons = f[:seasons].size == 4 ? '四季' : f[:seasons].map { |s| l::SEASONS[s] }.join
      if rec && rec[0] > 0
        c.draw_text(24, y, 140, 28, f[:name])
        c.draw_text(164, y, 100, 28, seasons)
        c.draw_text(264, y, 120, 28, l::RARITY_NAME[f[:rarity]])
        c.draw_text(384, y, 80, 28, "#{rec[0]}条")
        c.draw_text(464, y, 140, 28, "最大#{l.weight_text(rec[1])}")
      else
        c.draw_text(24, y, 140, 28, '？？？')
        c.draw_text(164, y, 100, 28, seasons)
        c.draw_text(264, y, 120, 28, l::RARITY_NAME[f[:rarity]])
      end
    end
    c.font.size = 16
    c.draw_text(0, 424, 608, 24, '左右键翻页，确定或取消返回', 1)
  end
end

module WebLife
  def self.data_size_fish = FISH.size
end

#==============================================================================
# ■ 厨子：菜谱、做菜判定、吃饭增益（内容在 src/game/mods/130_厨子.rb）
#------------------------------------------------------------------------------
#  做菜：备齐食材，在灶台上选“火候”（文火 / 武火 / 先武后文）和“调味”（清淡 / 咸鲜 / 重口）。
#    两样都对 → 极品（出两份），对一样 → 好，都不对 → 普通；厨艺越高，越有机会往上提一档。
#    每道菜的讲究写在菜谱提示里（“鳜鱼肉嫩，火大了就老”），要琢磨，不是背答案。
#  吃菜：填饱肚子，并在接下来的几场战斗里带上这道菜的增益（接装备特效引擎，同一时间只算最后吃的一道）。
#  存档数据：@web_life[:cook] = { recipes: [菜的物品编号], meal: [菜, 剩几场] }，熟练度在 [:skill][:cooking]
#==============================================================================
module WebLife
  HEATS  = %w[文火 武火 先武后文]
  TASTES = %w[清淡 咸鲜 重口]
  RECIPES = {}
  COOK_TITLES = [nil, '学徒', '学徒', '帮厨', '帮厨', '掌勺', '掌勺', '大厨', '大厨', '御厨', '御厨']
  COOK_STEPS = [0, 8, 20, 36, 56, 80, 110, 145, 185, 230]
  QUALITY = %w[普通 好 极品]

  class << self
    # 登记一道菜：id 是做出来的菜（物品）；needs { 食材物品编号 => 数量 }；heat / taste 是 HEATS / TASTES 的下标；
    # fx 是吃了以后的增益（装备特效写法），battles 管几场战斗；fill 填多少肚子
    def recipe(id, name:, needs:, heat:, taste:, hint:, fx:, battles: 2, fill: 200, spicy: false)
      RECIPES[id] = { id: id, name: name, needs: needs, heat: heat, taste: taste, hint: hint,
                      fx: fx.map { |t, o| (o || {}).merge(type: t) }, battles: battles, fill: fill, spicy: spicy }
    end

    def cook_data
      data[:cook] ||= { recipes: [], meal: nil }
    end

    def known?(id) = cook_data[:recipes].include?(id)

    # 学会菜谱，返回新学会的菜名（都会了返回空串）
    def learn(*ids)
      new = ids.reject { |id| known?(id) }
      cook_data[:recipes].concat(new)
      new.map { |id| RECIPES[id][:name] }.join('、')
    end

    def cook_skill = data[:skill][:cooking].to_i
    def cook_level = COOK_STEPS.count { |n| cook_skill >= n }
    def cook_title = COOK_TITLES[cook_level]

    def can_cook?(id)
      RECIPES[id][:needs].all? { |item, n| $game_party.item_number(item) >= n }
    end

    def needs_text(id)
      RECIPES[id][:needs].map { |item, n| "#{$data_items[item].name}×#{n}（有#{$game_party.item_number(item)}）" }.join('、')
    end

    # 做一道菜：返回 [品质 0～2, 份数, 说明]
    # （不叫 cook：110 里 WebLife.cook 是客栈厨师这位熟客的数据）
    def cook_dish(id, heat, taste)
      r = RECIPES[id]
      r[:needs].each { |item, n| $game_party.lose_item(item, n) }
      q = (heat == r[:heat] ? 1 : 0) + (taste == r[:taste] ? 1 : 0)
      q += 1 if q < 2 && rand(100) < cook_level * 4             # 厨艺高，偶尔有神来之笔
      portions = q == 2 ? 2 : 1
      $game_party.gain_item(id, portions)
      data[:skill][:cooking] = cook_skill + 1 + q
      pass_time(2)
      tips = []
      tips << "火候#{heat == r[:heat] ? '正好' : '不太对'}" 
      tips << "味道#{taste == r[:taste] ? '正好' : '不太对'}"
      [q, portions, "#{r[:name]}做好了！成色：#{QUALITY[q]}（#{tips.join('，')}），得到#{portions}份。"]
    end

    # ---- 吃饭增益：最后吃的一道菜，管几场战斗
    def eat_dish(id)
      r = RECIPES[id]
      $game_variables[15] += r[:fill] if $game_variables[15] < $game_variables[16]
      cook_data[:meal] = [id, r[:battles]]
      "#{r[:name]}下肚，浑身舒坦。（接下来#{r[:battles]}场战斗：#{r[:fx].map { |e| WebGear.describe(e) }.join('，')}）"
    end

    def meal_effects
      m = cook_data[:meal] rescue nil
      return [] unless m && m[1].to_i > 0 && RECIPES[m[0]]
      RECIPES[m[0]][:fx]
    end

    def meal_battle_done
      m = cook_data[:meal]
      return unless m
      m[1] -= 1
      cook_data[:meal] = nil if m[1] <= 0
    end
  end
end

# 吃饭增益接到装备特效：战斗中当作多穿了一件带这些特效的装备
module WebGear
  class << self
    alias __life_active active
    def active
      list = __life_active
      meal = WebLife.meal_effects rescue []
      meal.empty? ? list : list + meal.select { |e| met?(e[:when]) }
    end
  end
end

class Scene_Battle
  alias __life_battle_end battle_end
  def battle_end(result)
    WebLife.meal_battle_done rescue nil
    __life_battle_end(result)
  end
end

#--------------------------------------------------------------------------
# 做菜画面：左边菜谱（缺料的变灰），上方显示食材与讲究；选菜后依次选火候、调味
#--------------------------------------------------------------------------
class Scene_Cook
  def main
    @help = Window_Help.new
    @ids = WebLife.cook_data[:recipes].sort
    @list = Window_Command.new(240, @ids.empty? ? ['（还不会做菜）'] : @ids.map { |id| WebLife::RECIPES[id][:name] })
    @list.y = 64
    @list.height = 416                              # 菜少时也占满一列，不留黑底
    @ids.each_with_index { |id, i| @list.disable_item(i) unless WebLife.can_cook?(id) }
    @info = Window_Base.new(240, 64, 400, 416)
    @info.contents = Bitmap.new(368, 384)
    @heat = Window_Command.new(160, WebLife::HEATS)
    @taste = Window_Command.new(160, WebLife::TASTES)
    [@heat, @taste].each { |w| w.x = 320; w.y = 240; w.visible = w.active = false; w.z = 200 }
    @step = :list
    refresh_info
    Graphics.transition
    until $scene != self
      Graphics.update
      Input.update
      update
    end
    Graphics.freeze
    [@help, @list, @info, @heat, @taste].each(&:dispose)
  end

  def current
    @ids[@list.index]
  end

  def refresh_info
    c = @info.contents
    c.clear
    c.font.color.set(0, 0, 0)
    c.font.size = 20
    l = WebLife
    c.draw_text(0, 0, 368, 28, "灶台　厨艺：#{l.cook_title || '新手'}（#{l.cook_level}级）")
    meal = l.cook_data[:meal]
    c.font.size = 16
    c.draw_text(0, 30, 368, 22, meal ? "正在管用：#{l::RECIPES[meal[0]][:name]}（还剩#{meal[1]}场）" : '（还没吃过有增益的菜）')
    id = current or return @help.set_text('先去跟厨师学几道菜吧。')
    r = l::RECIPES[id]
    c.font.size = 18
    y = 64
    wrap = lambda do |text|
      text.scan(/.{1,19}/).each { |line| c.draw_text(0, y, 368, 24, line); y += 24 }
    end
    wrap.call("食材：#{l.needs_text(id)}")
    y += 6
    wrap.call("讲究：#{r[:hint]}")
    y += 6
    wrap.call("吃了：#{r[:fx].map { |e| WebGear.describe(e) }.join('，')}（#{r[:battles]}场战斗）")
    @help.set_text(l.can_cook?(id) ? "#{r[:name]}：按确定开始做" : "#{r[:name]}：食材不够")
  end

  def update
    case @step
    when :list
      @list.update
      refresh_info if @last_index != @list.index && (@last_index = @list.index)
      if Input.trigger?(Input::B)
        $game_system.se_play($data_system.cancel_se)
        $scene = Scene_Map.new
      elsif Input.trigger?(Input::C)
        if current && WebLife.can_cook?(current)
          $game_system.se_play($data_system.decision_se)
          @step = :heat
          @list.active = false
          @heat.visible = @heat.active = true
          @heat.index = 0
          @help.set_text('火候：文火、武火，还是先武后文？')
        else
          $game_system.se_play($data_system.buzzer_se)
        end
      end
    when :heat
      @heat.update
      if Input.trigger?(Input::B)
        back_to_list
      elsif Input.trigger?(Input::C)
        $game_system.se_play($data_system.decision_se)
        @step = :taste
        @heat.active = false
        @taste.visible = @taste.active = true
        @taste.index = 0
        @help.set_text('调味：清淡、咸鲜，还是重口？')
      end
    when :taste
      @taste.update
      if Input.trigger?(Input::B)
        @taste.visible = @taste.active = false
        @heat.active = true
        @step = :heat
      elsif Input.trigger?(Input::C)
        q, _, text = WebLife.cook_dish(current, @heat.index, @taste.index)
        $game_system.se_play(q == 2 ? $data_system.shop_se : $data_system.decision_se)
        back_to_list
        @help.set_text(text)
        @ids.each_with_index { |id, i| WebLife.can_cook?(id) ? @list.able_item(i) : @list.disable_item(i) }
        refresh_info_keep_help
      end
    end
  end

  def refresh_info_keep_help
    t = @help.instance_variable_get(:@text)
    refresh_info
    @help.set_text(t)
  end

  def back_to_list
    @heat.visible = @heat.active = false
    @taste.visible = @taste.active = false
    @list.active = true
    @step = :list
    refresh_info
  end
end
