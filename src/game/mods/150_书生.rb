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
    c.draw_text(0, 0, 608, 28, "书目　#{l.rank_name ? l.rank_name + '　' : ''}#{l.book_title || '识字'}（学识#{l.book_level}级）　读通#{l.books_done}/#{l::BOOKS.size}本　今天还能读#{[l.eyes_max - l.eyes_used, 0].max}章", 1)
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

    def yijing_due? = scholar? && book_level >= 6 && !flag?(:yijing) && !$game_switches[153] && ban_stage != :informed

    def give_yijing
      set_flag(:yijing)
      $game_party.gain_item(88, 1)
    end

    def rare_stock
      pool = RARE_BOOKS + (data[:writ_total].to_i >= BRUSH_WRITS ? [105] : [])
      pool.select { |id| $game_party.item_number(id) == 0 && !book_done?(id) }
    end

    def bookstall_goods
      ids = BOOKSTALL + (ban_stage == :spread || ban[:copied] ? [104] : [])
      ids.map { |i| [:item, i] } + [[:armor, 116], [:armor, 118]]
    end
  end
end

# 书架：入行；之后按顺序看有没有剧情（禁书、笔阵图、易经），再开书店
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
        WebLife.shelf_story(c)
        c.text '书架上摆着蒙学和经书，书童在一旁磨墨。'
        c.script 'WebMod.open_shop(WebLife::CLASSIC_SHELF.map { |i| [:item, i] })'
      end
    end
  end
end

WebMod.edit 15 do |m|
  m.npc 6, 17, name: '书摊老板', tile: 885,
        look: { age: 5, level: 0, attack: 0, items: '长衫', text: '一个戴着瓜皮帽的老头，守着一摊旧书，见谁都说“开卷有益”。' },
        shop: lambda { |c| c.script 'WebMod.open_shop(WebLife.bookstall_goods)' } do |c|
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
      pay = (base * (1 + book_level * 0.15) * (right ? 1 : 0.4) * (1 + WebGear.value(:write_pay)) * rank_rate).to_i
      $game_party.gain_gold(pay)
      gain_book_skill(right ? 3 : 1)
      data[:writ_total] = data[:writ_total].to_i + 1
      pass_time(2)
      up = train(BRUSH_ART, right ? 3 : 1)
      text = right ? "#{kind}写好了，客人捧着看了又看，连声道谢，付了#{pay}两。" : "客人看了直皱眉：“这……怎么是这么写的？”只给了#{pay}两。（该写“#{words[0]}”）"
      text += "笔锋一转之间，你对一阳书指又有了新的领悟！（#{up}级）" if up
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

#==========================================================================
# 第二批：一阳书指、科举、禁书
#--------------------------------------------------------------------------
#  一阳书指（拳脚 62，基础基本拳脚）：致敬朱子柳把书法化进一阳指。代写满十五回后，顾先生（或落魄书生）给《笔阵图》，
#        读通就会。之后代写时按原版学武规则长进度（同钓鱼、砍柴练功）。
#        绝招“笔走龙蛇”（60 级，三连指，可能点中穴道），“力透纸背”（120 级，五连指；禁书一事护住顾先生的才传）。
#  科举：衙门刘师爷主持，每年秋天开考一次。县试（学识 3 级，报名 100 两）五题对三题中秀才；
#        乡试（秀才、学识 7 级，报名 500 两）五题对四题中举人（有顾先生的荐书，对三题就行）。
#        秀才代写报酬 ×1.3；举人 ×1.6，每季到师爷那儿领三百两廪银。
#  禁书：学识 5 级、读通六本书以后，顾先生说起刘师爷在查禁书，他写的《日知录》书稿犯忌。二十天后官府来搜。
#    1 替先生藏书稿：带在身上，路上可能被捕快搜身（让搜、动手、或亮出六扇门腰牌）；躲过搜查后还给先生
#    2 抄一份传出去：连抄两天，得一本《日知录》，书摊也开始卖；先生自己烧了原稿，官府扑空；你的通缉值 +1
#    3 告发：向刘师爷告发，得两千两、通缉值清零、道德 −10；先生被带走一个月
#    4 不管：到期官府搜出书稿，先生被带走一个月
#    护住先生的（1、2）：先生传“力透纸背”；藏书的还给你写一封荐书（乡试少答对一题）
#
#  编号：武功 62 一阳书指（进度变量 122）；绝招 35 笔走龙蛇、36 力透纸背；物品 103 日知录书稿、104 日知录、105 笔阵图；
#        开关 153 顾先生被带走；奇遇 31 捕快搜身
#==========================================================================
module WebLife
  BRUSH_ART = 62
  BRUSH_WRITS = 15
  BAN_DAYS = 20
  AWAY_DAYS = 30
  RANKS = [nil, '秀才', '举人']
end

WebLife.book 104, '日知录', :classic, 6, 800, '顾先生的书，天下兴亡，匹夫有责', [:moral, 5, 500],
  [['「天下兴亡」下一句？', %w[匹夫有责 在于君王 自有天命]], ['顾先生说读书人要？', %w[经世致用 只读圣贤书 闭门不出]]]
WebLife.book 105, '笔阵图', :misc, 4, 3000, '卫夫人讲书法笔势的书，书页边上画满了指法', [:brush],
  [['这本书相传是谁写的？', %w[卫夫人 王羲之 颜真卿]], ['「点」如什么？', %w[高峰坠石 千里阵云 万岁枯藤]]]
WebMod.item 103, like: 21, name: '日知录书稿', price: 0, description: '顾先生亲笔的书稿，字迹密密麻麻。被官府搜到就是大祸'

#--------------------------------------------------------------------------
# 一阳书指
#--------------------------------------------------------------------------
WebSkill.add_skill 62, WebSkill::FIST, 40
WebMod.variable_name 62, '一阳书指'
WebSkill.attack_words 62, [
  [0,   '%{user}食指一点，如写“永”字的侧点，点向%{objector}的%{sp}', 25, 32, 4],
  [0,   '%{user}手指一横，如笔走横画，划向%{objector}的%{sp}', 25, 30, 4],
  [15,  '%{user}一竖直下，指力如悬针，刺向%{objector}的%{sp}', 40, 32, 4],
  [30,  '%{user}手腕一翻，一撇一捺，指风交错，罩住%{objector}的%{sp}', 55, 31, 3],
  [50,  '%{user}指走草书，一气呵成，连点%{objector}身上三处大穴', 75, 33, 4],
  [80,  '%{user}以指代笔，凌空写了个“剑”字，笔划间尽是剑意，直逼%{objector}', 100, 34, 4],
  [120, '%{user}一指点出，正是一阳指的功夫，一缕劲风嗤嗤作响，射向%{objector}的%{sp}', 130, 35, 4],
]
WebMod.skill 35, like: 28, name: '笔走龙蛇', sp_cost: 400, description: '以指作笔，三笔连环，可能点中穴道'
WebMod.skill 36, like: 28, name: '力透纸背', sp_cost: 700, description: '五指连书，一笔重过一笔'
WebSkill.perform 62, 35, 36
WebSkill.requirement 35, [[29, 62], [62, 60], [40, 60]]
WebSkill.requirement 36, [[29, 62], [62, 120], [40, 120]]
WebSkill.combo 35, moves_of: 62, times: 3, stun: { state: 1, text: '%{objector}被点中了穴道，一时动弹不得！' }
WebSkill.combo 36, moves_of: 62, times: 5
WebSkill.skill_words 35, ['%{user}一指凌空，龙飞凤舞，像在%{objector}身上写一幅狂草——笔走龙蛇！']
WebSkill.skill_words 36, ['%{user}屏息凝神，五指如握千钧之笔，一笔一划都透出纸背，向%{objector}写去！']

alias __brush_study_skill study_skill
def study_skill
  __brush_study_skill
  $game_party.actors[0].forget_skill(36) unless WebLife.flag?(:lituo)
end

#--------------------------------------------------------------------------
# 功名、禁书、笔阵图的规则
#--------------------------------------------------------------------------
module WebLife
  class << self
    # ---- 功名
    def rank = data[:rank].to_i
    def rank_name = RANKS[rank]
    def rank_rate = [1, 1.3, 1.6][rank]
    def year = ticks / 3000

    def exam_kind = rank == 0 ? '县试' : '乡试'
    def exam_fee = rank == 0 ? 100 : 500
    def exam_need = rank == 0 ? 3 : (flag?(:recommend) ? 3 : 4)

    def exam_ready?
      rank < 2 && book_level >= (rank == 0 ? 3 : 7)
    end

    def exam_open?
      exam_ready? && season == 2 && data[:exam_year] != year
    end

    def exam_info
      return '“举人老爷，今年的廪银可领过了？”师爷满脸堆笑。' if rank == 2
      need = rank == 0 ? 3 : 7
      return "“#{exam_kind}要学问扎实的人去考，学识#{need}级再来吧。”" unless exam_ready?
      return '“今年的秋闱你已经考过了，明年秋天再来。”' if data[:exam_year] == year
      "“#{exam_kind}每年秋天开考，到时候来报名，报名费#{exam_fee}两。”"
    end

    def exam_pool
      base = BOOKS.values.select { |b| b[:kind] == :classic }.flat_map { |b| b[:quiz] }
      rank == 0 ? base : POLICY + BOOKS[88][:quiz] + BOOKS[89][:quiz] + BOOKS[104][:quiz]
    end

    def exam_begin
      $game_party.lose_gold(exam_fee)
      data[:exam_year] = year
      @exam = exam_pool.sample(5)
      @exam_right = 0
      @exam_i = 0
    end

    def exam_question
      q = @exam[@exam_i]
      WebMod.choice_labels = q[1].shuffle
      @exam_answer = WebMod.choice_labels.index(q[1][0])
      "第#{@exam_i + 1}题：#{q[0]}"
    end

    def exam_answer(i)
      @exam_right += 1 if i == @exam_answer
      @exam_i += 1
    end

    def exam_result
      pass_time(8)
      if @exam_right >= exam_need
        data[:rank] = rank + 1
        gain_book_skill(10)
        data[:stipend] = season_index if rank == 2
        "五题答对#{@exam_right}题。放榜那天，榜上赫然写着你的名字——你中了#{rank_name}！" \
          "#{rank == 1 ? '（代写报酬提高三成）' : '（代写报酬提高六成，每季可到师爷那儿领三百两廪银）'}"
      else
        "五题只答对#{@exam_right}题，要对#{exam_need}题才行。放榜那天，你在榜上从头找到尾……名落孙山。明年再来吧。"
      end
    end

    def season_index = ticks / 750

    def stipend_due? = rank == 2 && data[:stipend].to_i < season_index

    def take_stipend
      n = season_index - data[:stipend].to_i
      data[:stipend] = season_index
      $game_party.gain_gold(300 * n)
      "师爷点出#{300 * n}两廪银：“举人老爷收好。”"
    end

    # ---- 禁书
    def ban
      data[:ban] ||= {}
    end

    def ban_stage = ban[:stage]

    def ban_due?
      ban_stage.nil? && book_level >= 5 && books_done >= 6 && !$game_switches[153]
    end

    def ban_start
      ban[:stage] = :search
      ban[:day] = day
    end

    def ban_days_left = [ban[:day].to_i + BAN_DAYS - day, 0].max

    def ban_hint
      "顾先生压低声音：“书稿的事……刘师爷说#{ban_days_left}天后来搜。”"
    end

    def ban_carry
      ban[:stage] = :carry
      $game_party.gain_item(103, 1)
    end

    def ban_copy
      ban[:stage] = :copied
      ban[:copied] = true
      pass_time(16)
      $game_party.gain_item(104, 1)
      "你在书房里点着灯，整整抄了两天两夜，手腕都抄肿了。（得到日知录）顾先生翻着你的抄本，眼圈红了：“好，好……书在人间，就烧不掉了。”"
    end

    def ban_inform
      ban[:stage] = :informed
      take_away
      $game_party.gain_gold(2000)
      $game_variables[164] = 0
      WebMod.gain_morality(-10)
      text = '刘师爷眼睛一亮，当即带着捕快去了私塾。不一会儿，顾先生就被押着走过了街口。师爷赏了你两千两，还把你案底上的事一笔勾销了。（通缉值清零，道德−10）'
      text += '周铁总捕听说后，也托人捎来一句“办得好”。' if $game_switches[117]
      text
    end

    def take_away
      $game_switches[153] = true
      ban[:back] = day + AWAY_DAYS
      $game_map.need_refresh = true
    end

    # 搜身：交出书稿，等于书稿落到官府手里
    def ban_seized
      $game_party.lose_item(103, $game_party.item_number(103))
      ban[:stage] = :seized
      take_away
    end

    # 进出地图时检查：到期搜查；先生被带走一个月后回来
    def ban_tick
      if %i[search carry copied].include?(ban_stage) && ban_days_left <= 0
        case ban_stage
        when :search then ban[:stage] = :ignored; take_away
        when :carry then ban[:stage] = :searched
        when :copied then ban[:stage] = :spread
        end
      end
      if $game_switches[153] && ban[:back] && day >= ban[:back]
        $game_switches[153] = false
        ban[:back] = nil
      end
    end

    def ban_reward_due?
      (ban_stage == :searched && $game_party.item_number(103) > 0) || (ban_stage == :spread && !flag?(:lituo))
    end

    def ban_reward
      text = if ban_stage == :searched
               $game_party.lose_item(103, 1)
               ban[:stage] = :hidden
               set_flag(:recommend)
               '顾先生接过书稿，摩挲了半天：“官府翻遍了私塾，一个字也没找到。多亏了你。”他另写了一封荐书：“去考乡试，带上它。”'
             else
               '顾先生笑道：“原稿我烧了，官府扑了个空。可书已经在外头传开了——这把火，是他们烧不灭的。”'
             end
      set_flag(:lituo)
      study_skill
      note = $game_variables[BRUSH_ART] > 0 ? '' : '先生又叮嘱：“这一招要会一阳书指才使得出，代写多了，我送你一本笔阵图。”'
      "#{text}#{note}（学会了“力透纸背”：一阳书指 120 级、基本拳脚 120 级可用）"
    end

    def ban_ended_line
      case ban_stage
      when :informed then '书童躲着你，小声嘀咕：“就是他……”'
      when :ignored, :seized then '书童红着眼睛：“先生的书稿被官府搜走烧了……”'
      else ''
      end
    end

    # ---- 笔阵图：代写满十五回，顾先生送
    def brush_due? = scholar? && data[:writ_total].to_i >= BRUSH_WRITS && !flag?(:brush) && !$game_switches[153] && ban_stage != :informed

    def give_brush
      set_flag(:brush)
      $game_party.gain_item(105, 1)
    end
  end

  # 乡试的策论题
  POLICY = [
    ['治水之道，贵在？', %w[疏导 堵截 祭河神]],
    ['「民为贵，社稷次之」君？', %w[为轻 为重 为先]],
    ['「苛政猛于」什么？', %w[虎也 狼也 火也]],
    ['荒年赈灾，先当？', %w[开仓放粮 加征赋税 闭城自守]],
    ['「先天下之忧而忧」下句？', %w[后天下之乐而乐 与民同乐 乐在其中]],
    ['「水能载舟」下一句？', %w[亦能覆舟 亦能行舟 舟行千里]],
    ['「工欲善其事」下一句？', %w[必先利其器 必先正其心 必先修其身]],
    ['「温故而知新」下一句？', %w[可以为师矣 学而不厌 不亦乐乎]],
    ['「路漫漫其修远兮」下句？', %w[吾将上下而求索 吾将独善其身 长路漫漫兮]],
  ]
end

# 读通笔阵图：学会一阳书指（读书收获里加一种）
module WebLife
  class << self
    alias __brush_book_reward book_reward
    def book_reward(b)
      return __brush_book_reward(b) unless b[:reward][0] == :brush
      gain_book_skill(5)
      return '笔阵图你早已烂熟于心。' if $game_variables[BRUSH_ART] > 0
      $game_variables[BRUSH_ART] = 1
      '你照着书页边上的指法比划，以指作笔，点、横、竖、撇……竟是一套指上功夫！（学会了一阳书指：拳脚，空手启用；代写时功夫会跟着长）'
    end
  end
end

class Game_Map
  alias __ban_setup setup
  def setup(map_id)
    WebLife.ban_tick if $game_system
    __ban_setup(map_id)
  end
end

#--------------------------------------------------------------------------
# 书架上的剧情（150 前半的书架事件调用）：禁书、笔阵图、易经
#--------------------------------------------------------------------------
module WebLife
  def self.shelf_story(c)
    c.if_switch(153) do
      c.text '顾先生的座位空着。书童说，先生被衙门带走了，要过些日子才能回来。'
    end.else do
      c.if_script('WebLife.ban_due?') do
        c.text '顾先生合上门，从书箱底下取出一叠书稿：“这是我写了半辈子的《日知录》。”'
        c.text '“衙门的刘师爷近来在查禁书，我这里头有些话，官府是不爱听的。他说二十天后来私塾搜查。”'
        c.script 'WebLife.ban_start'
        c.text '“我一把年纪，不怕什么。只可惜了这些字……”（替先生藏起书稿、抄一份传出去，或者向刘师爷告发——你自己拿主意）'
      end
      c.if_script('WebLife.ban_stage == :search') do
        c.say 'WebLife.ban_hint'
        c.choices(%w[替先生藏起来 抄一份传出去 先生保重]) do |i|
          case i
          when 0
            c.script 'WebLife.ban_carry'
            c.text '你把书稿贴身藏好。顾先生拱了拱手：“拜托了。等搜过了，再还给我。”（得到日知录书稿：路上小心捕快）'
          when 1
            c.say 'WebLife.ban_copy'
            c.reward wanted: 1
          else
            c.text '顾先生点点头，不再多说。'
          end
        end
      end
      c.if_script('WebLife.ban_reward_due?') do
        c.say 'WebLife.ban_reward'
      end
      c.if_script('WebLife.brush_due?') do
        c.text '顾先生拿起你代人写的一封家书，看了又看：“你这笔字，有筋骨了。”'
        c.text '“这本卫夫人的《笔阵图》送你。书页边上的指法，是我一位姓朱的故人画的——他说书法和武功，本是一回事。”'
        c.script 'WebLife.give_brush'
        c.text '得到了笔阵图！'
      end
      c.if_script('WebLife.yijing_due?') do
        c.text '顾先生踱进书房，看了看你案头的书，点点头：“读书读到这个份上，可以看看这个了。”'
        c.script 'WebLife.give_yijing'
        c.text '顾先生把一本批满了小字的《易经》递给你。（得到易经）'
      end
    end
    c.if_script('!WebLife.ban_ended_line.empty?') do
      c.say 'WebLife.ban_ended_line'
    end
  end
end

# 顾先生被带走时不在私塾（开关 153）
WebMod.edit 9 do |m|
  m.away '顾炎武', switch: 153
end

#--------------------------------------------------------------------------
# 刘师爷：衙门大堂。科举报名、廪银、禁书
#--------------------------------------------------------------------------
WebMod.edit 10 do |m|
  m.npc 11, 4, name: '刘师爷', tile: 876,
        look: { age: 4, level: 2, attack: 1, items: '长衫、折扇', text: '衙门的师爷，八字胡，一把折扇不离手。管着县里的文书、科举，还有查禁书。' } do |c|
    c.if_script('WebLife.ban_stage == :search || WebLife.ban_stage == :carry') do
      c.text '刘师爷摇着折扇：“最近上头查禁书查得紧。你是读书人，可听说镇上谁家藏着不该藏的书？”'
      c.choices(%w[告发顾炎武 不知道]) do |i|
        if i == 0
          c.if_script('WebLife.ban_stage == :carry') do
            c.text '你刚要开口，摸到怀里那叠书稿，又把话咽了回去。（书稿在你身上，告发不成）'
          end.else do
            c.say 'WebLife.ban_inform'
          end
        else
          c.text '“哼，知道了可要来报。”'
        end
      end
    end
    c.if_script('WebLife.stipend_due?') do
      c.say 'WebLife.take_stipend'
    end
    c.if_script('WebLife.exam_open?') do
      c.text '“今年秋闱开考了。要报名吗？”'
      c.choices(%w[报名应考 改天再来]) do |i|
        if i == 0
          c.if_script('$game_party.gold >= WebLife.exam_fee') do
            c.script 'WebLife.exam_begin'
            c.text '你领了号牌，进了考棚。一共五道题。'
            5.times do
              c.say 'WebLife.exam_question'
              c.choices(%w[{0} {1} {2}]) { |k| c.script "WebLife.exam_answer(#{k})" }
            end
            c.say 'WebLife.exam_result'
          end.else do
            c.text '“报名费都交不起，还考什么？”'
          end
        end
      end
    end.else do
      c.say 'WebLife.exam_info'
    end
  end
end

#--------------------------------------------------------------------------
# 奇遇 31 捕快搜身：身上带着日知录书稿时
#--------------------------------------------------------------------------
WebEncounter.add 31, '捕快搜身', combat: true, show: { tile: 845 }, where: %i[town suburb], weight: 8, cooldown: 2,
                 if: -> { WebLife.ban_stage == :carry && $game_party.item_number(103) > 0 } do |c|
  c.text '两个捕快拦住了你：“站住！刘师爷有令，读书人一律搜身！”'
  fight = lambda do
    c.fight(159,
      win: -> { c.text '捕快捂着脸跑了。这下你的案底上又多了一笔。'; c.reward wanted: 1 },
      escape: -> { c.text '你夺路而逃，书稿还在怀里。' },
      lose: -> { c.script 'WebLife.ban_seized'; c.text '你被按倒在地，书稿被搜了出去。捕快拿着它，一溜烟跑回了衙门……' })
  end
  c.if_switch(117) do
    c.choices(%w[亮出六扇门腰牌 让他搜 动手]) do |i|
      case i
      when 0 then c.text '捕快一看腰牌，立刻换了笑脸：“原来是六扇门的大人，小的有眼无珠！”'
      when 1 then c.script 'WebLife.ban_seized'; c.text '捕快从你怀里搜出了书稿：“好哇，果然有！”'
      else fight.call
      end
    end
  end.else do
    c.choices(%w[让他搜 动手]) do |i|
      if i == 0
        c.script 'WebLife.ban_seized'
        c.text '捕快从你怀里搜出了书稿：“好哇，果然有！”'
      else
        fight.call
      end
    end
  end
end
