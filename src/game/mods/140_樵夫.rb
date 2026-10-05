#==============================================================================
# ■ 樵夫路线（第一批）：砍柴、山货、樵技、攀山步、斧头与樵夫套（设计见 docs/职业生活与武林互动设计.md）
#------------------------------------------------------------------------------
#  入行：在平安镇西老婆婆家劈柴（原版的活）满三次，她送你一把柴刀，说起武当山脚唱山歌的老樵夫“歌樵子”。
#  砍柴：拿着斧头（柴刀、开山斧……），站在树前按确定。四片林子：武当山脚的柳树、山间盆地的松林、
#        玉女峰的林子、大雪山寨的枯树雪松。眼前是什么树，按季节、稀有程度抽；怎么下斧（顺纹劈 / 斜着砍 / 拉锯）
#        要看提示判断，下对了多得一根。顺手还能采到山货：草药、山菌、野蜂蜜、鸟蛋、山参、雪莲。
#        林情：一片林子砍多了就秃了，过些日子才长回来（同鱼情）。小插曲：山豹、蜂窝、采药人、起雾、山歌。
#  樵技称号：樵童、樵夫、老樵、山客、樵隐。
#  攀山步（轻功 71，基础基本轻功）：歌樵子在樵技 5 级后传授，并送开山斧。拿着斧头砍柴时长修炼进度（同钓鱼练功）。
#        绝招“开山一斧”（60 级，两斧重劈，可能把人劈懵）、“伐木连斧”（100 级，四连斧），都要手里拿着斧头。
#  联动：灶台做菜时，身上有松木、桃木、雪松木会自动添一把好柴，更容易出极品；歌樵子教两道山珍菜；客栈订单也收木柴。
#  樵夫套：草鞋、麻衣、草帽、背篓、任一斧头。2 件回春；4 件攀山步 +20、两个绝招省力；5 件采山货多一份。
#
#  编号：武功 71 攀山步（修炼进度变量 131）；绝招 32 开山一斧、33 伐木连斧；武器 76 柴刀、77 开山斧；
#        防具 113 麻衣、114 背篓、115 草帽；物品 65～73 木材、74～79 山货、80～81 山珍菜；
#        公共事件 49～50 吃山珍菜、51 吃山参、52 吃雪莲；敌人 162 山豹
#==============================================================================

#--------------------------------------------------------------------------
# 林子与木材、山货
#--------------------------------------------------------------------------
module WebLife
  FORESTS = { wudang: '武当山脚', basin: '山间盆地', yunv: '玉女峰', snow: '大雪山寨' }
  WOODS = {}
  CUT = %w[顺纹劈 斜着砍 拉锯]
  WOOD_TITLES = [nil, '樵童', '樵童', '樵夫', '樵夫', '老樵', '老樵', '山客', '山客', '樵隐', '樵隐']
  WOOD_STOCK_COST = [6, 8, 12, 18]
  AXES = { 76 => { more: 0 }, 77 => { more: 2 } }       # 斧头 => 稀罕木材加成（第二批再加宣花大斧、铁木神斧）
  ART_WOOD = 71
  # 山货：[物品, 林子（nil 都有）, 季节（nil 都有）, 几率 %]
  GATHER = [
    [74, nil, nil, 18], [75, [:wudang, :basin], [1, 2], 14], [76, [:yunv], [0, 1], 10],
    [77, [:wudang, :yunv], [0], 10], [78, [:basin], nil, 3], [79, [:snow], nil, 4],
  ]

  # 同一种木材可以长在几片林子里：每片林子登记一条，键是 [物品, 林子]
  def self.wood(item, name:, forest:, seasons: [0, 1, 2, 3], rarity: 0, cut:, hint:)
    WOODS[[item, forest]] = { item: item, name: name, forest: forest, seasons: seasons, rarity: rarity, cut: cut, hint: hint }
  end
end

[
  [65, '杂木柴', [:wudang, :yunv], [0, 1, 2, 3], 0, 1, 10,   '什么树都有一点，斜着砍几斧就断', '一捆杂木柴，烧火做饭都行'],
  [66, '柳木',   [:wudang],        [0, 1, 2, 3], 0, 0, 20,   '柳木软，顺着纹路一劈就开', '柔软的柳木，好劈好烧'],
  [67, '松木',   [:basin, :snow],  [0, 1, 2, 3], 0, 0, 30,   '松木直，顺纹劈，油多耐烧', '带着松脂香的松木，烧起来火旺'],
  [68, '桦木',   [:wudang, :basin],[1, 2, 3],    1, 1, 40,   '桦树皮滑，斧子要斜着吃进去', '白皮的桦木，结实耐用'],
  [69, '桃木',   [:yunv],          [0, 1],       1, 1, 60,   '桃木脆，斜着砍，别把枝子劈裂了', '玉女峰的桃木，烤东西有果香'],
  [70, '楠木',   [:basin],         [1, 2],       2, 2, 150,  '楠木硬得很，劈不动，得慢慢拉锯', '金丝楠木，盖房子的好料'],
  [71, '檀木',   [:yunv],          [2, 3],       2, 2, 200,  '檀木比铁还硬，只能拉锯', '紫檀木，香气幽幽'],
  [72, '雪松木', [:snow],          [3, 0],       1, 0, 120,  '雪松冻得脆，顺纹一劈就开', '大雪山上的雪松木，冷香扑鼻'],
  [73, '沉香木', [:basin, :yunv],  [0, 1, 2, 3], 3, 2, 1500, '沉香木在老树心里，要锯开树干才找得到', '千金难买的沉香木，一点就满屋生香'],
].each do |id, name, forests, seasons, rarity, cut, price, hint, text|
  WebMod.item id, like: 21, name: name, price: price, description: text
  forests.each { |f| WebLife.wood(id, name: name, forest: f, seasons: seasons, rarity: rarity, cut: cut, hint: hint) }
end

[
  [74, '草药',   30,  '山里随处可见的草药，药店收'],
  [75, '山菌',   40,  '雨后林子里冒出来的山菌，炖鸡最香'],
  [76, '野蜂蜜', 80,  '从野蜂窝里割下来的蜂蜜，甜得发腻'],
  [77, '鸟蛋',   25,  '一窝花斑鸟蛋'],
  [78, '山参',   800, '一支须根齐全的老山参。可以吃'],
  [79, '雪莲',   1000, '雪山顶上的雪莲，一年才开一回。可以吃'],
].each do |id, name, price, text|
  edible = { 78 => 51, 79 => 52 }[id]
  WebMod.item id, like: 21, name: name, price: price, description: text,
              **(edible ? { common_event_id: edible, occasion: 2, consumable: true } : {})
end

#--------------------------------------------------------------------------
# 斧头、樵夫套
#--------------------------------------------------------------------------
WebEquip.weapon 76, '柴刀',   :刀, 18, 300,  '老婆婆家的柴刀，刃口豁了几处，砍柴还够用'
WebEquip.weapon 77, '开山斧', :刀, 52, 6000, '歌樵子年轻时的斧头，斧背厚如门板', fx: [[:pierce, name: '开山']]
WebEquip.armor 113, '麻衣', :外衣, 12, 400, '粗麻布缝的短褂，砍柴爬山都方便', dex: 2
WebEquip.armor 114, '背篓', :披风, 4, 300, '竹编的背篓，砍柴时顺手装点山货'
WebEquip.armor 115, '草帽', :头饰, 3, 80, '麦秸编的草帽，遮阳'
WebGear.set :樵夫, '樵夫',
  pieces: [[:armor, 39], [:armor, 113], [:armor, 115], [:armor, 114], [[:weapon, 76], [:weapon, 77]]],
  tiers: { 2 => [[:regen, pct: 2]],
           4 => [[:level, skill: 71, n: 20], [:cost, ratio: 0.4, skills: [32, 33]]],
           5 => [[:custom, key: :gather_more, value: 1, text: '采山货多得一份']] }

WebMod.edit 7 do |m|                                # 裁缝店：麻衣、草帽
  m.goods '小裁缝', [[:armor, 113], [:armor, 115]]
end
WebMod.edit 16 do |m|                               # 杂货店：背篓
  m.goods '杂货贩', [[:armor, 114]]
end

#--------------------------------------------------------------------------
# 攀山步与斧法绝招
#--------------------------------------------------------------------------
WebSkill.add_skill 71, WebSkill::MOVE, 46
WebMod.variable_name 71, '攀山步'
WebSkill.attack_words 71, [                          # 斧法招式，只供两个绝招连击用
  [0, '%{user}抡起%{weapon}，一斧从上往下劈向%{objector}的%{sp}', 50, 36, 3],
  [0, '%{user}脚踩山步，身子一拧，%{weapon}横扫%{objector}的%{sp}', 50, 36, 3],
  [0, '%{user}一声断喝，%{weapon}斜着砍向%{objector}的%{sp}', 55, 36, 1],
  [0, '%{user}如伐老树，%{weapon}一下一下，专砍%{objector}的%{sp}', 60, 37, 1],
]
WebSkill.defend_words 71, [                          # 闪避：山里攀爬练出的步子
  '%{user}脚尖在石头上一点，像攀崖一样借力一纵，避了开去',
  '%{user}身子一矮，好似钻过低垂的树枝，%{objector}这一招从头顶擦过',
  '%{user}一步踩稳，一步斜跨，如走山间窄径，轻轻让开',
  '%{user}往后一仰，好像躲开倒下的大树，避得干干净净',
  '%{user}脚下一滑一撑，稳如老樵下陡坡，闪在一旁',
]
WebMod.skill 32, like: 28, name: '开山一斧', sp_cost: 300, description: '樵夫的斧法，两斧重劈'
WebMod.skill 33, like: 28, name: '伐木连斧', sp_cost: 450, description: '樵夫的斧法，四连斧'
WebSkill.perform 71, 32, 33
WebSkill.requirement 32, [[31, 71], [71, 60], [42, 60]]   # 启用攀山步，攀山步、基本刀法都到 60 级（还要拿着斧头，见下）
WebSkill.requirement 33, [[31, 71], [71, 100], [42, 100]]
WebSkill.combo 32, moves_of: 71, times: 2, stun: { state: 1, text: '%{objector}被这两斧劈得眼冒金星，一时动弹不得！' }
WebSkill.combo 33, moves_of: 71, times: 4
WebSkill.skill_words 32, ['%{user}脚下一蹬，借着攀山的劲道纵身跃起，%{weapon}高高举过头顶——开山一斧！']
WebSkill.skill_words 33, ['%{user}%{weapon}左右开弓，一斧接一斧，像伐一棵老树一样劈向%{objector}！']

module WebSkill
  class << self
    alias __axe_requirements_for requirements_for
    # 两个斧法绝招要手里拿着斧头：不拿斧头时加一条达不到的条件
    def requirements_for(id, original)
      r = __axe_requirements_for(id, original)
      return r unless [32, 33].include?(id)
      WebLife::AXES.key?($game_actors[1].weapon_id) ? r : r + [[42, 9999]]
    end
  end
end

#--------------------------------------------------------------------------
# 砍柴的规则
#--------------------------------------------------------------------------
module WebLife
  class << self
    def axe? = AXES.key?($game_actors[1].weapon_id)
    def wood_skill = data[:skill][:wood].to_i
    def wood_level = SKILL_STEPS.count { |n| wood_skill >= n }
    def wood_title = WOOD_TITLES[wood_level]
    def forest_name(f) = FORESTS[f]

    def wood_log
      data[:wood] ||= {}
    end

    # 林情（同鱼情，用 :stock 里的另一个键）
    def forest_stock(f) = stock(:"forest_#{f}")
    def drain_forest(f, n) = drain_stock(:"forest_#{f}", n)

    # 下斧前：变量 9 = 1 可以砍 5 林子秃了
    def start_chop(forest)
      @forest = forest
      @wood_interlude = nil
      if forest_stock(forest) < 15
        $game_variables[9] = 5
        return
      end
      pool = WOODS.values.select { |w| w[:forest] == forest && w[:seasons].include?(season) }
      boost = wood_level + AXES[$game_actors[1].weapon_id][:more]
      weights = pool.map { |w| [w, RARITY[w[:rarity]] + boost * w[:rarity] * (w[:rarity] == 3 ? 0.4 : 1.5)] }
      r = rand * weights.sum { |_, x| x }
      @tree = weights.find { |_, x| (r -= x) < 0 }&.first || weights[-1][0]
      roll_wood_interlude
      $game_variables[9] = 1
    end

    def bald_text
      "#{forest_name(@forest)}的树快被你砍秃了，剩下的都是小树苗。过些日子再来吧。"
    end

    def tree_prompt
      "眼前是一棵#{@tree[:name]}的树。#{@tree[:hint]}——怎么下斧？"
    end

    # 下斧：对了多得一根。顺手采山货。返回说明
    def chop(method)
      w = @tree
      n = method == w[:cut] ? 2 : 1
      $game_party.gain_item(w[:item], n)
      wood_log[w[:item]] = (wood_log[w[:item]] || 0) + n
      data[:skill][:wood] = wood_skill + 1 + w[:rarity] * 2 + (n - 1)
      drain_forest(@forest, WOOD_STOCK_COST[w[:rarity]])
      pass_time(2)
      a = $game_actors[1]
      a.hp -= 15 if a.hp > 15
      WebMod.gain_exp(CATCH_EXP[w[:rarity]]) if CATCH_EXP[w[:rarity]] > 0
      up = train(ART_WOOD, 1 + w[:rarity])
      text = method == w[:cut] ? "下斧正好，#{w[:name]}应声而开，得到#{w[:name]}两份。" : "费了好大劲，总算砍下一截#{w[:name]}。"
      text += "（实战经验+#{CATCH_EXP[w[:rarity]]}）" if CATCH_EXP[w[:rarity]] > 0
      got = gather
      text += "顺手采到了#{got}。" unless got.empty?
      text += "一上一下之间，你对攀山步又有了新的领悟！（攀山步升到#{up}级）" if up
      text
    end

    def gather
      more = 1 + (WebGear.value(:gather_more) > 0 ? 1 : 0)
      got = GATHER.select do |item, forests, seasons, chance|
        (forests.nil? || forests.include?(@forest)) && (seasons.nil? || seasons.include?(season)) && rand(100) < chance
      end
      got.each { |item, *| $game_party.gain_item(item, more) }
      got.map { |item, *| $data_items[item].name + (more > 1 ? "×#{more}" : '') }.join('、')
    end

    # ---- 伐木时的小插曲
    WOOD_INTERLUDES = [[:boar, 6, nil], [:bees, 10, nil], [:herbalist, 10, nil], [:fog, 8, [:basin, :snow, :yunv]], [:song, 8, [:wudang, :basin]]]
    def roll_wood_interlude
      return if rand(100) >= 20
      pool = WOOD_INTERLUDES.select { |_, _, fs| fs.nil? || fs.include?(@forest) }
      r = rand(pool.sum { |_, w, _| w })
      pool.each { |k, w, _| return @wood_interlude = k if (r -= w) < 0 }
    end

    def wood_interlude = @wood_interlude

    def wood_interlude_text
      case @wood_interlude
      when :boar then '林子里一阵窸窣，一头山豹从树后蹿了出来！'
      when :bees then '树杈上挂着一个野蜂窝，嗡嗡作响。'
      when :herbalist
        $game_party.gain_item(74, 1)
        '一个背着药篓的采药人路过，送你一把草药：“这山里的参，都长在松林深处的阴坡上。”'
      when :fog
        pass_time(3)
        '山里起了大雾，你在林子里转了半天才找回原处。'
      when :song
        '远处传来一阵山歌：“丁丁伐木声，山深不见人……”唱得苍劲有力。'
      else ''
      end
    end

    def poke_bees
      a = $game_actors[1]
      lost = [a.maxhp / 10, a.hp - 1].min
      a.hp -= lost if lost > 0
      $game_party.gain_item(76, 2)
      '你一斧捅下蜂窝，被蜇了好几口，脸都肿了，好在割到两块野蜂蜜。'
    end
  end
end

WebMod.enemy 162, name: '山豹', tile: 867, like: 80, maxhp: 320, gold: 0,
             stats: { 膂力: 30, 敏捷: 28, 经验: 30000 }

chopping = lambda do |c, forest|
  c.if_script('WebLife.axe?') do
    c.if_script('$game_actors[1].hp < 40') do
      c.text '你累得胳膊都抬不起来了，先歇歇吧。'
    end.else do
      c.script "WebLife.start_chop(#{forest.inspect})"
      c.if_variable(9, 5) do
        c.say 'WebLife.bald_text'
      end.else do
        c.if_script('WebLife.wood_interlude') do
          c.say 'WebLife.wood_interlude_text'
          c.if_script('WebLife.wood_interlude == :boar') do
            c.fight(162, lose: -> { c.text '山豹叼走了你挂在树杈上的干粮，钻进林子不见了。' })
          end
          c.if_script('WebLife.wood_interlude == :bees') do
            c.choices(%w[捅下来 绕开它]) do |i|
              i == 0 ? c.say('WebLife.poke_bees') : c.text('你绕开蜂窝，换了一边下斧。')
            end
          end
        end
        c.say 'WebLife.tree_prompt'
        c.choices(WebLife::CUT) { |i| c.say "WebLife.chop(#{i})" }
      end
    end
  end.else do
    c.text '一棵好树。要是手里有把斧头就好了。'
  end
end

# 伐木点：树前按确定（树上没有记号，歌樵子、老婆婆会告诉你在哪儿）
{ 26 => [[:wudang, 7, 7], [:wudang, 8, 8]], 28 => [[:basin, 7, 2], [:basin, 14, 6]],
  23 => [[:yunv, 7, 7], [:yunv, 10, 7]], 42 => [[:snow, 7, 7], [:snow, 12, 5]] }.each do |map, spots|
  WebMod.edit map do |m|
    spots.each { |forest, x, y| m.event(x, y, name: '伐木点') { |c| chopping.call(c, forest) } }
  end
end

#--------------------------------------------------------------------------
# 入行：老婆婆家劈柴满三次送柴刀
#--------------------------------------------------------------------------
alias __wood_task3 task3
def task3
  __wood_task3
  WebLife.data[:chores] = (WebLife.data[:chores] || 0) + 1
end

alias __wood_finishtask finishtask
def finishtask
  __wood_finishtask
  return unless (WebLife.data[:chores] || 0) >= 3 && !WebLife.flag?(:axe)
  WebLife.set_flag(:axe)
  $game_party.gain_weapon(76, 1)
  w = Window_Base.new(80, 128, 480, 128)
  w.contents = Bitmap.new(448, 96)
  w.contents.font.color.set(0, 0, 0)
  ['老婆婆把一把柴刀塞给你：“这刀你拿着。你劈柴是把好手，', '该上山去砍些好木头。武当山脚有个唱山歌的老樵夫，', '叫歌樵子，你去找他。”（得到柴刀）'].each_with_index do |line, i|
    w.contents.draw_text(0, i * 30, 448, 30, line)
  end
  120.times { Graphics.update }
  w.dispose
end

#--------------------------------------------------------------------------
# 歌樵子：武当山脚。樵技 5 级传攀山步、送开山斧；入了厨子行的，再教两道山珍菜
#--------------------------------------------------------------------------
WebMod.edit 26 do |m|
  m.npc 11, 9, name: '歌樵子', tile: 842,
        look: { age: 6, level: 25, attack: 5, items: '麻衣、草鞋', text: '一个精瘦的老樵夫，背着一捆柴，嘴里哼着山歌。斧柄被磨得油光发亮。' } do |c|
    c.if_variable(71, 1, 1) do
      c.if_script('WebLife.kitchen? && !WebLife.known?(80)') do
        c.text '“听说你在客栈学了做菜？山里人有山里人的吃法，教你两手。”'
        c.say 'WebLife.mountain_recipes'
      end.else do
        c.one_of '砍树跟练功一个道理，顺着它的纹路来，事半功倍。',
                 '松林深处有楠木，玉女峰上有檀木，都硬得很，得拉锯。',
                 '攀山步练到六十级，就能使“开山一斧”；一百级，“伐木连斧”。',
                 '一片林子别砍得太狠，给树留条活路，明年才有柴烧。'
      end
    end.else do
      c.if_script('WebLife.wood_level >= 5') do
        c.text '歌樵子停下山歌，打量了你一眼：“嗯，手上有茧，是砍过柴的。”'
        c.text '“山里人走惯了山路，脚下自有一套功夫。我教你这‘攀山步’，再把这把开山斧给你——斧头抡熟了，也能防身。”'
        c.variable(71, 1)
        c.gain(:weapon, 77)
        c.text '你学会了攀山步！得到了开山斧。（启用攀山步、拿着斧头砍柴，功夫会跟着长）'
      end.else do
        c.text '“丁丁伐木声，山深不见人……”歌樵子唱完一段，咧嘴一笑：“想跟我学本事？先去多砍几棵树。”（樵技 5 级）'
        c.text '“这山脚的大柳树、后山盆地的松林、玉女峰、大雪山，都有好木头。站在树跟前，拿着斧头就能砍。”'
      end
    end
  end
end

#--------------------------------------------------------------------------
# 联动：好柴入厨、山珍菜、客栈收木柴
#--------------------------------------------------------------------------
WebMod.item 80, like: 2, name: '山菌炖鸡', price: 260, common_event_id: 49, occasion: 2, consumable: true,
            description: '山菌和鸡一起炖了半天，汤鲜得掉眉毛'
WebMod.item 81, like: 2, name: '蜜汁烤鱼', price: 240, common_event_id: 50, occasion: 2, consumable: true,
            description: '刷了野蜂蜜的烤鱼，外焦里嫩，甜香扑鼻'
WebLife.recipe 80, name: '山菌炖鸡', needs: { 75 => 2, 1 => 1 }, heat: 0, taste: 1,
               hint: '山菌要文火慢炖，出了鲜味只消一点盐。', fx: [[:regen, pct: 4], [:sp_regen, pct: 3]], battles: 3
WebLife.recipe 81, name: '蜜汁烤鱼', needs: { 76 => 1, 17 => 1 }, heat: 1, taste: 2,
               hint: '大火烤，蜂蜜要刷得厚，甜得发腻才好吃。', fx: [[:power, ratio: 0.1], [:chase, chance: 8]], battles: 2
WebMod.common_event 49, '吃-山菌炖鸡' do |c| c.say 'WebLife.eat_dish(80)' end
WebMod.common_event 50, '吃-蜜汁烤鱼' do |c| c.say 'WebLife.eat_dish(81)' end
WebMod.common_event 51, '吃-山参' do |c|
  c.script "$game_variables[24] += 20\na = $game_actors[1]\na.hp = a.maxhp"
  c.text '你把老山参嚼了，一股热流从丹田升起，精神百倍。（内力修为+20）'
end
WebMod.common_event 52, '吃-雪莲' do |c|
  c.script "$game_variables[24] += 40\na = $game_actors[1]\na.hp = a.maxhp"
  c.text '雪莲入口清凉，随即化作一团暖意，游遍全身经脉。（内力修为+40）'
end

class RPG::Item
  alias __wood_type type
  def type
    [78, 79, 80, 81].include?(id) ? 0 : __wood_type
  end
end

module WebLife
  GOOD_FUEL = [67, 69, 72]                         # 松木、桃木、雪松木

  class << self
    def mountain_recipes
      names = learn(80, 81)
      "歌樵子教会了你#{names}。“山菌、蜂蜜，砍柴时顺手就能采到。”"
    end

    # 做菜时身上有好柴，自动添一把：烧掉一根，更容易出极品
    alias __wood_cook_dish cook_dish
    def cook_dish(id, heat, taste)
      fuel = GOOD_FUEL.find { |w| $game_party.item_number(w) > 0 }
      return __wood_cook_dish(id, heat, taste) unless fuel
      $game_party.lose_item(fuel, 1)
      @fuel_bonus = true
      q, n, text = __wood_cook_dish(id, heat, taste)
      [q, n, "（添了一把#{$data_items[fuel].name}，火又旺又稳）#{text}"]
    ensure
      @fuel_bonus = false
    end

    alias __wood_cook_level cook_level
    def cook_level
      __wood_cook_level + (@fuel_bonus ? 4 : 0)        # 好柴相当于厨艺高四级（神来之笔的几率）
    end

    # 客栈订单：砍过柴以后，有四分之一是收木柴
    alias __wood_cook_offer_text cook_offer_text
    def cook_offer_text
      fuel = wood_log.keys.select { |i| $data_items[i].price <= 120 }    # 只要烧火的柴，稀罕木材不当柴烧
      return __wood_cook_offer_text unless !fuel.empty? && rand(4) == 0
      id = fuel.sample
      qty = 3 + rand(4)
      data[:order] = { client: :cook, item: id, qty: qty, pay: ($data_items[id].price * qty * 1.5).to_i, day: day, wood: true }
      "灶上的柴快烧完了，你能送#{$data_items[id].name}#{qty}根来吗？我付你#{data[:order][:pay]}两。"
    end
  end
end
