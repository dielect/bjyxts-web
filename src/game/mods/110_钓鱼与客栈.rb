#==============================================================================
# ■ 生活试点：钓鱼 → 熟客荷西 → 客栈收鱼订单 → 客栈菜牌（设计见 docs/职业生活与武林互动设计.md）
#------------------------------------------------------------------------------
#  钓点：南郊鱼塘（淡水，原版的两个钓点改写）、冰火岛渡口（海，岸边栏杆旁两处，挂着钓线的地方）。
#    要装备钓竿；带着鱼篓才留得住鱼（原版规则）。每钓一次过去 2 个时辰（时间 +2），气血 −10。
#    浮子一沉可以“提竿”或“再等等”：再等等更容易上大鱼、稀罕鱼，也可能跑掉。
#    鱼按季节、水域、稀有程度出现（鱼谱里记着），渔技越高、用香饵、换好钓竿，稀罕鱼越多。
#  熟客荷西（杂货店）：给他看没见过的鱼，交情渐深，称呼从“客官”变成“小兄弟”“渔友”“钓神”；
#    交情 2：介绍客栈厨师收鱼；交情 5：送香饵；交情 8：送斑竹钓竿。原有的“三十条鲤鱼换女儿红”照旧。
#  客栈厨师：经荷西介绍后接收鱼订单（主动接、没有期限，可以退掉）；交完 3 单，墙上挂出菜牌。
#    原有的“猪肉换祖传宝刀”照旧。
#
#  编号：物品 28～38 鱼、39 香饵、40 鱼谱；防具 107 斑竹钓竿；公共事件 28 看鱼谱
#        开关 150 客栈挂出菜牌；其余数据在 $game_system 的 @web_life（见 src/game/web_life.rb）
#==============================================================================

#--------------------------------------------------------------------------
# 鱼与渔具
#--------------------------------------------------------------------------
FISH_ITEM = { like: 17, common_event_id: 0, occasion: 3 }       # 以鲤鱼为模板；普通的新鱼不能直接吃（鲤鱼的公共事件写死扣鲤鱼）
[
  [28, '鲫鱼',   :pond, [0, 1, 2, 3], 0, [3, 10],  20,  '一条巴掌大的鲫鱼，熬汤最鲜'],
  [29, '草鱼',   :pond, [1, 2],       1, [16, 64], 60,  '青灰色的草鱼，个头不小'],
  [30, '鲶鱼',   :pond, [1],          1, [16, 80], 70,  '长着两撇胡子的鲶鱼，夏天才肯咬钩'],
  [31, '银鱼',   :pond, [3],          1, [1, 3],   50,  '通体透亮的小银鱼，冬天的稀罕物'],
  [32, '鳜鱼',   :pond, [0, 2],       2, [10, 40], 150, '桃花流水鳜鱼肥，肉嫩刺少'],
  [33, '金鲤',   :pond, [0, 1, 2, 3], 3, [24, 96], 800, '一条金灿灿的鲤鱼，传说能跃龙门'],
  [34, '黄鱼',   :sea,  [0, 1],       0, [8, 24],  40,  '金黄色的海鱼，春夏成群'],
  [35, '带鱼',   :sea,  [2, 3],       0, [10, 30], 40,  '银白细长的带鱼，像一条腰带'],
  [36, '墨鱼',   :sea,  [1, 2],       1, [8, 32],  70,  '一碰就喷墨的墨鱼'],
  [37, '石斑鱼', :sea,  [2],          2, [24, 96], 200, '浑身斑点的石斑鱼，秋天藏在礁石边'],
  [38, '红鲷',   :sea,  [3, 0],       2, [16, 48], 180, '通红的鲷鱼，冬春时节才有'],
].each do |id, name, water, seasons, rarity, weight, price, text|
  # 稀罕鱼可以吃（公共事件 30～33 在 120_渔隐.rb）：鳜鱼、石斑鱼、红鲷补气血，金鲤长内力
  eat = { 32 => 30, 37 => 31, 38 => 32, 33 => 33 }[id]
  attrs = eat ? FISH_ITEM.merge(common_event_id: eat, occasion: 2, consumable: true) : FISH_ITEM
  WebMod.item id, **attrs, name: name, price: price, description: text
  WebLife.fish id, name: name, water: water, seasons: seasons, rarity: rarity, weight: weight, price: price
end
WebLife.fish 17, name: '鲤鱼', water: :pond, rarity: 0, weight: [8, 40], price: 30   # 原版的鲤鱼（物品不变）

WebMod.item 39, like: 17, common_event_id: 0, occasion: 3, name: '香饵', price: 15,
            description: '荷西秘制的香饵，挂在钩上，稀罕的鱼也忍不住'
WebMod.item 40, like: 14, common_event_id: 28, consumable: false, name: '鱼谱', price: 0,
            description: '荷西送的一本旧册子，记着钓到过的鱼'
WebMod.common_event 28, '使用-鱼谱' do |c|
  c.script '$scene = Scene_FishBook.new'
end
#--------------------------------------------------------------------------
# 钓竿（防具，钓竿位，以原版钓竿为模板）
#--------------------------------------------------------------------------
[
  [107, '斑竹钓竿', 0,    '荷西珍藏的斑竹钓竿，竿梢极韧。', { rare: 6, keep: 10 }],
  [108, '柳木钓竿', 120,  '柳木削成的钓竿，轻便便宜。',                     { bite: 8 }],
  [109, '青竹轻竿', 800,  '细青竹做的轻竿，一甩就出去。',  { fast: 1, bite: 5 }],
  [110, '海竿',     2000, '粗竿配铜轮，专钓海里的大鱼。',      { sea: 10, rare: 2 }],
  [111, '乌金钓竿', 0,    '乌金镶头的钓竿，客栈厨师的谢礼。',    { size: 30, rare: 3 }],
  [112, '龙须钓竿', 0,    '传说用龙须做线的钓竿，荷西的镇店之宝。', { legend: 3, rare: 4 }],
].each do |id, name, price, text, fx|
  # kind 要写明 6：原版按编号把 31 号算作钓竿（012 Data_String 重写了 Armor#kind），数据里存的是 0
  WebMod.armor id, like: 31, kind: 6, name: name, price: price, description: text
  WebLife.rod_effect id, **fx
end
WebLife.rod_effect 31                                  # 原版钓竿：没有加成

#--------------------------------------------------------------------------
# 钓鱼的过程（两处水域共用）
#--------------------------------------------------------------------------
module WebLife
  class << self
    # 下竿：用不用香饵，咬不咬钩（变量 9：1 咬钩 0 没咬）
    def start_cast(water, bait)
      @water = water
      @bait = bait && $game_party.item_number(39) > 0
      $game_party.lose_item(39, 1) if @bait
      $game_variables[9] = rand(100) < bite_chance(@bait) ? 1 : 0
    end

    # 提竿或再等等（变量 9：2 钓上来鱼 3 钓上来别的东西 4 钓上来一个水贼 / 海盗 0 跑了）
    def hook(patient)
      keep = patient ? 45 + skill_level * 3 + rod_fx(:keep) : 85 + skill_level
      if rand(100) < keep
        @junk = patient ? nil : junk_roll(@water)        # 耐心等来的一定是鱼
        if @junk
          $game_variables[9] = @junk == :bandit ? 4 : 3
          return
        end
        cast(@water, bait: @bait, patient: patient)
        $game_variables[9] = @last ? 2 : 0
      else
        @last = nil
        $game_variables[9] = 0
      end
    end

    def land_and_text
      f = @last or return '……'
      text = landed_text
      $game_party.gain_item(f[:id], 1)
      text
    end

    def escape_text
      ['鱼线一松，鱼跑了。', '一个大家伙挣断了鱼线，跑了！', '钩子空空的，饵也被吃光了。'].sample
    end
  end
end

fishing = lambda do |c, water|
  c.if_script('WebLife.rod') do
    c.if_script('$game_actors[1].hp < 34') do
      c.text '现在日头这么毒，以你的体质，恐怕没钓到鱼就已经……'
    end.else do
      c.if_has(:item, 39) do
        c.text '用什么饵？'
        c.choices(%w[香饵 蚯蚓]) { |i| c.script "WebLife.start_cast(#{water.inspect}, #{i == 0})" }
      end.else do
        c.script "WebLife.start_cast(#{water.inspect}, false)"
      end
      c.text water == :pond ? '你甩出钓线，往塘边一蹲，盯着浮子。' : '你把钓线甩进海里，海浪一下一下地拍着礁石。'
      c.script "a = $game_actors[1]\na.hp -= 10 if a.hp > 10\nWebLife.pass_time(WebLife.rod_fx(:fast) > 0 ? 1 : 2)"
      c.if_variable(9, 1) do
        c.text '浮子猛地一沉！'
        c.choices(%w[提竿 再等等]) do |i|
          c.script "WebLife.hook(#{i == 1})"
          c.if_variable(9, 2) do
            c.if_has(:item, 18) do
              c.say 'WebLife.land_and_text'
            end.else do
              c.text '鱼拉上来了，你却猛然想起：坏了，没带鱼篓。一分神，鱼滑回了水里。'
            end
          end.else do
            c.if_variable(9, 3) do
              c.say 'WebLife.junk_text'
            end.else do
              c.if_variable(9, 4) do                     # 钓上来一个人（见 120_渔隐.rb）
                if water == :pond
                  c.text '钓线猛地一沉，水里“哗啦”冒出一个人来——是个憋着气躲在塘里的水贼！'
                  c.fight(160, loot: [[:item, 26, 1, 50]],
                    win: -> { c.text '水贼扔下偷来的钱袋，扑通一声跳回水里逃了。'; c.gold(300) },
                    lose: -> { c.script '$game_party.lose_gold($game_party.gold/4)'; c.text '水贼抢了你的钱袋，钻进水里不见了。' })
                else
                  c.text '海里钩上来的不是鱼，是一条小船——船上跳下几个海盗！'
                  c.fight(161, loot: [[:item, 41, 1, 60]],
                    win: -> { c.text '海盗们跳回船上，摇着橹逃走了，船尾扔下一包银子。'; c.gold(600) },
                    lose: -> { c.script '$game_party.lose_gold($game_party.gold/3)'; c.text '海盗们抢走了你的银子，扬帆而去。' })
                end
              end.else do
                c.say 'WebLife.escape_text'
              end
            end
          end
        end
      end.else do
        c.say 'WebLife.no_bite_text'
      end
    end
  end.else do
    c.text water == :pond ? '你看着池塘里的鱼，摸了摸肚皮：要是现在有个钓竿该多好啊！' : '海里的鱼一群一群的。要是有根钓竿就好了。'
  end
end

WebMod.edit 13 do |m|                               # 南郊鱼塘：原版的两个钓点
  m.rewrite(8) { |c| fishing.call(c, :pond) }
  m.rewrite(9) { |c| fishing.call(c, :pond) }
end

WebMod.edit 37 do |m|                               # 冰火岛渡口：岸边栏杆上挂着钓线的两处，站在下面按确定
  m.event 5, 10, name: '钓位', tile: 712 do |c|
    fishing.call(c, :sea)
  end
  m.event 14, 10, name: '钓位', tile: 712 do |c|
    fishing.call(c, :sea)
  end
end

#--------------------------------------------------------------------------
# 熟客：荷西
#--------------------------------------------------------------------------
module WebLife
  JOSE_TIERS = [[0, '客官'], [2, :young], [5, '渔友'], [8, '钓神']]

  class << self
    def jose = client(:jose)

    def jose_tier
      JOSE_TIERS.count { |n, _| jose[:favor] >= n } - 1
    end

    def jose_title
      t = JOSE_TIERS[jose_tier][1]
      t == :young ? ($gender == '女' ? '小姑娘' : '小兄弟') : t
    end

    def jose_greeting
      case jose_tier
      when 0 then '你也喜欢钓鱼吗？南郊有个鱼塘，冰火岛渡口还能钓海鱼呢！'
      when 1 then "#{jose_title}来啦！最近又钓着什么了？"
      when 2 then "哟，#{jose_title}！快坐，正想跟你聊聊鱼呢。"
      else "#{jose_title}大驾光临！今儿个想去哪儿下竿？"
      end
    end

    # 当季的提示：说一种这个季节能钓到、你还没钓到过的鱼
    def jose_tip
      todo = FISH.values.select { |f| f[:seasons].include?(season) && f[:seasons].size < 4 && !caught?(f[:id]) }
      return "这#{season_name}天啊，鱼塘里鲫鱼鲤鱼最多。想钓稀罕的，就得有耐心，浮子沉了别急着提竿。" if todo.empty?
      f = todo.sample
      where = f[:water] == :pond ? '南郊鱼塘' : '冰火岛渡口'
      "#{season_name}天正是#{f[:name]}的时候，去#{where}碰碰运气吧！"
    end

    # 给荷西看鱼：每种他没见过的鱼加一点交情，付一点“看鱼钱”
    def show_jose
      new = FISH.keys.select { |id| $game_party.item_number(id) > 0 && !jose[:shown].include?(id) }
      if new.empty?
        @jose_gifts = []
        return '这些我都见过啦。钓到没见过的，记得拿来给我瞧瞧！'
      end
      before = jose_tier
      new.each { |id| jose[:shown] << id; jose[:favor] += 1 }
      pay = new.sum { |id| FISH[id][:price] / 2 }
      $game_party.gain_gold(pay)
      names = new.map { |id| FISH[id][:name] }.join('、')
      @jose_gifts = ((before + 1)..jose_tier).to_a     # 一次跨过几档，礼物依次都给
      "#{names}！我还是头一回见！这#{pay}两银子你拿着，算我看鱼的钱。"
    end

    def jose_gift?
      !(@jose_gifts || []).empty?
    end

    # 事件里发放的钓竿（107 斑竹，112 龙须），发完清掉
    def jose_rod
      r = @jose_rod
      @jose_rod = nil
      r
    end

    # 十二种鱼都给荷西看过：送龙须钓竿（只一次）
    def dragon_rod_due?
      jose[:shown].size >= FISH.size && !flag?(:dragon_rod)
    end

    # 交情升档时的礼物（每次取一档）
    def jose_gift_text
      tier = (@jose_gifts || []).shift
      case tier
      when 1
        set_flag(:cook_intro)
        "#{jose_title}，客栈的胖厨子一直想收新鲜鱼，我跟他提过你了，你去找他吧。"
      when 2
        $game_party.gain_item(39, 10)
        "#{jose_title}，这是我秘制的香饵，挂在钩上，稀罕的鱼也忍不住。往后在我这儿也买得到。（得到香饵十个）"
      when 3
        @jose_rod = 107
        "#{jose_title}！这根斑竹钓竿跟了我二十年，今天送给你，往后的鱼就靠你钓啦！（得到斑竹钓竿）"
      else ''
      end
    end
  end
end

WebMod.edit 16 do |m|
  m.goods '荷西', [[:armor, 108], [:armor, 109], [:armor, 110], [:item, 39]]
  m.talk '荷西', override: true do |c|
    c.say 'WebLife.jose_greeting'
    c.choices(%w[聊聊钓鱼 给你看看鱼 换女儿红 告辞]) do |i|
      case i
      when 0
        c.if_has(:item, 40, 1) do
          c.say 'WebLife.jose_tip'
        end.else do
          c.text '荷西从柜台底下翻出一本旧册子：“拿着，钓到什么就记上，看看一年四季能钓多少种！”'
          c.gain(:item, 40)
          c.text '得到了鱼谱！（在物品栏里使用）'
          c.say 'WebLife.jose_tip'
        end
      when 1
        c.say 'WebLife.show_jose'
        3.times do                                    # 一次最多跨三档
          c.if_script('WebLife.jose_gift?') do
            c.say 'WebLife.jose_gift_text'
            c.if_script('WebLife.jose_rod == 107') { c.gain(:armor, 107) }
          end
        end
        c.if_script('WebLife.dragon_rod_due?') do
          c.script 'WebLife.set_flag(:dragon_rod)'
          c.text '荷西捧着鱼谱翻了又翻，忽然起身，从里屋取出一根细长的钓竿。'
          c.text '“十二种，一种不落！这根龙须钓竿是我的镇店之宝，今天送给你——你才配得上它。”'
          c.gain(:armor, 112)
          c.text '得到了龙须钓竿！'
        end
      when 2                                          # 原版：三十条鲤鱼换一瓶女儿红
        c.if_has(:item, 17, 30) do
          c.text '三十条鲤鱼！好，好！我前天钓上来一瓶女儿红，留着也是无用，就送给你了！'
          c.lose(:item, 17, 30)
          c.gain(:item, 16)
        end.else do
          c.text '凑够三十条鲤鱼，我拿一瓶女儿红跟你换。'
        end
      end
    end
  end
end

#--------------------------------------------------------------------------
# 客栈厨师：收鱼订单；交完三单挂出菜牌
#--------------------------------------------------------------------------
module WebLife
  class << self
    def cook = client(:cook)

    def cook_offer_text
      new_order(:cook)
      o = order or return '……'
      first = cook[:done] == 0 ? '荷西说你钓鱼是把好手。' : '又得麻烦你了。'
      "#{first}能不能给我送#{FISH[o[:item]][:name]}#{o[:qty]}条？我付你#{o[:pay]}两。"
    end

    def cook_wait_text
      o = order
      have = $game_party.item_number(o[:item])
      "#{FISH[o[:item]][:name]}#{o[:qty]}条，你身上有#{have}条。不急，慢慢钓。"
    end

    def cook_done_text
      o = order
      text = "#{FISH[o[:item]][:name]}#{o[:qty]}条，一条不少！这是#{o[:pay]}两，你点点。"
      (cook[:served] ||= []) << o[:item] unless (cook[:served] ||= []).include?(o[:item])
      finish_order
      text
    end

    def menu_ready?
      cook[:done] >= 3
    end

    def menu_text
      names = (cook[:served] || []).map { |id| FISH[id][:name] }
      dishes = names.first(4).zip(%w[清蒸 红烧 糖醋 干煎]).map { |n, way| "#{way}#{n}" }
      who = $game_actors[1].name.to_s.empty? ? '你' : $game_actors[1].name
      "墙上挂着新写的菜牌：#{dishes.join('、')}……下面一行小字：鲜鱼由#{who}供应。"
    end
  end
end

WebMod.edit 20 do |m|
  m.talk '厨师', override: true do |c|
    c.if_has(:item, 5) do                           # 原版：猪肉换祖传宝刀
      c.text '真奇怪，我条案上的肉不见了，真是急人！我用这把祖传的宝刀换你身上的猪肉，你换吗？'
      c.choices(%w[换 不换]) do |i|
        if i == 0
          c.gain(:weapon, 1)
          c.lose(:item, 5)
          c.text '真是谢谢你啊，我的祖传宝刀还好用吗？'
        end
      end
    end.else do
      c.if_script('!WebLife.flag?(:cook_intro)') do
        c.text '真奇怪，我条案上的肉不见了，真是急人！'
      end.else do
        c.if_script('WebLife.order.nil?') do
          c.say 'WebLife.cook_offer_text'
          c.choices(%w[接下 下次吧]) do |i|
            c.script 'WebLife.cancel_order' if i == 1
            c.text(i == 0 ? '“好嘞！钓到了就送过来，不着急。”' : '“行，你什么时候得空再来。”')
          end
        end.else do
          c.if_script('WebLife.order_ready?') do
            c.say 'WebLife.cook_done_text'
            c.if_script('WebLife.menu_ready? && !$game_switches[150]') do
              c.switch(150)
              c.text '厨师搓着手：“客人们都夸鱼新鲜！我把你的鱼写上菜牌了，你瞧，就挂在那边墙上。”'
            end
            c.if_script('WebLife.cook[:done] >= 5 && !WebLife.flag?(:black_rod)') do
              c.script 'WebLife.set_flag(:black_rod)'
              c.text '“五单了！老哥我没什么好送的，这根乌金钓竿是早年一个客人押在店里的，归你了。”'
              c.gain(:armor, 111)
              c.text '得到了乌金钓竿！'
            end
          end.else do
            c.say 'WebLife.cook_wait_text'
            c.choices(%w[这就去钓 这单不做了]) do |i|
              if i == 1
                c.script 'WebLife.cancel_order'
                c.text '“没事，下回再说。”'
              end
            end
          end
        end
      end
    end
  end

  m.event 10, 5, name: '菜牌', tile: 595, switch: 150 do |c|
    c.say 'WebLife.menu_text'
  end
end
