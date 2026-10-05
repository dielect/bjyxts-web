#==============================================================================
# ■ 江湖奇遇：第一批（引擎见 src/game/web_encounters.rb）
#------------------------------------------------------------------------------
#  走在野外、郊外、镇上时随机遇到。同一件事，正派和邪派的选择不同，选择的后果会留到以后：
#
#    1 山贼劫道   野外    给钱 / 动手 / （邪派）入伙分赃。经验够了遇到的是山贼头目
#    2 重伤的剑客 野外    救他 / 搜身 / 走开 —— 只发生一次，决定温青日后是报恩还是寻仇
#    3 温青报恩   各处    救过他、又过了三段奇遇：赠秋水剑
#    4 温青寻仇   各处    搜过他、又过了三段奇遇：赔还书信银两，或者动手
#    5 武学残页   野外    捡到残页，集齐四页拼读，潜能大增
#    6 骰子摊     镇上    押大押小；眼尖的能看出庄家出千（揭穿 / 不动声色）
#    7 恶霸欺人   各处    （正派）路见不平
#    8 落单行商   野外    （邪派）拦路打劫
#    9 赏金猎人   野外郊外 通缉值 ≥ 2 或道德很低时，官府的人找上门来（正邪分支邪道线被六扇门总捕追捕期间不出现）
#   10 江湖传闻   镇上郊外 茶客闲聊：两处藏宝、珍珑棋局、老乞丐的线索
#
#  编号：敌人 145～149；物品 25、26；公共事件 27（使用武学残页）
#        变量 162 打败山贼头目的次数  163 行侠次数（恶霸、山贼，正派时）
#        开关 107 救了温青  108 搜了温青  109 老汉送过鞋  110/111 西北藏宝 听说/已取
#             112/113 五指山大石 听说/已取  114 听说珍珑棋局  115 听说老乞丐  116 得到过灌铅骰子  120 得到君子剑
#        通缉值是变量 164（作恶时增加），道德值 160。原版的变量 159“追杀数”是杀死的恶人数，不是通缉
#==============================================================================

#--------------------------------------------------------------------------
# 敌人
#--------------------------------------------------------------------------
NO_STYLE = { 拳脚: 0, 兵刃: 0, 轻功: 0, 内功: 0, 招架: 0 }    # 不启用门派武功，只用基本功夫

WebMod.enemy 145, name: '山贼', tile: 841, like: 123, maxhp: 340, maxsp: 0, gold: 120,
             stats: NO_STYLE.merge(膂力: 24, 敏捷: 22, 悟性: 18, 根骨: 22, 武器: 8, 经验: 8000),
             skills: { 42 => 40, 47 => 30, 40 => 30, 46 => 30 }
WebMod.enemy 146, name: '山贼头目', tile: 882, like: 124, maxhp: 460, maxsp: 500, gold: 900,
             stats: NO_STYLE.merge(膂力: 27, 敏捷: 24, 悟性: 20, 根骨: 26, 武器: 10, 经验: 90000),
             skills: { 42 => 100, 47 => 90, 46 => 80, 40 => 80, 45 => 80 }
WebMod.enemy 147, name: '温青', tile: 879, like: 8, maxhp: 520, maxsp: 900, gold: 300,
             stats: NO_STYLE.merge(膂力: 25, 敏捷: 27, 悟性: 26, 根骨: 25, 武器: 34, 经验: 120000),
             skills: { 41 => 120, 47 => 100, 46 => 110, 45 => 100, 40 => 80 }
WebMod.enemy 148, name: '恶霸', tile: 884, like: 122, maxhp: 360, gold: 400,
             stats: NO_STYLE.merge(膂力: 28, 敏捷: 20, 经验: 20000),
             skills: { 40 => 60, 47 => 50, 46 => 40 }
WebMod.enemy 149, name: '赏金猎人', tile: 845, like: 5, maxhp: 480, maxsp: 600, gold: 600,
             stats: NO_STYLE.merge(膂力: 26, 敏捷: 26, 悟性: 24, 根骨: 27, 武器: 21, 经验: 100000),
             skills: { 44 => 110, 47 => 90, 46 => 90, 45 => 80, 40 => 80 }

#--------------------------------------------------------------------------
# 物品
#--------------------------------------------------------------------------
WebMod.item 25, like: 22, name: '染血的书信',
            description: '一封沾着血迹的书信，落款画着一团黑风，字迹潦草，看不太懂'
WebMod.item 26, like: 12, name: '武学残页', price: 150, consumable: false, common_event_id: 27,
            description: '一页发黄的残页，画着人形和经脉。集齐四页可以拼读'

WebMod.common_event 27, '使用-武学残页' do |c|
  c.if_has(:item, 26, 4) do
    c.lose(:item, 26, 4)
    c.text '你把四页残页拼在一起，对着图形比划了半天，忽然豁然开朗——原来是这么回事！'
    c.reward pot: 300
    c.text '潜能增加了三百点。'
  end.else do
    c.text '残页上的图形支离破碎，看不出头绪。凑齐四页再说。'
  end
end

#--------------------------------------------------------------------------
# 奇遇里用到的小工具
#--------------------------------------------------------------------------
module WebJianghu
  module_function

  # 骰子摊：能不能看出庄家出千（敏捷天赋越高越容易），带着灌铅骰子的胜算
  def sharp_eyes?
    rand(100) < 15 + [$game_variables[12] - 20, 0].max * 5
  end

  def dice_win?
    rand(100) < (WebGear.value(:dice) > 0 ? 70 : 42)
  end

  # 赏金猎人开的价：每桩案子五百两
  def bounty
    [$game_variables[164], 1].max * 500
  end
end

#--------------------------------------------------------------------------
# 1 山贼劫道
#--------------------------------------------------------------------------
bandit = lambda do |c, enemy, toll, loot, share, exp, pot|
  pay = lambda do
    c.if_gold(toll) do
      c.gold(-toll)
      c.text '山贼掂了掂钱袋，嘿嘿一笑，让开了路。'
    end.else do
      c.script '$game_party.lose_gold($game_party.gold)'
      c.text '山贼把你从头搜到脚，只摸出几个铜板，啐了一口：“穷鬼，滚吧！”'
    end
  end
  fight = lambda do
    c.fight(enemy, loot: loot,
      win: lambda {
        c.reward exp: exp, pot: pot
        c.variable(162, 1, 1) if enemy == 146         # 打败山贼头目的次数（黑风寨，见 080）
        c.if_good { c.variable(163, 1, 1) }            # 行侠次数（捕头相邀，见 080）
      },
      killed: -> { c.text '为民除害，路过的乡亲们都松了口气。'; c.reward morality: 2 },
      spared: -> { c.text '山贼磕头如捣蒜，连滚带爬地逃进了林子。' },
      escape: -> { c.text '你拔腿就跑，身后传来一阵哄笑。' },
      lose: -> { c.script '$game_party.lose_gold($game_party.gold/2)'; c.text '山贼搜走了你身上一半的银子，扬长而去。' })
  end
  c.if_good do
    c.choices(%w[破财消灾 拔刀相向]) { |i| i == 0 ? pay.call : fight.call }
  end.else do
    c.choices(%w[破财消灾 拔刀相向 入伙分赃]) do |i|
      case i
      when 0 then pay.call
      when 1 then fight.call
      when 2
        c.text '山贼上下打量你：“哟，也是道上的？前头有支商队，干完这一票，见者有份！”'
        c.text '你跟着他们劫了一支商队，分到一大包银子。'
        c.gold(share)
        c.reward morality: -5, wanted: 1
      end
    end
  end
end

WebEncounter.add 1, '山贼劫道', combat: true, show: { tile: 841 }, where: :wild, weight: -> { (WebEncounter.gold >= 5000 ? 4 : 2) * (WebEncounter.mountain? ? 2 : 1) }, cooldown: 4 do |c|
  c.if_script('WebRoute.route == :evil && WebRoute.sw(WebRoute::DONE)') do      # 血衣楼主（100_正邪分支.rb）
    c.text '一伙山贼从林子里窜出来，看清是你，扑通扑通跪了一地：“楼、楼主饶命！小的们有眼无珠……”'
    c.text '为首的捧上一包银子：“这点孝敬，不成敬意！”'
    c.gold(500)
  end.else do
  c.if_variable(19, 150000, 1) do
    c.text '一声呼哨，林子里窜出一伙山贼，为首的独眼汉子扛着一口鬼头刀：“此山是我开，此树是我栽！”'
    bandit.call(c, 146, 1000, [[:weapon, 35, 1, 15], [:armor, 34, 1, 30], [:weapon, 66, 1, 10]], 1500, 600, 150)
  end.else do
    c.text '路边草丛里跳出一个手持钢刀的山贼：“此山是我开，此树是我栽，要想从此过，留下买路钱！”'
    bandit.call(c, 145, 100, [[:armor, 32, 1, 30]], 400, 150, 40)
  end
  end
end

#--------------------------------------------------------------------------
# 2～4 温青：救他还是搜他的身，三段奇遇之后见分晓
#--------------------------------------------------------------------------
WebEncounter.add 2, '重伤的剑客', show: { tile: 879 }, where: :wild, weight: 3, once: true,
                 if: -> { WebEncounter.exp >= 10000 } do |c|
  c.text '路边草丛里躺着一个青衫剑客，浑身是血，腰间只剩一只空剑鞘。'
  c.text '他听见脚步声，勉强睁开眼，嘴唇动了动。'
  c.text '“……水……给我口水……”'
  c.choices(%w[救他 搜身 走开]) do |i|
    case i
    when 0
      c.if_has(:item, 9) do
        c.lose(:item, 9)
        c.text '你取出生肌膏替他敷上，血慢慢止住了。'
      end.else do
        c.if_has(:item, 8) do
          c.lose(:item, 8)
          c.text '你取出金创药替他敷上，血慢慢止住了。'
        end.else do
          c.if_gold(200) do
            c.gold(-200)
            c.text '你身上没带伤药，只好背着他赶到最近的镇子请大夫医治，花去二百两银子。'
          end.else do
            c.text '你身上没有伤药，也没有银子，只好撕下衣襟替他包扎，又喂了他几口水。'
          end
        end
      end
      c.text '剑客喘息稍定，抱拳道：“在下温青。追杀我的人还在附近，恩公快走。这份恩情，温某日后必报！”'
      c.switch(107)
      c.reward morality: 5
    when 1
      c.text '你在他怀里摸出一个钱袋，还有一封染血的书信。剑客死死瞪着你，却说不出话来。'
      c.gold(300)
      c.gain(:item, 25)
      c.switch(108)
      c.reward morality: -10
    when 2
      c.text '江湖险恶，少管闲事。你绕过他，继续赶路。'
    end
  end
end

WebEncounter.add 3, '温青报恩', where: %i[wild suburb town], weight: 5, once: true, after: [2, 3],
                 if: -> { $game_switches[107] } do |c|
  c.text '“恩公！”一个青衫剑客快步迎上来，正是那日你救下的温青，气色已经大好。'
  c.text '“那日追杀我的是黑风寨的山贼。如今仇已报了，家传的秋水剑也夺了回来。”'
  c.text '“温某身无长物，这口剑就送给恩公。另有几手剑上的心得，也一并说与恩公听。”'
  c.gain(:weapon, 34)
  c.reward pot: 300
  c.text '得到了秋水剑！潜能增加了三百点。'
end

WebEncounter.add 4, '温青寻仇', combat: true, where: %i[wild suburb town], weight: 5, once: true, after: [2, 3],
                 if: -> { $game_switches[108] } do |c|
  fight = lambda do
    c.fight(147, loot: [[:weapon, 34]],
      killed: -> { c.text '温青倒在血泊里，至死也没合上眼睛。'; c.reward morality: -10, wanted: 1 },
      spared: -> { c.text '温青捂着伤口，恨恨地看了你一眼，转身走了。' },
      escape: -> { c.text '你仗着脚快，甩开了温青。' },
      lose: -> {
        c.if_has(:item, 25) { c.lose(:item, 25) }
        c.script '$game_party.lose_gold([$game_party.gold, 300].min)'
        c.text '温青收回书信和银两，剑尖在你喉前停了一停：“今日饶你一命。”'
      })
  end
  c.text '“站住！”一个青衫剑客拦在路中，手里握着一口寒光闪闪的长剑。'
  c.text '“那日趁人之危、搜走我书信的，就是你吧？温青今日讨债来了！”'
  c.choices(%w[认错赔还 动手]) do |i|
    if i == 0
      c.if_script('$game_party.item_number(25)>0 && $game_party.gold>=300') do
        c.lose(:item, 25)
        c.gold(-300)
        c.reward morality: 3
        c.text '温青接过书信和银两，冷冷看了你一眼：“好自为之。”'
      end.else do
        c.text '你身上已经拿不出那些东西了。温青拔剑出鞘：“那就手底下见真章！”'
        fight.call
      end
    else
      fight.call
    end
  end
end

#--------------------------------------------------------------------------
# 5 武学残页
#--------------------------------------------------------------------------
WebEncounter.add 5, '武学残页', show: { tile: 457 }, where: :wild, weight: 2, cooldown: 2,
                 if: -> { $game_party.item_number(26) < 8 } do |c|
  c.text '一阵风卷着一页发黄的纸飘到你脚边，上面密密麻麻画着人形和经脉。'
  c.gain(:item, 26)
  c.text '得到了武学残页！（集齐四页，在物品栏里使用）'
end

#--------------------------------------------------------------------------
# 6 骰子摊
#--------------------------------------------------------------------------
dice = lambda do |c, bet|
  c.if_gold(bet) do
    c.gold(-bet)
    c.if_script('WebJianghu.sharp_eyes?') do
      c.text '你盯着骰盅看了几把，发觉庄家袖口里藏着东西——这骰子灌了铅！'
      c.choices(%w[当场揭穿 不动声色]) do |i|
        if i == 0
          c.text '你一把按住骰盅：“各位，这骰子有鬼！”众人哗然。庄家赔着笑，把银子加倍塞还给你。'
          c.gold(bet * 2)
          c.reward morality: 2
          c.if_switch(116, false) do
            c.text '临走时，你顺手把那枚灌铅骰子揣进了怀里。'
            c.gain(:armor, 38)
            c.switch(116)
          end
        else
          c.text '你暗中记准了庄家的手法，一连押中三把，赢得庄家脸都绿了。'
          c.gold(bet * 4)
          c.reward morality: -1
        end
      end
    end.else do
      c.choices(%w[押大 押小]) do |i|
        c.if_script('WebJianghu.dice_win?') do
          c.text(i == 0 ? '开！四五六，大！你赢了。' : '开！一二三，小！你赢了。')
          c.gold(bet * 2)
        end.else do
          c.text(i == 0 ? '开！一一二，小！庄家笑嘻嘻地把银子扫走了。' : '开！五五六，大！庄家笑嘻嘻地把银子扫走了。')
        end
      end
    end
  end.else do
    c.text '你摸了摸钱袋，还不够这一注。'
  end
end

WebEncounter.add 6, '骰子摊', show: { tile: 847 }, where: :town, weight: 3, cooldown: 2 do |c|
  c.text '街角围着一圈人，一个尖嘴猴腮的汉子摇着骰盅，哗啦哗啦响。'
  c.text '“押大押小，买定离手！”'
  c.choices(%w[押一百两 押五百两 走开]) do |i|
    case i
    when 0 then dice.call(c, 100)
    when 1 then dice.call(c, 500)
    when 2 then c.text '十赌九输。你摇摇头走开了。'
    end
  end
end

#--------------------------------------------------------------------------
# 7 恶霸欺人（正派）  8 落单行商（邪派）
#--------------------------------------------------------------------------
WebEncounter.add 7, '恶霸欺人', combat: true, show: { tile: 884 }, where: %i[wild suburb town], weight: 2, cooldown: 4,
                 if: -> { WebEncounter.good? } do |c|
  c.text '一个满脸横肉的恶霸揪着卖菜老汉的衣领。'
  c.text '“这个月的份子钱呢？拿不出来就砸了你的摊子！”'
  c.choices(%w[出手相助 视而不见]) do |i|
    if i == 0
      c.text '“光天化日，欺负老人家算什么本事？”'
      c.fight(148, loot: [[:armor, 35, 1, 20]],
        win: lambda {
          c.text '卖菜老汉拉着你的手千恩万谢。'
          c.if_switch(109, false) do
            c.text '老汉硬塞给你一双新纳的千层底布鞋：“自家婆娘做的，少侠别嫌弃。”'
            c.gain(:armor, 33)
            c.switch(109)
          end
          c.reward exp: 200, pot: 60, morality: 3
          c.variable(163, 1, 1)
          c.if_script('$game_variables[163] >= 5 && !$game_switches[120]') do
            c.text '围观的人群里走出一位青衫老者，捋须点头：“少侠屡次路见不平，有古君子之风。”'
            c.text '“老夫年轻时也练过几天剑，这口君子剑跟了我四十年，今日赠与少侠。”'
            c.gain(:weapon, 51)
            c.switch(120)
            c.text '得到了君子剑！'
          end
        },
        spared: -> { c.text '恶霸捂着脸跑了，临走还撂下一句狠话。' },
        lose: -> { c.text '恶霸把你推倒在地，朝老汉的菜筐踹了一脚，扬长而去。' })
    else
      c.text '你低头走开了，身后传来老汉的哀求声。'
      c.reward morality: -1
    end
  end
end

WebEncounter.add 8, '落单行商', show: { tile: 878 }, where: :wild, weight: 2, cooldown: 4,
                 if: -> { !WebEncounter.good? } do |c|
  c.text '一个挑着货担的行商独自赶路，担子沉甸甸的，不时紧张地四下张望。'
  c.choices(%w[拦路打劫 放他过去]) do |i|
    if i == 0
      c.text '行商吓得面无人色，乖乖交出了钱袋，连货担也不要了，撒腿就跑。'
      c.script '$game_party.gain_gold(200 + rand(400))'
      c.reward morality: -5, wanted: 1
    else
      c.text '你侧身让开了路。行商愣了愣，千恩万谢地走了。'
      c.reward morality: 1
    end
  end
end

#--------------------------------------------------------------------------
# 9 赏金猎人：作恶的后果
#--------------------------------------------------------------------------
WebEncounter.add 9, '赏金猎人', combat: true, where: %i[wild suburb], weight: -> { 2 + [WebEncounter.wanted, 6].min }, cooldown: 3,
                 if: -> { ($game_variables[164] >= 2 || $game_variables[160] < 64) && WebGear.value(:no_bounty) == 0 && !WebRoute.hunted? } do |c|
  fight = lambda do
    c.fight(149, loot: [[:weapon, 36, 1, 25], [:armor, 35, 1, 25]],
      killed: -> { c.text '杀了官府的人，这下事情闹大了。'; c.reward wanted: 1, morality: -3 },
      spared: -> { c.text '赏金猎人捂着伤口退走了：“你等着，官府不会放过你的！”' },
      escape: -> { c.text '你钻进树林，甩掉了赏金猎人。' },
      lose: -> {
        c.script '$game_party.lose_gold($game_party.gold/2)'
        c.script '$game_variables[164]=[$game_variables[164]-2,0].max'
        c.text '你被铁链锁着押到衙门，罚了一半的银子才放出来。'
      })
  end
  c.text '“站住！”一个背着铁链、腰缠长鞭的汉子拦住去路，抖开一张画像，“没错，就是你！官府悬赏，拿你归案！”'
  c.script '$game_variables[9]=WebJianghu.bounty'
  c.text '赏金猎人：“要么交出赏银\V[9]两，要么跟我去衙门走一趟！”'
  c.choices(%w[交出赏银 动手]) do |i|
    if i == 0
      c.if_script('$game_party.gold>=$game_variables[9]') do
        c.script "$game_party.lose_gold($game_variables[9])\n$game_variables[164]=[$game_variables[164]-1,0].max"
        c.text '赏金猎人收起银子，撕了画像：“这回放你一马。”'
      end.else do
        c.text '“没钱？那就手底下见！”'
        fight.call
      end
    else
      fight.call
    end
  end
end

#--------------------------------------------------------------------------
# 10 江湖传闻：每次听到一条还没听过的
#--------------------------------------------------------------------------
RUMORS = [
  [110, 'true',
   '“……听说当年有个独行大盗，把一箱金银埋在大地图西北角的尽头。后来他死了，宝贝到今天也没人找着……”'],
  [112, 'true',
   '“……五指山山谷西北角的崖壁底下有块大青石，我爷爷说，底下压着一块能续命的暖玉……”'],
  [114, '!$game_switches[106]',
   '“……平安镇西郊有张石桌，桌上刻着一局怪棋，几十年了没人解得开。都说解开了，有天大的好处……”'],
  [115, '!$game_switches[104] && $live[144] != false',
   '“……商业街那个老叫化，你可别小看了。有人见过他一根竹棒，把七八个泼皮打得满地找牙……”'],
]

WebEncounter.add 10, '江湖传闻', show: { tile: 643 }, where: %i[town suburb], weight: 2, cooldown: 1,
                 if: -> { RUMORS.any? { |sw, cond, _| !$game_switches[sw] && eval(cond) } } do |c|
  c.text '路边茶摊上，几个江湖客压低了嗓门说话。你要了碗茶，凑近听了几句……'
  tell = lambda do |rest|
    sw, cond, text = rest[0]
    c.if_script("!$game_switches[#{sw}] && (#{cond})") do
      c.text text
      c.switch(sw)
    end.else do
      tell.call(rest[1..]) if rest.size > 1
    end
  end
  tell.call(RUMORS)
end

# 传闻里的两处藏宝：听说之前走过去什么也不会发生
WebMod.edit 1 do |m|
  m.event 2, 1, name: '乱石堆', trigger: 1 do |c|
    c.if_script('$game_switches[110] && !$game_switches[111]') do
      c.text '你在尽头的乱石堆里扒拉了半天，挖出一只朽烂的铁箱，箱里是一件金光闪闪的软甲和一包银子。'
      c.gain(:armor, 36)
      c.gold(2000)
      c.switch(111)
      c.text '得到了金丝软甲和二千两银子！'
    end
  end
end

WebMod.edit 24 do |m|
  m.event 5, 4, name: '大青石', trigger: 1 do |c|
    c.if_script('$game_switches[112] && !$game_switches[113]') do
      c.text '你使出吃奶的力气掀开大青石，底下的土里埋着一只小木匣，匣中一块暖玉温润如脂。'
      c.gain(:armor, 37)
      c.switch(113)
      c.text '得到了回春玉佩！'
    end
  end
end

#--------------------------------------------------------------------------
# 28 游方郎中：受了伤更容易遇到（气血不到一半时最常见，满血时不出现）
#   治好气血，也把受伤掉的气血上限补回来。道德很高的不收钱
#--------------------------------------------------------------------------
WebEncounter.add 28, '游方郎中', show: { tile: 847 }, where: %i[wild suburb], cooldown: 2,
                 weight: -> { r = WebEncounter.hp_rate; r < 0.5 ? 8 : r < 0.8 ? 2 : 0 } do |c|
  c.text '一个背着药箱的游方郎中拦住你，皱着眉看了看你的脸色：“这位客官，伤得不轻啊。”'
  c.if_variable(160, 200, 1) do
    c.text '郎中忽然认出了你：“原来是位大侠！行侠仗义落下的伤，老朽分文不取。”'
    c.script "a = $game_actors[1]\na.maxhp = [a.maxhp, a.full_hp].max\na.hp = a.maxhp"
    c.text '郎中替你推宫过血、敷上药膏，伤势全好了。'
  end.else do
    c.choices(%w[请他医治（二百两） 不必了]) do |i|
      if i == 0
        c.if_gold(200) do
          c.gold(-200)
          c.script "a = $game_actors[1]\na.maxhp = [a.maxhp, a.full_hp].max\na.hp = a.maxhp"
          c.text '郎中替你推宫过血、敷上药膏，伤势全好了。'
        end.else do
          c.text '你摸了摸钱袋，还差一些。郎中叹了口气，塞给你一包草药：“省着点用吧。”'
          c.script "a = $game_actors[1]\na.hp = [a.hp + a.maxhp / 4, a.maxhp].min"
        end
      else
        c.text '“讳疾忌医，可不是好事。”郎中摇摇头走了。'
      end
    end
  end
end
