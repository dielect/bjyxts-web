#==============================================================================
# ■ 郎中路线（第一批）：采药、制药、看病、医术、医者套（设计见 docs/职业生活与武林互动设计.md）
#------------------------------------------------------------------------------
#  原版：挨重击会压低气血上限（受伤），受了伤不能练功。治伤只有运功疗伤（内功、招架 30 级才行，每次 5%）、
#        金创药（2000 两，四分之一）、生肌膏（3000 两，一半），药只有平一指卖，而他见了道德 ≥128 的人就赶走。
#  入行：平安镇东的游方神医薛慕华（“阎王敌”）义诊摊。送他三份草药、读通本草纲目、或者交五百两拜师礼，
#        他收你做徒弟，送一把药锄。
#  采药：拿着药锄，在五指山、武当山、玉女峰、大雪山寨的药草前按确定。是什么药按季节、稀有程度抽；怎么挖
#        （连根挖 / 摘花叶 / 割取）看提示判断，对了多得一份。药情：一处挖多了要过些日子才长回来。
#        小插曲：毒蛇、悬崖上的灵芝（摔下来会受伤）、采药人、迷路。
#  制药：薛神医摊上的药炉。选炮制（生用 / 炒制 / 蜜炙）和火候，判断同做菜。医术越高会配的药越多：
#        草药膏、金银花茶（入行就会），续骨膏（郎中），金创药（大夫），生肌膏、大还丹（大夫以上），九花玉露丸（名医）。
#        治伤的药恢复被打掉的气血上限，和原版金创药一样算法。
#  看病：薛神医摊上的诊桌，一天最多三位病人。听症状选治法，对了收诊金；外伤的病人，身上有自制的药膏就用上，诊金翻倍。
#  医术称号：学徒、郎中、大夫、名医、神医。
#  联动：读过本草纲目，挖药时提示更准（显示该怎么挖）；薛神医给入了厨行的人教两道药膳。
#  医者套：药锄、葛布衫、药箱、斗笠。2 件回春；3 件采药多一份；4 件诊金 +30%。
#
#  编号：物品 106～113 药材、114～118 药、119～120 药膳；武器 80 药锄；防具 119 葛布衫、120 药箱；
#        公共事件 56～60 用药、61～62 吃药膳；敌人 165 毒蛇
#==============================================================================
module WebLife
  HERB_PLACES = { wuzhi: '五指山', wudang: '武当山', yunv: '玉女峰', snow: '大雪山' }
  HERBS = {}
  DIG = %w[连根挖 摘花叶 割取]
  MEDIC_TITLES = [nil, '学徒', '学徒', '郎中', '郎中', '大夫', '大夫', '名医', '名医', '神医', '神医']
  HERB_STOCK_COST = [6, 8, 12, 18]
  HOES = [80]
  MEDIC_ART = 79                                   # 青囊功（第二批）：采药、制药、看病时练

  def self.herb(item, places:, seasons: [0, 1, 2, 3], rarity:, dig:, hint:)
    places.each { |p| HERBS[[item, p]] = { item: item, place: p, seasons: seasons, rarity: rarity, dig: dig, hint: hint } }
  end
end

[
  [106, '甘草',   20,   '一把甘草根，嚼着发甜，能调和百药'],
  [107, '金银花', 30,   '一捧金银花，清热解毒'],
  [108, '当归',   80,   '当归的根，补血活血'],
  [109, '川贝',   120,  '雪山上的川贝，止咳润肺'],
  [110, '田七',   150,  '田七，止血散瘀的好药，金创药的主料'],
  [111, '血竭',   200,  '从树皮里割出来的红色树脂，治外伤的圣药'],
  [112, '何首乌', 600,  '一块人形的何首乌，越老越珍贵'],
  [113, '灵芝',   1200, '一朵紫红的灵芝，长在朽木上'],
].each do |id, name, price, text|
  WebMod.item id, like: 21, name: name, price: price, description: text
end

WebLife.herb 74,  places: %i[wuzhi wudang yunv snow], rarity: 0, dig: 1, hint: '寻常的草药，摘些叶子就行'
WebLife.herb 106, places: %i[wuzhi wudang], rarity: 0, dig: 0, hint: '甘草入药的是根，叶子没用'
WebLife.herb 107, places: %i[wudang yunv], seasons: [0, 1], rarity: 0, dig: 1, hint: '金银花要趁花苞没开的时候摘'
WebLife.herb 108, places: %i[wuzhi snow], seasons: [2, 3, 0], rarity: 1, dig: 0, hint: '当归入药的是根，秋冬最肥'
WebLife.herb 109, places: %i[snow], rarity: 1, dig: 0, hint: '川贝是埋在土里的小鳞茎，要整个挖出来'
WebLife.herb 110, places: %i[wuzhi yunv], seasons: [1, 2, 3], rarity: 1, dig: 0, hint: '田七要长够三年，挖的是根'
WebLife.herb 111, places: %i[yunv wuzhi], rarity: 2, dig: 2, hint: '血竭是树脂，要割开树皮取'
WebLife.herb 112, places: %i[wudang], seasons: [2, 3], rarity: 2, dig: 0, hint: '何首乌的块根越老越好'
WebLife.herb 113, places: %i[yunv wudang], seasons: [1, 2], rarity: 3, dig: 2, hint: '灵芝长在朽木上，要贴着根割下来'
WebLife.herb 78,  places: %i[wudang], seasons: [1, 2], rarity: 3, dig: 0, hint: '山参的须根一根都不能断，连土挖'
WebLife.herb 79,  places: %i[snow], seasons: [1], rarity: 3, dig: 1, hint: '雪莲只摘花，根留着明年还开'

#--------------------------------------------------------------------------
# 药锄、医者套
#--------------------------------------------------------------------------
WebEquip.weapon 80, '药锄', :杖, 16, 300, '薛神医的药锄，锄头磨得雪亮，也能当拐杖'
WebEquip.armor 119, '葛布衫', :外衣, 8, 300, '葛布缝的短衫，透气，上山采药不捂汗'
WebEquip.armor 120, '药箱', :披风, 4, 500, '樟木药箱，里面分了几十个小格子'
WebGear.set :医者, '医者',
  pieces: [[:weapon, 80], [:armor, 119], [:armor, 120], [:armor, 32]],
  tiers: { 2 => [[:regen, pct: 2]],
           3 => [[:custom, key: :herb_more, value: 1, text: '采药多得一份']],
           4 => [[:custom, key: :clinic_pay, value: 0.3, text: '诊金+30%']] }

#--------------------------------------------------------------------------
# 采药的规则
#--------------------------------------------------------------------------
module WebLife
  class << self
    def medic? = flag?(:medic)
    def hoe? = HOES.include?($game_actors[1].weapon_id)
    def medic_skill = data[:skill][:medic].to_i
    def medic_level = SKILL_STEPS.count { |n| medic_skill >= n }
    def medic_title = MEDIC_TITLES[medic_level]

    def gain_medic(n)
      data[:skill][:medic] = medic_skill + n
    end

    def herb_stock(p) = stock(:"herb_#{p}")

    # 气血上限的满值（原版金创药、运功疗伤的算法）
    def full_hp
      100 + $game_variables[24] / 4 + [($game_variables[157] - 14) * 20, 300].min
    end

    # 下锄前：变量 9 = 1 可以挖、5 挖空了
    def start_dig(place)
      @herb_place = place
      @herb_interlude = nil
      if herb_stock(place) < 15
        $game_variables[9] = 5
        return
      end
      pool = HERBS.values.select { |h| h[:place] == place && h[:seasons].include?(season) }
      weights = pool.map { |h| [h, RARITY[h[:rarity]] + medic_level * h[:rarity] * (h[:rarity] == 3 ? 0.3 : 1.2)] }
      r = rand * weights.sum { |_, x| x }
      @herb = weights.find { |_, x| (r -= x) < 0 }&.first || weights[-1][0]
      roll_herb_interlude
      $game_variables[9] = 1
    end

    def dug_out_text
      "#{HERB_PLACES[@herb_place]}这一片的药草被挖得差不多了，过些日子再来吧。"
    end

    def herb_prompt
      name = $data_items[@herb[:item]].name
      known = book_done?(92) ? "（本草纲目上说：该#{DIG[@herb[:dig]]}）" : ''
      "是一株#{name}。#{@herb[:hint]}#{known}——怎么挖？"
    end

    def dig(method)
      h = @herb
      right = method == h[:dig] || book_done?(92) && rand(100) < 50
      n = (right ? 2 : 1) + (WebGear.value(:herb_more) > 0 ? 1 : 0)
      $game_party.gain_item(h[:item], n)
      gain_medic(1 + h[:rarity] * 2 + (right ? 1 : 0))
      drain_stock(:"herb_#{@herb_place}", HERB_STOCK_COST[h[:rarity]])
      pass_time(2)
      WebMod.gain_exp(CATCH_EXP[h[:rarity]]) if CATCH_EXP[h[:rarity]] > 0
      up = train_medic(1 + h[:rarity])
      name = $data_items[h[:item]].name
      text = right ? "挖得干干净净，得到#{name}#{n}份。" : "挖坏了一些，只剩下#{name}#{n}份能用。"
      text += "（实战经验+#{CATCH_EXP[h[:rarity]]}）" if CATCH_EXP[h[:rarity]] > 0
      text + (up ? "一俯一仰之间，你对青囊功又有了新的领悟！（#{up}级）" : '')
    end

    # 青囊功（第二批）：学过才长
    def train_medic(times)
      $game_variables[MEDIC_ART].to_i > 0 ? train(MEDIC_ART, times) : nil
    end

    # ---- 采药的小插曲
    HERB_INTERLUDES = [[:snake, 8], [:cliff, 6], [:picker, 8], [:lost, 6]]
    def roll_herb_interlude
      return if rand(100) >= 20
      r = rand(HERB_INTERLUDES.sum { |_, w| w })
      HERB_INTERLUDES.each { |k, w| return @herb_interlude = k if (r -= w) < 0 }
    end

    def herb_interlude = @herb_interlude

    def herb_interlude_text
      case @herb_interlude
      when :snake then '草丛里“嘶”的一声，一条花斑毒蛇昂起了头！'
      when :cliff then '抬头一看，悬崖半腰的朽木上长着一朵紫红的灵芝。'
      when :picker
        $game_party.gain_item(106, 1)
        '一个背着药篓的老药农路过，送你一把甘草：“挖药别贪多，给山里留点种。”'
      when :lost
        pass_time(3)
        '山里的路七拐八绕，你转了半天才找回原处。'
      else ''
      end
    end

    # 攀崖采灵芝：六成拿到，否则摔下来——受伤（压低气血上限）
    def climb_cliff
      if rand(100) < 60 + medic_level * 2
        $game_party.gain_item(113, 1)
        return '你手脚并用攀上崖壁，小心地把灵芝割了下来。（得到灵芝）'
      end
      a = $game_actors[1]
      hurt = [full_hp / 10, a.maxhp - 1].min
      a.maxhp -= hurt
      a.hp = [a.hp, a.maxhp].min
      "脚下一滑，你从崖壁上摔了下来，摔得浑身是伤。（受伤：气血上限−#{hurt}）"
    end
  end
end

WebMod.enemy 165, name: '毒蛇', tile: 867, like: 80, maxhp: 180, gold: 0,
             stats: { 膂力: 22, 敏捷: 34, 经验: 20000 }

digging = lambda do |c, place|
  c.if_script('WebLife.hoe?') do
    c.script "WebLife.start_dig(#{place.inspect})"
    c.if_variable(9, 5) do
      c.say 'WebLife.dug_out_text'
    end.else do
      c.if_script('WebLife.herb_interlude') do
        c.say 'WebLife.herb_interlude_text'
        c.if_script('WebLife.herb_interlude == :snake') do
          c.choices(%w[打死它 绕开]) do |i|
            if i == 0
              c.fight(165, lose: -> { c.text '毒蛇在你腿上咬了一口，钻进草丛不见了。' })
            else
              c.text '你屏住呼吸，绕开了毒蛇。'
            end
          end
        end
        c.if_script('WebLife.herb_interlude == :cliff') do
          c.choices(%w[攀上去 算了]) { |i| i == 0 ? c.say('WebLife.climb_cliff') : c.text('你看了看陡峭的崖壁，摇摇头。') }
        end
      end
      c.say 'WebLife.herb_prompt'
      c.choices(WebLife::DIG) { |i| c.say "WebLife.dig(#{i})" }
    end
  end.else do
    c.text '一丛药草。手里要是有把药锄就好了。'
  end
end

# 采药点：看得见的药草（树林、崖边）
{ 24 => [[:wuzhi, 13, 6], [:wuzhi, 12, 10]], 27 => [[:wudang, 14, 2], [:wudang, 5, 12]],
  23 => [[:yunv, 4, 4], [:yunv, 27, 9]], 42 => [[:snow, 6, 9], [:snow, 5, 11]] }.each do |map, spots|
  WebMod.edit map do |m|
    spots.each { |place, x, y| m.event(x, y, name: '药草', tile: 506) { |c| digging.call(c, place) } }
  end
end

#--------------------------------------------------------------------------
# 药：制法与服用
#--------------------------------------------------------------------------
module WebLife
  PREPS = %w[生用 炒制 蜜炙]
  MEDS = {}

  # 一味药：id 物品；needs 药材；prep / heat 是 PREPS / HEATS 的下标；level 要几级医术才会
  def self.med(id, needs:, prep:, heat:, level:, hint:, use:)
    MEDS[id] = { id: id, needs: needs, prep: prep, heat: heat, level: level, hint: hint, use: use }
  end
end

[
  [114, '草药膏',     150,  56, '草药捣烂熬成的膏，敷上能治轻伤'],
  [115, '续骨膏',     600,  57, '当归、田七熬的膏药，跌打损伤都能治'],
  [116, '金银花茶',   80,   58, '一壶金银花茶，清热解渴'],
  [117, '大还丹',     2500, 59, '何首乌、灵芝炼的丹药，补足内力'],
  [118, '九花玉露丸', 6000, 60, '采雪莲、灵芝、山参炼成的丸药，清香扑鼻，大增内力修为'],
].each do |id, name, price, ce, text|
  WebMod.item id, like: 2, name: name, price: price, common_event_id: ce, occasion: 2, consumable: true, description: text
end

WebLife.med 114, needs: { 74 => 2 }, prep: 0, heat: 0, level: 0, hint: '草药生用，捣烂了用文火慢慢熬成膏。', use: '恢复一成被打掉的气血上限'
WebLife.med 116, needs: { 107 => 2, 106 => 1 }, prep: 0, heat: 0, level: 0, hint: '金银花不能炒，生用，文火泡出味来就行。', use: '解渴，回两成气血'
WebLife.med 115, needs: { 108 => 1, 110 => 1, 74 => 1 }, prep: 1, heat: 2, level: 3, hint: '当归、田七要炒过才出药性；先武火煎透，再文火收膏。', use: '恢复三成被打掉的气血上限'
WebLife.med 8, needs: { 110 => 2, 111 => 1 }, prep: 1, heat: 1, level: 5, hint: '田七炒黄，血竭研末，武火急煎——原版平一指的方子。', use: '恢复四分之一被打掉的气血上限'
WebLife.med 9, needs: { 108 => 2, 111 => 1, 74 => 2 }, prep: 2, heat: 0, level: 6, hint: '当归蜜炙，加血竭、草药，文火熬上一夜成膏。', use: '恢复一半被打掉的气血上限'
WebLife.med 117, needs: { 112 => 1, 113 => 1, 106 => 1 }, prep: 2, heat: 2, level: 6, hint: '何首乌要蜜炙九蒸九晒，先武后文，火候一刻不能差。', use: '补满内力，内力修为+2'
WebLife.med 118, needs: { 79 => 1, 113 => 1, 78 => 1, 107 => 2 }, prep: 0, heat: 0, level: 7, hint: '雪莲、灵芝、山参都是天地精华，生用，文火慢炼七七四十九天。', use: '内力修为+8'

module WebLife
  class << self
    def med_known?(id) = medic? && medic_level >= MEDS[id][:level]
    def med_ids = MEDS.keys.select { |id| med_known?(id) }

    def can_brew?(id)
      MEDS[id][:needs].all? { |item, n| $game_party.item_number(item) >= n }
    end

    def med_needs_text(id)
      MEDS[id][:needs].map { |item, n| "#{$data_items[item].name}×#{n}（有#{$game_party.item_number(item)}）" }.join('、')
    end

    # 配一味药：返回 [品质 0～2, 份数, 说明]（判断同做菜）
    def brew(id, prep, heat)
      m = MEDS[id]
      m[:needs].each { |item, n| $game_party.lose_item(item, n) }
      q = (prep == m[:prep] ? 1 : 0) + (heat == m[:heat] ? 1 : 0)
      q += 1 if q < 2 && rand(100) < medic_level * 4
      n = q == 2 ? 2 : 1
      $game_party.gain_item(id, n)
      gain_medic(1 + q)
      pass_time(2)
      up = train_medic(1 + q)
      tips = ["炮制#{prep == m[:prep] ? '得法' : '不太对'}", "火候#{heat == m[:heat] ? '正好' : '不太对'}"]
      text = "#{$data_items[id].name}配好了！成色：#{QUALITY[q]}（#{tips.join('，')}），得到#{n}份。"
      text += "（青囊功升到#{up}级）" if up
      [q, n, text]
    end

    # 治伤：恢复被打掉的气血上限（同原版金创药的算法）
    def heal_injury(ratio)
      a = $game_actors[1]
      full = full_hp
      return '你身上没有伤，这药白敷了。' if a.maxhp >= full
      a.maxhp = [a.maxhp + (full * ratio).to_i, full].min
      a.hp = [a.hp + (full * ratio).to_i, a.maxhp].min
      a.maxhp >= full ? '药力化开，伤全好了。' : "药力化开，伤好了一些。（气血上限#{a.maxhp}/#{full}）"
    end

    def injured? = $game_actors[1].maxhp < full_hp
  end
end

WebMod.common_event 56, '用-草药膏' do |c| c.say 'WebLife.heal_injury(0.1)' end
WebMod.common_event 57, '用-续骨膏' do |c| c.say 'WebLife.heal_injury(0.3)' end
WebMod.common_event 58, '用-金银花茶' do |c|
  c.script "$game_variables[17] = [$game_variables[17] + 200, $game_variables[18]].min\na = $game_actors[1]\na.hp = [a.hp + a.maxhp / 5, a.maxhp].min"
  c.text '一壶金银花茶下肚，暑气全消。'
end
WebMod.common_event 59, '用-大还丹' do |c|
  c.script "a = $game_actors[1]\na.sp = a.maxsp\n$game_variables[24] += 2"
  c.text '大还丹入腹，丹田里一股热气直冲上来，内力充盈。（内力修为+2）'
end
WebMod.common_event 60, '用-九花玉露丸' do |c|
  c.script '$game_variables[24] += 8'
  c.text '九花玉露丸清香满口，一股清凉之气游遍全身经脉。（内力修为+8）'
end

class RPG::Item
  alias __medic_type type
  def type
    return 1 if (114..118).include?(id)          # 药物
    return 0 if [119, 120].include?(id)          # 药膳归食物
    __medic_type
  end
end

class Scene_Brew < Scene_Cook
  def ids = WebLife.med_ids
  def label(id) = $data_items[id].name
  def can?(id) = WebLife.can_brew?(id)
  def empty_text = '（还不会配药）'
  def options1 = WebLife::PREPS
  def options2 = WebLife::HEATS
  def prompt1 = '炮制：生用、炒制，还是蜜炙？'
  def prompt2 = '火候：文火、武火，还是先武后文？'
  def make(id, a, b) = WebLife.brew(id, a, b)

  def draw_info(c)
    l = WebLife
    c.draw_text(0, 0, 368, 28, "药炉　医术：#{l.medic_title || '新手'}（#{l.medic_level}级）")
    c.font.size = 16
    c.draw_text(0, 30, 368, 22, l.injured? ? "你受了伤：气血上限#{$game_actors[1].maxhp}/#{l.full_hp}" : '（身上没有伤）')
    id = current or return @help.set_text('先跟薛神医学几味药吧。')
    m = l::MEDS[id]
    c.font.size = 18
    y = 64
    wrap = lambda do |text|
      WebLife.wrap_lines(text, 19).each { |line| c.draw_text(0, y, 368, 24, line); y += 24 }
    end
    wrap.call("药材：#{l.med_needs_text(id)}")
    y += 6
    wrap.call("讲究：#{m[:hint]}")
    y += 6
    wrap.call("用处：#{m[:use]}")
    @help.set_text(l.can_brew?(id) ? "#{label(id)}：按确定开始配" : "#{label(id)}：药材不够")
  end
end

#--------------------------------------------------------------------------
# 看病：诊桌
#--------------------------------------------------------------------------
module WebLife
  # [病人, 题目（一行以内）, [对的治法, 错的, 错的], 诊金, 外伤（可以用自制药膏）]
  CASES = [
    ['张大婶头痛发热，怕冷，一点汗也没有。', '该怎么治？', %w[发汗解表 清热泻火 补气养血], 30, false],
    ['一个小孩吃坏了肚子，上吐下泻。', '该怎么治？', %w[消食和胃 发汗解表 活血化瘀], 30, false],
    ['老汉腰腿酸痛，一到阴雨天就加重。', '该怎么治？', %w[祛风除湿 清热解毒 消食和胃], 40, false],
    ['一个樵夫被斧头砍伤了腿，血流不止。', '先怎么办？', %w[先止血再敷药 先灌一碗酒 让他多走动], 50, true],
    ['一个书生熬夜读书，心慌失眠。', '该怎么治？', %w[养心安神 发汗解表 泻下通便], 40, false],
    ['一个渔夫在河边被毒蛇咬了。', '先怎么办？', %w[扎紧伤口吸出毒 用热水泡 让他跑起来], 50, true],
    ['产妇产后体虚，面色苍白。', '该怎么治？', %w[补气养血 清热泻火 发汗解表], 50, false],
    ['一个镖师胸口中了一掌，咳出血来。', '该怎么治？', %w[活血化瘀 发汗解表 消食和胃], 80, true],
    ['大热天一个挑夫中了暑，头晕恶心。', '该怎么治？', %w[清暑解热 补气养血 祛风除湿], 30, false],
  ]
  PATIENTS_PER_DAY = 3
  SALVES = [115, 114]

  class << self
    def patients_today
      d, n = data[:patients]
      d == day ? n.to_i : 0
    end

    # 坐诊：变量 9 = 1 来了病人、2 今天没人了
    def start_clinic
      if patients_today >= PATIENTS_PER_DAY
        $game_variables[9] = 2
        return
      end
      data[:patients] = [day, patients_today + 1]
      @case = CASES.sample
      $game_variables[9] = 1
    end

    def no_patient_text = '今天的病人都看完了。薛神医在一旁收拾药箱：“明天再来。”'
    def patient_text = @case[0]

    def case_question
      WebMod.choice_labels = @case[2].shuffle
      @case_answer = WebMod.choice_labels.index(@case[2][0])
      @case[1]
    end

    def treat(i)
      _, _, ways, base, wound = @case
      right = i == @case_answer
      salve = right && wound && SALVES.find { |s| $game_party.item_number(s) > 0 }
      $game_party.lose_item(salve, 1) if salve
      pay = (base * (1 + medic_level * 0.2) * (right ? 1 : 0.3) * (salve ? 2 : 1) * (1 + WebGear.value(:clinic_pay))).to_i
      $game_party.gain_gold(pay)
      gain_medic(right ? 3 : 1)
      pass_time(2)
      up = train_medic(right ? 3 : 1)
      text = if right
               "对症下药，病人千恩万谢，留下#{pay}两诊金。" + (salve ? "（用上了自制的#{$data_items[salve].name}，诊金翻倍）" : '')
             else
               "病人吃了药不见好，薛神医在旁边摇摇头：“该#{ways[0]}。”病人只留下#{pay}两。"
             end
      text + (up ? "（青囊功升到#{up}级）" : '')
    end
  end
end

#--------------------------------------------------------------------------
# 薛神医的义诊摊：平安镇东。薛神医、诊桌、药炉
#--------------------------------------------------------------------------
module WebLife
  class << self
    def medic_entry_way
      return :book if book_done?(92)
      return :herbs if $game_party.item_number(74) >= 3
      return :gold if $game_party.gold >= 500
      nil
    end

    def enter_medic
      case medic_entry_way
      when :herbs then $game_party.lose_item(74, 3)
      when :gold then $game_party.lose_gold(500)
      end
      set_flag(:medic)
      $game_party.gain_weapon(80, 1)
    end

    def medic_entry_text
      case medic_entry_way
      when :book then '“读过本草纲目？好，好，省了我一半口舌。”'
      when :herbs then '你把三份草药递过去。薛神医捏起一片叶子闻了闻：“采得不错。”'
      else '你恭恭敬敬奉上五百两拜师礼。薛神医摆摆手：“钱我替你买药材，算你的。”'
      end
    end

    def medic_dishes_due? = medic? && kitchen? && !known?(119)

    def medic_dishes
      names = learn(119, 120)
      "“听说你还会做菜？药食同源，教你两道药膳。”（学会了#{names}）"
    end
  end
end

WebMod.item 119, like: 2, name: '当归炖鸡', price: 300, common_event_id: 61, occasion: 2, consumable: true,
            description: '当归和鸡一起炖的药膳，补气养血'
WebMod.item 120, like: 2, name: '金银花鱼汤', price: 200, common_event_id: 62, occasion: 2, consumable: true,
            description: '金银花煮的鲫鱼汤，清热解毒'
WebLife.recipe 119, name: '当归炖鸡', needs: { 108 => 1, 1 => 1 }, heat: 0, taste: 1,
               hint: '当归味重，文火慢炖，咸鲜就好，别压了药香。', fx: [[:regen, pct: 4], [:reduce, ratio: 0.06]], battles: 3
WebLife.recipe 120, name: '金银花鱼汤', needs: { 107 => 1, 28 => 1 }, heat: 0, taste: 0,
               hint: '金银花一煮就散，文火，清淡，出锅前才放。', fx: [[:sp_regen, pct: 4], [:steady]], battles: 3
WebMod.common_event 61, '吃-当归炖鸡' do |c| c.say 'WebLife.eat_dish(119)' end
WebMod.common_event 62, '吃-金银花鱼汤' do |c| c.say 'WebLife.eat_dish(120)' end

WebMod.edit 5 do |m|
  m.npc 6, 9, name: '薛神医', tile: 881,
        look: { age: 5, level: 20, attack: 2, items: '葛布衫、药箱', text: '游方行医的薛慕华，人称“阎王敌”。在镇东摆了个义诊摊，穷人看病不收钱。' },
        shop: [[:item, 114], [:item, 116], [:weapon, 80], [:armor, 119], [:armor, 120]] do |c|
    c.if_script('!WebLife.medic?') do
      c.text '薛神医捋着胡子：“看病？还是想学医？学医可苦，上山采药、守着药炉熬夜，一样都少不了。”'
      c.if_script('WebLife.medic_entry_way') do
        c.choices(%w[拜师学医 再想想]) do |i|
          if i == 0
            c.say 'WebLife.medic_entry_text'
            c.script 'WebLife.enter_medic'
            c.text '“从今天起你就是我的徒弟了。这把药锄拿着：山上的药草，拿着它就能挖。”（得到药锄）'
            c.text '“我这摊上的药炉、诊桌，你随时用。医术长进了，我再教你配更难的药。”'
          else
            c.text '“想好了再来。”'
          end
        end
      end.else do
        c.text '“想学医，先给我采三份草药来（砍柴时山里顺手就能采到），或者读读本草纲目。实在不行，交五百两拜师礼也成。”'
      end
    end.else do
      c.if_script('WebLife.medic_dishes_due?') do
        c.say 'WebLife.medic_dishes'
      end.else do
        c.one_of '挖药跟看病一个道理，先看清楚是什么，再下手。',
                 '五指山、武当山、玉女峰、大雪山，都有好药。灵芝长在悬崖上，要小心。',
                 '外伤的病人，你身上带着自己配的药膏，就给他用上。',
                 '平一指那人医术是高，就是只医坏人。咱们不挑病人。'
      end
    end
  end
  m.event 7, 9, name: '诊桌', tile: 645 do |c|
    c.if_script('WebLife.medic?') do
      c.script 'WebLife.start_clinic'
      c.if_variable(9, 2) do
        c.say 'WebLife.no_patient_text'
      end.else do
        c.say 'WebLife.patient_text'
        c.say 'WebLife.case_question'
        c.choices(%w[{0} {1} {2}]) { |i| c.say "WebLife.treat(#{i})" }
      end
    end.else do
      c.text '薛神医的诊桌，排队看病的人不少。（拜薛神医为师后可以坐诊）'
    end
  end
  m.event 5, 9, name: '药炉', tile: 510 do |c|
    c.if_script('WebLife.medic?') do
      c.script '$scene = Scene_Brew.new'
    end.else do
      c.text '一口小药炉，炉火正旺，药香扑鼻。'
    end
  end
end
