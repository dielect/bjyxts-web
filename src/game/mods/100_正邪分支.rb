#==============================================================================
# ■ 正邪分支：血衣楼（设计见 docs/内容设计思路.md 2.2）
#------------------------------------------------------------------------------
#  血衣楼是一个暗杀组织：黑风寨是它在外面的爪牙，追杀温青的是它（染血书信落款的“黑风”就是它的暗号），
#  它的图谋是在舞林大会上刺杀武林名宿。经验 30 万起，三条路任选其一，互斥：
#
#  正道（六扇门）  20 血衣案：周捕头请你查案（道德 ≥ 96 或入了六扇门；有染血书信的多一段）
#                  22 血衣楼杀手：打赢掉血衣令残片，集齐 3 片拼出分舵位置（大地图西南的黑松林）
#                  分舵（新地图 52）：打败香主，救出镖师，得知楼主已去五指山
#                  五指山：截住血衣楼主 → 六扇门金牌，结局称号“天下名捕”
#  邪道（血衣楼）  21 血衣楼的请帖：杀一个镖头纳投名状（道德 < 160 或入伙黑风寨）
#                  24 暗杀委托：杀满 3 个目标，官府震怒
#                  25 六扇门总捕：打退总捕，楼主召你回分舵
#                  分舵：挑战楼主取而代之 → 血衣、血莲，结局称号“血衣楼主”；之后山贼见你就进贡
#  独行            两边的邀请都拒绝（道德在中间的两边都会来请）
#                  26 两头不讨好：两边轮番来找麻烦，打退 5 次
#                  27 独行侠：客栈的独行大侠来访 → 孤云佩，结局称号“独来独往”
#
#  编号：开关 142 正道 143 邪道 144 独行 145 主线完成 146 分舵已现 147/148 拒绝过正道 / 邪道 149 楼主去了五指山
#        变量 164 通缉值（作恶时增加，赏金猎人看它）165 主线阶段 166 计数（委托次数、独行打退次数）
#        敌人 154～159  物品 27 血衣令残片  防具 103～106  地图 52 血衣楼分舵
#==============================================================================
module WebRoute
  WANTED, STAGE, COUNT = 164, 165, 166
  GOOD, EVIL, ALONE, DONE, DEN, DECL_GOOD, DECL_EVIL, LORD = 142, 143, 144, 145, 146, 147, 148, 149
  START_EXP = 300_000
  TITLES = { good: '天下名捕', evil: '血衣楼主', alone: '独来独往' }

  module_function

  def sw(id) = $game_switches[id] == true
  def stage = $game_variables[STAGE].to_i
  def count = $game_variables[COUNT].to_i

  def route
    return :good if sw(GOOD)
    return :evil if sw(EVIL)
    return :alone if sw(ALONE)
    nil
  end

  def ready?
    route.nil? && $game_variables[19] >= START_EXP
  end

  def good_invite?
    ready? && !sw(DECL_GOOD) && !sw(119) && ($game_variables[160] >= 96 || sw(117))
  end

  def evil_invite?
    ready? && !sw(DECL_EVIL) && !sw(117) && ($game_variables[160] < 160 || sw(119))
  end

  # 拒绝一边的邀请；另一边也请不到你了（拒绝过，或者道德不合）时就走上独行
  def decline(side)
    $game_switches[side == :good ? DECL_GOOD : DECL_EVIL] = true
    $game_switches[ALONE] = true unless good_invite? || evil_invite?
  end

  # 邪道线被六扇门总捕追捕期间，赏金猎人不出现（总捕替代了他们）
  def hunted?
    route == :evil && stage == 2
  end

  # 镇上的人怕你：血衣楼主，或者通缉很重
  def feared?
    (route == :evil && sw(DONE)) || $game_variables[WANTED] >= 5
  end

  def hero?
    route == :good && sw(DONE)
  end

  # 结局称号（089 Scene_Finish）：走完一条路线时用路线称号
  def title_index(i)
    return i unless sw(DONE) && route
    $end_com.index(TITLES[route]) || i
  end
end
$end_com.push(*WebRoute::TITLES.values) unless $end_com.include?(WebRoute::TITLES[:good])   # 结局称号，接在原版 11 个后面

#--------------------------------------------------------------------------
# 敌人
#--------------------------------------------------------------------------
WebMod.enemy 154, name: '血衣楼杀手', tile: 846, like: 123, maxhp: 500, maxsp: 800, gold: 800,
             stats: NO_STYLE.merge(膂力: 26, 敏捷: 30, 悟性: 24, 根骨: 24, 武器: 2, 经验: 250000),
             skills: { 41 => 150, 46 => 160, 47 => 130, 45 => 120, 40 => 100 }
WebMod.enemy 155, name: '血衣楼香主', tile: 851, like: 124, maxhp: 650, maxsp: 1500, gold: 3000, elite: true,
             stats: NO_STYLE.merge(膂力: 30, 敏捷: 27, 悟性: 24, 根骨: 28, 武器: 11, 经验: 450000),
             skills: { 42 => 180, 47 => 160, 46 => 150, 45 => 160, 40 => 140 }
WebMod.enemy 156, name: '血衣楼主', tile: 873, like: 63, maxhp: 1200, maxsp: 4000, gold: 10000, elite: true,
             stats: NO_STYLE.merge(膂力: 32, 敏捷: 32, 悟性: 30, 根骨: 30, 武器: 18, 经验: 1500000),
             skills: { 41 => 240, 46 => 230, 47 => 230, 45 => 240, 40 => 200 }
WebMod.enemy 157, name: '镖头', tile: 845, like: 66, maxhp: 420, maxsp: 300, gold: 600,
             stats: NO_STYLE.merge(膂力: 26, 敏捷: 24, 根骨: 26, 武器: 8, 经验: 60000),
             skills: { 42 => 90, 47 => 80, 46 => 70, 40 => 70 }
WebMod.enemy 158, name: '六扇门总捕', tile: 879, like: 29, maxhp: 900, maxsp: 2500, gold: 2000, elite: true,
             stats: NO_STYLE.merge(膂力: 30, 敏捷: 30, 悟性: 28, 根骨: 30, 武器: 16, 经验: 1000000),
             skills: { 41 => 220, 46 => 200, 47 => 220, 45 => 200, 40 => 180 }
WebMod.enemy 159, name: '六扇门捕快', tile: 845, like: 5, maxhp: 450, maxsp: 600, gold: 500,
             stats: NO_STYLE.merge(膂力: 26, 敏捷: 26, 悟性: 24, 根骨: 26, 武器: 15, 经验: 200000),
             skills: { 41 => 140, 46 => 130, 47 => 140, 45 => 120, 40 => 110 }

#--------------------------------------------------------------------------
# 物品与装备
#--------------------------------------------------------------------------
WebMod.item 27, like: 19, name: '血衣令残片', description: '一角血红的令牌碎片，背面刻着半幅地图'
WebEquip.armor 103, '六扇门金牌', :头饰, 5, 0, '六扇门的金牌，天下名捕才有', fx: [[:power, ratio: 0.15, when: { good: 128 }, name: '正气'], [:disarm, chance: 10]]
WebEquip.armor 104, '血衣',       :盔甲, 45, 0, '血衣楼主的长袍，红得发黑', fx: [[:drain, ratio: 0.1], [:reduce, ratio: 0.1]]
WebEquip.armor 105, '血莲',       :头饰, 0, 0, '一朵血玉雕的莲花，戴着杀意难平', fx: [[:power, ratio: 0.3, name: '血莲'], [:self_hurt, pct: 2]]
WebEquip.armor 106, '孤云佩',     :头饰, 4, 0, '一块刻着孤云的玉佩，独行大侠所赠', fx: [[:dodge, chance: 8], [:reduce, ratio: 0.1]]

R = WebRoute

#--------------------------------------------------------------------------
# 20 血衣案（正道邀请）
#--------------------------------------------------------------------------
WebEncounter.add 20, '血衣案', where: %i[wild suburb town], weight: 6, cooldown: 2, if: -> { R.good_invite? } do |c|
  c.if_switch(117) do
    c.text '周铁捕头风尘仆仆地赶来：“少侠，出大事了。”'
  end.else do
    c.text '一个腰挂铁尺的中年汉子拦住你：“在下六扇门捕头周铁，久闻少侠侠名。”'
  end
  c.text '“近来江湖上接连有人被刺，死者身上都留着一角血红的衣襟——是血衣楼。”'
  c.text '“这伙人收钱杀人，连黑风寨都是他们养的狗。周某想请少侠助我查案。”'
  c.choices(%w[接下此案 不想卷进去]) do |i|
    if i == 0
      c.switch(R::GOOD)
      c.variable(R::STAGE, 1)
      c.text '“好！血衣楼的杀手常在野外截杀落单的人，他们身上带着血衣令。凑齐了，就能找到他们的分舵。”'
      c.if_has(:item, 25) do
        c.text '你想起那封染血的书信，取出来递给周铁。他只看了一眼，脸色就变了。'
        c.text '“这团黑风……是血衣楼的联络暗号！这信是从哪里来的？”你一时语塞。'
        c.text '周铁从信封夹层里抖出一角令牌碎片：“有了这个，就少了一片。”'
        c.lose(:item, 25)
        c.gain(:item, 27)
      end
    else
      c.script 'WebRoute.decline(:good)'
      c.text '“人各有志。”周铁拱拱手走了。'
      c.if_switch(R::ALONE) { c.text '你不打算替谁卖命。从今往后，独来独往。' }
    end
  end
end

#--------------------------------------------------------------------------
# 21 血衣楼的请帖（邪道邀请，要纳投名状）
#--------------------------------------------------------------------------
WebEncounter.add 21, '血衣楼的请帖', where: %i[wild suburb], weight: 6, cooldown: 2, if: -> { R.evil_invite? } do |c|
  c.text '一个戴斗笠的人从树后转出，把一张血红的帖子塞到你手里：“血衣楼请你喝杯酒。”'
  c.text '“楼主看中了你。不过入楼要纳投名状——前面山道上有一队镖车，镖头的命就是投名状。”'
  c.choices(%w[接帖 撕了帖子]) do |i|
    if i == 0
      c.text '你截住镖车，镖头横刀拦在车前：“什么人？”'
      c.fight(157, can_escape: false,
        killed: lambda {
          c.switch(R::EVIL)
          c.variable(R::STAGE, 1)
          c.reward morality: -10, wanted: 2
          c.text '斗笠人不知何时站在你身后，拍了拍你的肩：“从今天起，你是血衣楼的人了。有活儿，自会找你。”'
        },
        spared: -> { c.text '“楼里不要心软的人。”斗笠人冷冷说完，消失在林中。' },
        lose: -> { c.text '镖头一刀把你逼退，镖车扬长而去。林子里传来一声冷笑。' })
    else
      c.script 'WebRoute.decline(:evil)'
      c.text '你把帖子撕得粉碎。斗笠人看了你一眼，什么也没说，转身走了。'
      c.if_switch(R::ALONE) { c.text '你不打算替谁卖命。从今往后，独来独往。' }
    end
  end
end

#--------------------------------------------------------------------------
# 22 血衣楼杀手（正道：收集血衣令残片）
#--------------------------------------------------------------------------
WebEncounter.add 22, '血衣楼杀手', where: :wild, weight: 6, cooldown: 1,
                 if: -> { R.route == :good && R.stage == 1 } do |c|
  c.text '路边一个樵夫忽然扔下柴担，袖中寒光一闪——是血衣楼的杀手！'
  c.fight(154, loot: [[:item, 27]],
    win: lambda {
      c.if_has(:item, 27, 3) do
        c.lose(:item, 27, 3)
        c.text '三片血衣令拼在一起，背面是一幅小小的地图：大地图西南，黑松林深处。'
        c.variable(R::STAGE, 2)
        c.switch(R::DEN)
        c.text '血衣楼的分舵，就在那里。（失落的世界西南的黑松林）'
      end.else do
        c.text '你从杀手身上搜出一片血衣令。'
      end
    },
    escape: -> { c.text '你甩开了杀手。' },
    lose: -> { c.text '杀手一击得手，却没下死手，只冷笑一声：“楼主说了，留你一口气，回去告诉周铁。”' })
end

#--------------------------------------------------------------------------
# 24 暗杀委托  25 六扇门总捕（邪道）
#--------------------------------------------------------------------------
WebEncounter.add 24, '暗杀委托', where: %i[wild suburb], weight: 6, cooldown: 1,
                 if: -> { R.route == :evil && R.stage == 1 } do |c|
  c.text '斗笠人又来了，递给你一个蜡丸，里面是一张纸条。'
  c.one_of '“目标：威远镖局的镖头。三天后过野狼坡。”',
           '“目标：长风镖局的镖头，替一个盐商押银子。”',
           '“目标：顺义镖局的总镖头。有人出了三千两。”'
  c.fight(157,
    killed: lambda {
      c.gold(2000)
      c.variable(R::COUNT, 1, 1)
      c.reward morality: -5, wanted: 1
      c.text '事成之后，斗笠人送来两千两银子。'
      c.if_variable(R::COUNT, 3, 1) do
        c.variable(R::STAGE, 2)
        c.variable(R::COUNT, 0)
        c.text '接连几桩血案，官府震怒。听说六扇门总捕亲自出京，要拿你归案。'
      end
    },
    spared: -> { c.text '目标跪地求饶，你终究没有下手。委托算是砸了，斗笠人很不高兴。' },
    escape: -> { c.text '你没能得手。' },
    lose: -> { c.text '镖头比你想的硬，你只好先撤。' })
end

WebEncounter.add 25, '六扇门总捕', where: %i[wild suburb town], weight: 8, cooldown: 1,
                 if: -> { R.hunted? } do |c|
  c.text '十几个公差忽然从四面围上来，当中一人须发花白，目光如电。'
  c.text '“六扇门总捕在此。血衣楼的杀手，今天就跟我回去吧。”'
  c.fight(158,
    win: lambda {
      c.variable(R::STAGE, 3)
      c.switch(R::DEN)
      c.text '公差们抬着总捕撤走了。当晚，斗笠人捎来口信：“楼主请你回分舵一叙。”（失落的世界西南的黑松林）'
    },
    killed: -> { c.reward wanted: 3, morality: -10 },
    escape: -> { c.text '你冲出包围，躲进了山里。总捕不会善罢甘休的。' },
    lose: lambda {
      c.script '$game_party.lose_gold($game_party.gold/2)'
      c.text '你被铁链锁进大牢。几天后血衣楼花了大把银子把你赎了出来——总捕还在找你。'
    })
end

#--------------------------------------------------------------------------
# 26 两头不讨好  27 独行侠（独行）
#--------------------------------------------------------------------------
WebEncounter.add 26, '两头不讨好', where: %i[wild suburb], weight: 5, cooldown: 2,
                 if: -> { R.route == :alone && R.count < 5 && !R.sw(R::DONE) } do |c|
  after = lambda do
    c.variable(R::COUNT, 1, 1)
    c.if_variable(R::COUNT, 5, 1) { c.text '一来二去，血衣楼和六扇门都不敢再来惹你了。' }
  end
  c.random(2) do |i|
    if i == 0
      c.text '一个血衣楼的杀手拦住去路：“楼主说了，不为我用，便为我杀。”'
      c.fight(154, win: after, lose: -> { c.text '杀手冷笑一声，没有下杀手：“下回可就没这么便宜了。”' })
    else
      c.text '几个公差围上来：“你和血衣楼什么关系？跟我们回衙门问话！”'
      c.fight(159, win: after, lose: -> { c.script '$game_party.lose_gold($game_party.gold/3)'; c.text '你在衙门里关了两天，交了罚银才放出来。' })
    end
  end
end

WebEncounter.add 27, '独行侠', where: %i[wild suburb town], weight: 8, once: true,
                 if: -> { R.route == :alone && R.count >= 5 && !R.sw(R::DONE) } do |c|
  c.text '客栈里那位独行大侠背着手走来，上下打量你，点了点头。'
  c.text '“不投官府，不入黑道，两边都奈何不了你。好，好，像我年轻的时候。”'
  c.text '“这块孤云佩跟了我三十年。往后的路，你自己走。”'
  c.gain(:armor, 106)
  c.switch(R::DONE)
  c.reward pot: 1000
  c.text '得到了孤云佩！潜能增加了一千点。（结局称号：独来独往）'
end

#--------------------------------------------------------------------------
# 血衣楼分舵（新地图 52，地形复制商家堡大厅）
#--------------------------------------------------------------------------
WebMod.map 52, name: '血衣楼分舵', parent: 1, base: 30 do |m|
  m.door 9, 14, to: [1, 12, 25], dir: 2

  # 正道：香主守着分舵，镖师被绑在一边
  boss = m.event 9, 5, name: '血衣楼香主', tile: 851, switch: R::GOOD, variable: [R::STAGE, 2], once: true do |c|
    c.text '“周铁的走狗也敢找到这里？”香主抽出紫金刀，“既然来了，就别想活着出去！”'
    c.fight(155, can_escape: false,
      win: -> { c.done; c.reward exp: 2000, pot: 500 },
      lose: -> { c.text '你被打得退出了分舵。香主没有追出来。' })
  end
  m.event 6, 5, name: '被绑的镖师', tile: 845, switch: R::GOOD, variable: [R::STAGE, 2], once: true do |c|
    c.if_script("$game_self_switches[[52, #{boss.id}, 'A']]") do
      c.text '你割断绳子，镖师扯掉嘴里的布：“多谢少侠！我被关在这里，偷听到他们说话——”'
      c.text '“血衣楼主要在舞林大会上刺杀武林名宿！他已经动身去五指山了！”'
      c.variable(R::STAGE, 3)
      c.switch(R::LORD)
      c.gold(1000)
      c.done
      c.text '镖师塞给你一千两银子，连滚带爬地跑了。（血衣楼主去了五指山）'
    end.else do
      c.text '一个镖师被绑在柱子上，嘴里塞着布，冲你拼命使眼色——香主就在旁边。'
    end
  end

  # 邪道：楼主在上首等你
  m.event 9, 3, name: '血衣楼主', tile: 873, switch: R::EVIL, variable: [R::STAGE, 3], once: true do |c|
    c.text '上首坐着一个白面无须的人，一身红袍，红得发黑。'
    c.text '“打退了六扇门总捕，好本事。”楼主笑了笑，“我知道你想要什么——我这个位子。”'
    c.choices(%w[挑战楼主 告退]) do |i|
      if i == 0
        c.fight(156, can_escape: false,
          spared: -> { c.text '楼主跪在地上，双手捧起血衣和血莲：“楼主之位……是你的了。”' },
          killed: -> { c.text '你一剑结果了楼主。堂下的杀手们面面相觑，齐齐跪倒：“参见楼主！”' },
          win: lambda {
            c.gain(:armor, 104); c.gain(:armor, 105)
            c.variable(R::STAGE, 4)
            c.switch(R::DONE)
            c.reward exp: 5000, pot: 2000
            c.done
            c.text '得到了血衣、血莲！你成了血衣楼的新主人。（结局称号：血衣楼主）'
          },
          lose: -> { c.text '楼主一掌把你打下台阶：“还差得远。等你够格了，再来。”' })
      else
        c.text '“随时恭候。”'
      end
    end
  end
end

WebMod.edit 1 do |m|                                # 黑松林深处的入口，拼出地图（或楼主召见）后才进得去
  m.event 12, 26, name: '黑松林', trigger: 1 do |c|
    c.if_switch(R::DEN) do
      c.se 'Move'
      c.transfer(52, 9, 13, 8)
    end
  end
end

#--------------------------------------------------------------------------
# 正道决战：五指山，舞林大会入口旁
#--------------------------------------------------------------------------
WebMod.edit 24 do |m|
  m.event 12, 5, name: '血衣楼主', tile: 873, switch: [R::GOOD, R::LORD], once: true do |c|
    c.text '舞林大会的会场外，一个红袍人正混在人群里往里走。你一眼认出了他。'
    c.text '“又是周铁的人。”血衣楼主停下脚步，叹了口气，“你坏了我一桩大买卖。”'
    c.fight(156, can_escape: false,
      win: lambda {
        c.text '周铁带着公差赶到，把楼主押了下去。舞林大会照常开锣，没有人知道刚才发生了什么。'
        c.text '周铁郑重地把一块金牌交给你：“这是六扇门的金牌。从今往后，你就是天下名捕。”'
        c.gain(:armor, 103)
        c.variable(R::STAGE, 4)
        c.switch(R::DONE)
        c.reward exp: 5000, pot: 2000, morality: 10
        c.done
        c.text '得到了六扇门金牌！（结局称号：天下名捕）'
      },
      lose: -> { c.text '楼主一掌把你击退，却没有走，只是冷冷地盯着会场。他还在等机会。' })
  end
end
