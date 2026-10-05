#==============================================================================
# ■ 书生路线（第一批）：读书、书目、学识、代写、书生套（设计见 docs/职业生活与武林互动设计.md）
#------------------------------------------------------------------------------
#  入行：跟顾炎武学过读书识字（变量 48 ≥ 1）后，到私塾书架前按确定，书童领你进书房，送《三字经》和一本书目。
#  读书：在物品栏里打开一本书，每次读一章（过一个多时辰）。一天最多读六章（眼睛酸了）。有时会冒出一道小题，答对多读一章。
#        读一章涨学识，并按原版学武规则长读书识字（不花潜能，受经验上限约束；读书只读到 100 级，再往上请教顾先生）。
#        一本书读通有一次性的收获：话本、史书给潜能（阅历），杂学和别的生活路线联动，少数稀罕书小幅加属性。
#        小插曲：打瞌睡、书里夹着旧信、灵光一现、蠹鱼、书童来问字（只在私塾）。
#  书从哪来：私塾书架（经史）、商业街书摊（杂学、话本、兵书）、货郎（史记）、落魄书生（奇遇 30：山海经、武经总要）、
#           顾先生（学识 6 级送易经）。
#  代写：商业街的代书桌，一天最多三位客人。家书、状纸、借据、墓志、招牌、春联（冬天）、情书（读过诗经）……
#        措辞要选对，对了全价，错了只给四成。王大娘每回都给边关的儿子写信，写满五封，儿子回来了。
#  学识称号：识字、读书人、饱学、博学、鸿儒。
#  书生套（050 原有的描金折扇、方巾、儒衫，加上云头履、玉佩、书箱）：原有 2 件读书识字 +20、3 件绝招省力；
#        新增 4 件一天多读两章、5 件代写报酬 +30%、6 件话本史书的阅历加倍。
#
#  编号：物品 83～101 书、102 书目；公共事件 53 读书、54 书目、55 用草药（读过本草纲目才会用）；
#        防具 116 云头履、117 玉佩、118 书箱；奇遇 30 落魄书生
#==============================================================================
module WebLife
  BOOK_KINDS = { classic: '经史', misc: '杂学', tale: '话本', war: '兵书' }
  BOOKS = {}
  BOOK_TITLES = [nil, '识字', '识字', '读书人', '读书人', '饱学', '饱学', '博学', '博学', '鸿儒', '鸿儒']
  BOOK_ART = 48                                          # 读书识字
  BOOK_ART_CAP = 100
  EYES_PER_DAY = 6

  # 一本书：物品编号、名字、类别、几章、价钱、说明、读通的收获（reward 方法里的键）、小题 [[题, [对的, 错的, 错的]], ...]
  def self.book(id, name, kind, chapters, price, text, reward, quiz)
    BOOKS[id] = { id: id, name: name, kind: kind, chapters: chapters, reward: reward, quiz: quiz }
    WebMod.item id, like: 21, name: name, price: price, common_event_id: 53, occasion: 2, consumable: false, description: text
  end
end

WebLife.book 83, '三字经', :classic, 3, 20, '蒙学第一本书，人之初，性本善', [:pot, 60],
  [['「人之初」下一句？', %w[性本善 性相近 习相远]], ['「玉不琢」下一句？', %w[不成器 不知义 不成才]]]
WebLife.book 84, '千字文', :classic, 3, 20, '一千个字不重样，天地玄黄，宇宙洪荒', [:pot, 60],
  [['「天地玄黄」下一句？', %w[宇宙洪荒 日月盈昃 辰宿列张]], ['「寒来暑往」下一句？', %w[秋收冬藏 闰余成岁 律吕调阳]]]
WebLife.book 85, '论语', :classic, 5, 60, '孔子和弟子的言行，半部论语治天下', [:moral, 3, 120],
  [['「学而时习之」下一句？', %w[不亦说乎 不亦乐乎 人不知而不愠]], ['「三人行」下一句？', %w[必有我师焉 必有一失 其中有我]],
   ['「己所不欲」下一句？', %w[勿施于人 必施于人 勿求于人]]]
WebLife.book 86, '孟子', :classic, 5, 60, '孟子的文章，浩然之气，至大至刚', [:moral, 3, 120],
  [['「得道多助」下一句？', %w[失道寡助 失道者亡 得道者昌]], ['「富贵不能淫」下一句？', %w[贫贱不能移 威武不能屈 贫贱不能淫]],
   ['「生于忧患」下一句？', %w[死于安乐 死于非命 长于忧患]]]
WebLife.book 87, '诗经', :classic, 4, 50, '三百篇诗，关关雎鸠，在河之洲', [:poem, 120],
  [['「关关雎鸠」下一句？', %w[在河之洲 窈窕淑女 君子好逑]], ['「蒹葭苍苍」下一句？', %w[白露为霜 所谓伊人 在水一方]]]
WebLife.book 88, '易经', :classic, 6, 3000, '群经之首，讲阴阳变化。顾先生的批注本', [:wit],
  [['「天行健」下一句？', %w[君子以自强不息 君子以厚德载物 君子以独善其身]], ['「地势坤」下一句？', %w[君子以厚德载物 君子以自强不息 君子以果行育德]]]
WebLife.book 89, '史记', :classic, 6, 1500, '太史公的书，从黄帝写到汉武帝', [:pot, 400],
  [['「燕雀安知」下一句？', %w[鸿鹄之志哉 鸿雁之志哉 大鹏之志哉]], ['「项庄舞剑」下一句？', %w[意在沛公 意在项王 意在樊哙]]]
WebLife.book 90, '渔樵问对', :misc, 3, 200, '邵康节写的，一个渔夫和一个樵夫在河边问答', [:fisher_woodman],
  [['这本书是谁写的？', %w[邵雍 朱熹 苏轼]], ['书里说鱼为什么上钩？', %w[贪饵 好奇 饿了]]]
WebLife.book 91, '齐民要术', :misc, 4, 300, '贾思勰写的农书，种地、养鸡、酿酒、做菜都有', [:cook_book],
  [['这本书是谁写的？', %w[贾思勰 沈括 宋应星]], ['书里讲的主要是？', %w[农桑饮食 兵法战阵 天文历算]]]
WebLife.book 92, '本草纲目', :misc, 5, 400, '李时珍的药书，一草一木都写明了药性', [:herb],
  [['这本书是谁写的？', %w[李时珍 华佗 孙思邈]], ['书里说人参？', %w[大补元气 能解百毒 专治外伤]]]
WebLife.book 93, '棋经十三篇', :misc, 4, 300, '讲围棋的道理，以正合，以奇胜', [:go],
  [['「棋者，以正合」下一句？', %w[以奇胜 以和胜 以变胜]], ['「宁输数子」下一句？', %w[勿失一先 勿失一角 勿失一子]]]
WebLife.book 94, '山海经', :misc, 5, 2000, '一本古怪的书，写尽了天下的奇山异兽', [:rumor],
  [['精卫衔木石是为了？', %w[填东海 筑巢穴 补苍天]], ['夸父追的是？', %w[太阳 月亮 神鹿]]]
WebLife.book 95, '三国演义', :tale, 8, 250, '说书先生最爱讲的书，天下大势，分久必合', [:tale, 300],
  [['桃园结义的是哪三人？', %w[刘关张 曹刘孙 刘关赵]], ['草船借箭的是谁？', %w[诸葛亮 周瑜 鲁肃]]]
WebLife.book 96, '水浒传', :tale, 8, 250, '一百单八将，替天行道', [:tale, 300],
  [['景阳冈打虎的是谁？', %w[武松 李逵 鲁智深]], ['倒拔垂杨柳的是谁？', %w[鲁智深 武松 林冲]]]
WebLife.book 97, '西游记', :tale, 8, 250, '一个猴子保着和尚去西天取经', [:tale, 300],
  [['孙悟空使的兵器是？', %w[如意金箍棒 九齿钉耙 降妖宝杖]], ['孙悟空三打的是谁？', %w[白骨精 牛魔王 红孩儿]]]
WebLife.book 98, '聊斋志异', :tale, 6, 200, '狐鬼花妖的故事，夜里别一个人看', [:tale, 200],
  [['这本书是谁写的？', %w[蒲松龄 吴承恩 冯梦龙]], ['书里写得最多的是？', %w[狐鬼花妖 帝王将相 江湖豪侠]]]
WebLife.book 99, '太白诗集', :tale, 4, 300, '李白的诗，十步杀一人，千里不留行', [:tale, 150],
  [['「十步杀一人」下一句？', %w[千里不留行 事了拂衣去 深藏身与名]], ['「床前明月光」下一句？', %w[疑是地上霜 举头望明月 低头思故乡]]]
WebLife.book 100, '孙子兵法', :war, 6, 600, '兵家的书，知己知彼，百战不殆', [:exp, 2000],
  [['「知己知彼」下一句？', %w[百战不殆 百战百胜 一胜一负]], ['「上兵伐谋」其次是？', %w[伐交 伐兵 攻城]]]
WebLife.book 101, '武经总要', :war, 6, 2500, '朝廷编的兵书，刀枪器械、火药方子都画了图', [:exp, 5000],
  [['这本书是哪朝编的？', %w[宋朝 唐朝 明朝]], ['书里头一回记下的是？', %w[火药方子 九阴真经 长生之术]]]

WebMod.item 102, like: 21, name: '书目', price: 0, common_event_id: 54, occasion: 2, consumable: false,
            description: '书童给你的小本子，记着读过的书'

#--------------------------------------------------------------------------
# 读书的规则
#--------------------------------------------------------------------------
module WebLife
  READ_INTERLUDES = [[:doze, 6], [:letter, 4], [:insight, 5], [:worm, 3], [:boy, 6]]

  class << self
    def scholar? = flag?(:scholar)
    def book_skill = data[:skill][:book].to_i
    def book_level = SKILL_STEPS.count { |n| book_skill >= n }
    def book_title = BOOK_TITLES[book_level]

    def gain_book_skill(n)
      data[:skill][:book] = book_skill + n
    end

    # 每本书读到第几章：{ 物品 => 章数 }
    def books_read
      data[:books] ||= {}
    end

    def book_done?(id) = books_read[id].to_i >= BOOKS[id][:chapters]
    def books_done = BOOKS.keys.count { |id| book_done?(id) }

    def eyes_max = EYES_PER_DAY + (WebGear.value(:read_more) > 0 ? 2 : 0)

    def eyes_used
      d, n = data[:eyes]
      d == day ? n.to_i : 0
    end

    def use_eyes
      data[:eyes] = [day, eyes_used + 1]
    end

    # 打开一本书：变量 9 = 1 读、2 眼睛酸了
    def start_read
      @book = BOOKS[$web_used_item.to_i] || BOOKS[83]
      @quiz = nil
      @read_interlude = nil
      if eyes_used >= eyes_max
        $game_variables[9] = 2
        return
      end
      roll_read_interlude
      @quiz = @book[:quiz].sample if @read_interlude.nil? && !book_done?(@book[:id]) && rand(100) < 35
      $game_variables[9] = 1
    end

    def tired_text
      "眼睛又酸又涩，字都看成了重影。今天读了#{eyes_used}章，明天再读吧。"
    end

    def roll_read_interlude
      return if rand(100) >= 20
      pool = READ_INTERLUDES.reject { |k, _| k == :boy && $game_map.map_id != 9 }
      r = rand(pool.sum { |_, w| w })
      pool.each { |k, w| return @read_interlude = k if (r -= w) < 0 }
    end

    def read_interlude = @read_interlude

    def read_interlude_text
      case @read_interlude
      when :doze
        pass_time(2)
        '读着读着，眼皮越来越沉，一头栽在书上睡着了。醒来时，口水把书页洇湿了一片。'
      when :letter
        g = 30 + rand(170)
        $game_party.gain_gold(g)
        "书页里夹着一张发黄的信笺，是哪位前人写给家里的。信里还包着#{g}两碎银子。"
      when :insight
        '读到一处，忽然豁然开朗，前面几章没想通的地方，一下子都通了。'
      when :worm
        '书页上被蠹鱼咬出一串小洞，你只好连蒙带猜地读下去。'
      when :boy
        gain_book_skill(2)
        '小书童探头进来：“这个字念什么呀？”你给他讲了半天，自己倒也温习了一遍。（学识+2）'
      else ''
      end
    end

    # 小题：选项打乱，记下对的是第几个
    def quiz? = !@quiz.nil?

    def quiz_text
      WebMod.choice_labels = @quiz[1].shuffle
      @quiz_answer = WebMod.choice_labels.index(@quiz[1][0])
      @quiz[0]
    end

    def answer(i)
      right = @quiz[1][0]
      @quiz = nil
      if i == @quiz_answer
        @quiz_bonus = true
        "对了！这一处读通了，往下读得飞快。（多读一章）"
      else
        "不对，是“#{right}”。你红着脸把这句抄了三遍。"
      end
    end

    # 读一章：涨学识、读书识字；读通了领收获。返回说明
    def read_chapter
      b = @book
      use_eyes
      pass_time(1)
      if @read_interlude == :doze
        @quiz_bonus = false
        return "这一觉睡掉了大半天，《#{b[:name]}》一页也没翻过去。"
      end
      was_done = book_done?(b[:id])
      n = 1 + (@quiz_bonus ? 1 : 0) + (@read_interlude == :insight ? 1 : 0)
      @quiz_bonus = false
      books_read[b[:id]] = [books_read[b[:id]].to_i + n, b[:chapters]].min
      gain = was_done ? 1 : n * (1 + (b[:kind] == :classic ? 1 : 0)) + ($game_map.map_id == 9 ? 1 : 0)
      gain_book_skill(gain)
      up = train_reading(n)
      text = if was_done
               "《#{b[:name]}》你早就读通了，温故而知新。（学识+#{gain}）"
             else
               "读完了《#{b[:name]}》第#{books_read[b[:id]]}章，共#{b[:chapters]}章。（学识+#{gain}）"
             end
      text += "读书识字长进了！（#{up}级）" if up
      text += book_reward(b) if !was_done && book_done?(b[:id])
      text
    end

    # 读书长读书识字：没学过、到了 100 级就不长
    def train_reading(chapters)
      return nil if $game_variables[BOOK_ART] >= BOOK_ART_CAP
      up = train(BOOK_ART, chapters * (10 + book_level * 4))
      $game_variables[BOOK_ART] = BOOK_ART_CAP if up && $game_variables[BOOK_ART] > BOOK_ART_CAP
      up && [up, BOOK_ART_CAP].min
    end

    def art_capped_note
      $game_variables[BOOK_ART] >= BOOK_ART_CAP ? '（读书识字到了一百级，书上的已经难不倒你，再往上要请教顾先生）' : ''
    end

    # ---- 读通一本书的收获
    def book_reward(b)
      gain_book_skill(5)
      kind, *args = b[:reward]
      tale_rate = WebGear.value(:tale_double) > 0 ? 2 : 1
      case kind
      when :pot
        WebMod.gain_pot(args[0] * tale_rate)
        "合上书，只觉得见识长了不少。（潜能+#{args[0] * tale_rate}）"
      when :tale
        WebMod.gain_pot(args[0] * tale_rate)
        "书里的英雄好汉、悲欢离合，看得你如同亲身走了一遭。（江湖阅历，潜能+#{args[0] * tale_rate}）"
      when :moral
        WebMod.gain_morality(args[0])
        WebMod.gain_pot(args[1])
        "圣贤的话一句句记在心里，做人做事更有分寸了。（道德+#{args[0]}，潜能+#{args[1]}）"
      when :poem
        WebMod.gain_pot(args[0])
        "诗三百，一言以蔽之，思无邪。往后有人请你写情书，你也写得出来了。（潜能+#{args[0]}）"
      when :wit
        $game_variables[13] += 1
        '读通了易经，看什么都多了一层变化。（悟性+1）'
      when :exp
        WebMod.gain_exp(args[0])
        "合上书，觉得自己能打十个——其实未必，不过招式里的进退确实多了些讲究。（实战经验+#{args[0]}）"
      when :fisher_woodman
        data[:skill][:fishing] = data[:skill][:fishing].to_i + 15
        data[:skill][:wood] = data[:skill][:wood].to_i + 15
        '渔者识鱼性，樵者知木理。读完了，钓鱼砍柴都有了新的心得。（渔技、樵技各+15）'
      when :cook_book
        data[:skill][:cooking] = data[:skill][:cooking].to_i + 20
        '书里讲的做酱、腌菜、炙肉的法子，都是老祖宗的手艺。（厨艺+20）'
      when :herb
        '一草一木的药性都记下了。往后采到的草药，自己就会用了。（草药可以在物品栏里服用，回气血）'
      when :go
        WebMod.gain_pot(150)
        tip = $game_switches[106] ? '' : '书里有一句“欲取先予，置之死地而后生”，你忽然想起西郊那盘怪棋。'
        "#{tip}（潜能+150）"
      when :rumor
        rumor_from_book
      else ''
      end
    end

    # 山海经：书页边上有人用小字批注着一条江湖传闻（第一条还没听过的）
    def rumor_from_book
      sw, _, rumor = RUMORS.find { |s, cond, _| !$game_switches[s] && eval(cond.is_a?(String) ? cond : 'false') }
      return '书页边上密密麻麻写满了批注，可惜都是些你已经知道的事。' unless sw
      $game_switches[sw] = true
      "书页边上有人用小字批注：#{rumor}"
    end
  end
end

#--------------------------------------------------------------------------
# 公共事件：读书、书目、用草药
#--------------------------------------------------------------------------
WebMod.common_event 53, '读书' do |c|
  c.script 'WebLife.start_read'
  c.if_variable(9, 2) do
    c.say 'WebLife.tired_text'
  end.else do
    c.if_script('WebLife.read_interlude') do
      c.say 'WebLife.read_interlude_text'
    end
    c.if_script('WebLife.quiz?') do
      c.say 'WebLife.quiz_text'
      c.choices(%w[{0} {1} {2}]) { |i| c.say "WebLife.answer(#{i})" }
    end
    c.say 'WebLife.read_chapter'
  end
end

WebMod.common_event 54, '书目' do |c|
  c.script '$scene = Scene_BookList.new'
end

WebMod.common_event 55, '用草药' do |c|
  c.if_script('WebLife.book_done?(92)') do
    c.script "a = $game_actors[1]\na.hp = [a.hp + a.maxhp * 15 / 100, a.maxhp].min"
    c.text '你照本草纲目上的法子把草药嚼烂敷上，伤口一阵清凉。（回复一成半气血）'
  end.else do
    c.script '$game_party.gain_item(74, 1)'
    c.text '这草药该怎么用？你翻来覆去看了半天，还是不敢往嘴里放。（读过本草纲目就会用了）'
  end
end

class Scene_BookList
  def main
    @page = 0
    @kinds = WebLife::BOOK_KINDS.keys
    @window = Window_Base.new(0, 0, 640, 480)
    @window.contents = Bitmap.new(608, 448)
    refresh
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      break if Input.trigger?(Input::B) || Input.trigger?(Input::C)
      if Input.trigger?(Input::RIGHT) || Input.trigger?(Input::LEFT)
        @page = (@page + (Input.trigger?(Input::RIGHT) ? 1 : -1)) % @kinds.size
        $game_system.se_play($data_system.cursor_se)
        refresh
      end
    end
    $game_system.se_play($data_system.cancel_se)
    $scene = Scene_Map.new
    Graphics.freeze
    @window.dispose
  end

  # 一页一类：书名、读到第几章；没见过的书显示“？？？”
  def refresh
    c = @window.contents
    c.clear
    c.font.color.set(0, 0, 0)
    l = WebLife
    kind = @kinds[@page]
    c.font.size = 22
    c.draw_text(0, 0, 608, 28, "书目　#{l.book_title || '识字'}（学识#{l.book_level}级）　读通#{l.books_done}/#{l::BOOKS.size}本　今天还能读#{[l.eyes_max - l.eyes_used, 0].max}章", 1)
    c.font.size = 20
    c.draw_text(0, 40, 608, 28, "← #{l::BOOK_KINDS[kind]}（#{@page + 1}/#{@kinds.size}） →", 1)
    c.font.size = 18
    l::BOOKS.values.select { |b| b[:kind] == kind }.each_with_index do |b, i|
      y = 84 + i * 32
      read = l.books_read[b[:id]].to_i
      if read > 0 || $game_party.item_number(b[:id]) > 0
        c.draw_text(40, y, 200, 28, "《#{b[:name]}》")
        c.draw_text(260, y, 160, 28, l.book_done?(b[:id]) ? '读通了' : "#{read}/#{b[:chapters]}章")
      else
        c.draw_text(40, y, 200, 28, '？？？')
      end
    end
    c.font.size = 16
    c.draw_text(0, 424, 608, 24, '左右键翻页，确定或取消返回', 1)
  end
end

#--------------------------------------------------------------------------
# 入行与书的来源
#--------------------------------------------------------------------------
module WebLife
  CLASSIC_SHELF = [83, 84, 85, 86, 87]
  BOOKSTALL = [90, 91, 92, 93, 95, 96, 97, 98, 99, 100]
  RARE_BOOKS = [94, 101]

  class << self
    def enter_scholar
      set_flag(:scholar)
      $game_party.gain_item(102, 1)
      $game_party.gain_item(83, 1)
    end

    def yijing_due? = scholar? && book_level >= 6 && !flag?(:yijing)

    def give_yijing
      set_flag(:yijing)
      $game_party.gain_item(88, 1)
    end

    def rare_stock
      RARE_BOOKS.select { |id| $game_party.item_number(id) == 0 && !book_done?(id) }
    end
  end
end

WebMod.edit 9 do |m|
  m.event 10, 4, name: '书架', tile: 763 do |c|
    c.if_variable(48, 0) do
      c.text '满满一架子书。可惜你一个字也不认识。（先跟顾先生学读书识字）'
    end.else do
      c.if_script('!WebLife.scholar?') do
        c.text '小书童跑过来：“先生说了，学过识字的，就能进书房看书。不过书可不白借，要买回去自己读。”'
        c.text '“这本《三字经》先生送你。这个小本子拿着，读过哪本、读到哪儿，都记在上头。”'
        c.script 'WebLife.enter_scholar'
        c.text '得到了三字经、书目！（在物品栏里打开书就能读，一次一章）'
      end.else do
        c.if_script('WebLife.yijing_due?') do
          c.text '顾先生踱进书房，看了看你案头的书，点点头：“读书读到这个份上，可以看看这个了。”'
          c.script 'WebLife.give_yijing'
          c.text '顾先生把一本批满了小字的《易经》递给你。（得到易经）'
        end
        c.text '书架上摆着蒙学和经书，书童在一旁磨墨。'
        c.script 'WebMod.open_shop(WebLife::CLASSIC_SHELF.map { |i| [:item, i] })'
      end
    end
  end
end

WebMod.edit 15 do |m|
  m.npc 6, 17, name: '书摊老板', tile: 885,
        look: { age: 5, level: 0, attack: 0, items: '长衫', text: '一个戴着瓜皮帽的老头，守着一摊旧书，见谁都说“开卷有益”。' },
        shop: WebLife::BOOKSTALL.map { |i| [:item, i] } + [[:armor, 116], [:armor, 118]] do |c|
    c.one_of '开卷有益，开卷有益。', '话本看得最快，兵书最难啃。', '杂学也是学问，本草纲目读通了，草药自己就会用。'
  end
end

WebJianghu::PEDDLER << [:item, 89]

WebEncounter.add 30, '落魄书生', show: { tile: 869, stay: true }, where: %i[town suburb], weight: 2, cooldown: 5,
                 if: -> { WebLife.scholar? && !WebLife.rare_stock.empty? } do |c|
  c.text '路边蹲着个衣衫褴褛的书生，面前摊着几本旧书：“赶考的盘缠花光了……这几本祖传的书，贱卖了，贱卖了。”'
  c.choices(%w[看看书 走开]) do |i|
    if i == 0
      c.script 'WebMod.open_shop(WebLife.rare_stock.map { |id| [:item, id] })'
    else
      c.text '书生叹了口气，把书往怀里拢了拢。'
    end
  end
end

#--------------------------------------------------------------------------
# 代写：商业街代书桌
#--------------------------------------------------------------------------
module WebLife
  # [键, 文书, 客人, 题目（一行以内）, [对的措辞, 错的, 错的], 基础报酬, 条件]
  WRITS = [
    [:home,     '家书', '一个在镇上做工的小伙子，想给乡下的爹娘写封家书。', '开头怎么称呼？', %w[父母亲大人膝下 吾儿知悉 仁兄大人台鉴], 40, nil],
    [:suit,     '状纸', '赵老汉的地被邻居占了一垄，要写状纸告到衙门。', '状纸怎么写？', %w[据实写明地界 骂他祖宗十八代 越长越好], 80, nil],
    [:debt,     '借据', '两个商人借银子，请你当场写一张借据。', '借据要写明什么？', %w[数目日期和中人 只写借钱若干 写首诗助兴], 60, nil],
    [:epitaph,  '墓志', '张家老太爷过世了，孝子请你写墓志。', '用什么语气？', %w[庄重平实 喜气洋洋 诙谐打趣], 120, nil],
    [:sign,     '招牌', '豆腐店新漆了门脸，请你题块招牌。', '题什么字？', %w[豆香满堂 刀枪不入 龙行虎步], 80, nil],
    [:couplet1, '春联', '米铺老板要贴春联，上联是“生意兴隆通四海”。', '下联对什么？', %w[财源茂盛达三江 一帆风顺年年好 万事如意步步高], 60, :winter],
    [:couplet2, '春联', '铁匠要贴春联，上联是“红炉炼就千钧铁”。', '下联对什么？', %w[巧手锤成百炼钢 打铁还需自身硬 家和万事永兴旺], 60, :winter],
    [:love,     '情书', '一个书生红着脸，求你替他写封情书。', '情书怎么写？', %w[含蓄引一句诗 直接问彩礼 抄一段兵法], 100, :poem],
  ]
  WANG_LETTERS = 5
  WRITES_PER_DAY = 3

  class << self
    def wang = client(:wang)

    def writes_today
      d, n = data[:writes]
      d == day ? n.to_i : 0
    end

    # 坐下等客：变量 9 = 1 来了客人、2 今天没人了
    def start_write
      if writes_today >= WRITES_PER_DAY
        $game_variables[9] = 2
        return
      end
      data[:writes] = [day, writes_today + 1]
      if wang[:favor] < WANG_LETTERS && rand(100) < 35
        @writ = [:wang, '家书', nil, '开头怎么写？', %w[吾儿知悉 父母亲大人膝下 足下], 50, nil]
      else
        pool = WRITS.select do |*, cond|
          cond.nil? || (cond == :winter && season == 3) || (cond == :poem && book_done?(87))
        end
        @writ = pool.sample
      end
      $game_variables[9] = 1
    end

    def no_client_text
      '今天来写信的人都打发走了，砚台也干了。明天再来吧。'
    end

    def client_text
      return @writ[2] unless @writ[0] == :wang
      n = wang[:favor] + 1
      "王大娘又来了，手里攥着一包碎银子：“先生，再给我儿写封信。他在边关当兵，这是第#{n}封了……”"
    end

    def writ_question
      WebMod.choice_labels = @writ[4].shuffle
      @writ_answer = WebMod.choice_labels.index(@writ[4][0])
      @writ[3]
    end

    def write(i)
      key, kind, _, _, words, base = @writ
      right = i == @writ_answer
      pay = (base * (1 + book_level * 0.15) * (right ? 1 : 0.4) * (1 + WebGear.value(:write_pay))).to_i
      $game_party.gain_gold(pay)
      gain_book_skill(right ? 3 : 1)
      pass_time(2)
      text = right ? "#{kind}写好了，客人捧着看了又看，连声道谢，付了#{pay}两。" : "客人看了直皱眉：“这……怎么是这么写的？”只给了#{pay}两。（该写“#{words[0]}”）"
      text += wang_progress if key == :wang
      text
    end

    # 王大娘的信：写满五封，儿子回来了
    def wang_progress
      wang[:favor] += 1
      case wang[:favor]
      when 2 then '王大娘抹着眼泪：“他回信了，说边关冷，让我别惦记。”'
      when 4 then '王大娘笑得合不拢嘴：“他说打了胜仗，过些日子就能回来了！”'
      when WANG_LETTERS
        $game_party.gain_armor(117, 1)
        '没过几天，一个晒得黝黑的后生找到代书桌前：“您就是给我娘写信的先生？这些年多亏了您。”' \
          '他解下腰间一块玉佩塞给你：“这是我在边关立功得的，您收下。”（得到玉佩）'
      else ''
      end
    end
  end
end

WebMod.edit 15 do |m|
  m.event 9, 17, name: '代书桌', tile: 645 do |c|
    c.if_script('WebLife.scholar?') do
      c.script 'WebLife.start_write'
      c.if_variable(9, 2) do
        c.say 'WebLife.no_client_text'
      end.else do
        c.say 'WebLife.client_text'
        c.say 'WebLife.writ_question'
        c.choices(%w[{0} {1} {2}]) { |i| c.say "WebLife.write(#{i})" }
      end
    end.else do
      c.text '一张空着的代书桌，笔墨纸砚都摆好了。上面压着一张字条：“识文断字者，可在此代人书写。”（先到顾先生的私塾书房看看）'
    end
  end
end

#--------------------------------------------------------------------------
# 书生套（050 里原有的书生套：描金折扇、方巾、儒衫，这里加三件，套装定义也在 050）
#--------------------------------------------------------------------------
WebEquip.armor 116, '云头履', :鞋, 4, 300, '鞋头翘起一朵云，走路斯斯文文'
WebEquip.armor 117, '玉佩', :腰带, 6, 1200, '王大娘的儿子在边关立功得的玉佩', str: 1
WebEquip.armor 118, '书箱', :披风, 3, 400, '竹编的书箱，背着赶路、赶考都用得着'
