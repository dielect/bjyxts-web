#==============================================================================
# ■ 江湖奇遇：第二批（装备来源，设计见 docs/装备设计.md 第 6 节）
#------------------------------------------------------------------------------
#   11 江湖货郎   野外郊外  每次随机摆 3 件稀有货
#   12 黑风寨     野外      打败山贼头目 3 次后，寨主找上门：正派打寨主，邪派可以入伙。黑风寨套集齐前反复出现
#   13 捕头相邀   各处      正派、行侠 4 次后，六扇门捕头邀你入门，送六扇门软甲和腰牌
#   14 六扇门差事 野外郊外  入了六扇门以后，捉拿江洋大盗
#   15 比武招亲   镇上      打赢擂主得鸳鸯剑、鸳鸯佩（下手杀了就什么也得不到）
#
#  编号：敌人 150 黑风寨寨主、151 江洋大盗、152 擂主
#        开关 117 入了六扇门  118 比武招亲已了结  119 入伙黑风寨
#        变量 162 打败山贼头目的次数、163 行侠次数（在 060 里累计）
#==============================================================================

WebMod.enemy 150, name: '黑风寨寨主', tile: 853, like: 124, maxhp: 700, maxsp: 1500, gold: 3000, elite: true,
             stats: NO_STYLE.merge(膂力: 30, 敏捷: 26, 悟性: 22, 根骨: 28, 武器: 44, 经验: 400000),
             skills: { 42 => 170, 47 => 150, 46 => 140, 45 => 150, 40 => 130 }
WebMod.enemy 151, name: '江洋大盗', tile: 846, like: 123, maxhp: 520, maxsp: 800, gold: 1500,
             stats: NO_STYLE.merge(膂力: 27, 敏捷: 28, 悟性: 22, 根骨: 25, 武器: 19, 经验: 200000),
             skills: { 41 => 140, 47 => 120, 46 => 140, 45 => 120, 40 => 100 }
WebMod.enemy 152, name: '擂主', tile: 862, like: 52, maxhp: 500, maxsp: 900, gold: 0,
             stats: NO_STYLE.merge(膂力: 26, 敏捷: 28, 悟性: 26, 根骨: 24, 武器: 0, 经验: 150000),
             skills: { 40 => 130, 47 => 110, 46 => 120, 45 => 100 }

module WebJianghu
  # 货郎的货：每次从里面随机挑 3 件
  PEDDLER = [[:weapon, 39], [:weapon, 48], [:weapon, 53], [:weapon, 55], [:weapon, 61], [:weapon, 65], [:weapon, 69],
             [:armor, 48], [:armor, 58], [:armor, 74], [:armor, 80], [:armor, 82], [:armor, 88]]
  HEIFENG = [[:weapon, 44], [:armor, 78], [:armor, 86], [:armor, 100]]

  module_function

  def peddler_stock
    PEDDLER.sample(3).sort
  end

  def heifeng_done?
    HEIFENG.all? { |k, i| WebMod.owned(k, i) > 0 }
  end
end

#--------------------------------------------------------------------------
# 11 江湖货郎
#--------------------------------------------------------------------------
WebEncounter.add 11, '江湖货郎', show: { tile: 863 }, where: %i[wild suburb], weight: -> { WebEncounter.gold >= 20000 ? 4 : 2 }, cooldown: 3 do |c|
  c.text '一个挑着货担的货郎摇着拨浪鼓走过来：“走过路过，别错过！今儿个有几样稀罕货！”'
  c.choices(%w[看看货 不用了]) do |i|
    if i == 0
      c.script 'WebMod.open_shop(WebJianghu.peddler_stock)'
    else
      c.text '货郎也不纠缠，摇着拨浪鼓走远了。下回再碰上，担子里又是别的东西了。'
    end
  end
end

#--------------------------------------------------------------------------
# 12 黑风寨
#--------------------------------------------------------------------------
WebEncounter.add 12, '黑风寨', combat: true, where: :wild, weight: 4, cooldown: 4,
                 if: -> { $game_variables[162] >= 3 && !WebJianghu.heifeng_done? } do |c|
  fight = lambda do
    c.fight(150, loot: [[:missing, WebJianghu::HEIFENG, 1]],
      win: -> { c.reward exp: 1500, pot: 400 },
      killed: -> { c.text '黑风寨寨主一死，寨里的喽啰作鸟兽散。'; c.reward morality: 3 },
      spared: -> { c.text '寨主捂着伤口退进林子：“好！今日算你狠，咱们走着瞧！”' },
      escape: -> { c.text '你杀开一条血路，冲出了包围。' },
      lose: -> { c.script '$game_party.lose_gold($game_party.gold/2)'; c.text '山贼们把你捆在树上，搜走了一半银子才扬长而去。' })
  end
  c.if_switch(119) do
    c.text '黑风寨的喽啰在路边等你：“兄弟，寨主有一票大买卖，就等你了！”'
    c.choices(%w[干了 改天吧]) do |i|
      if i == 0
        c.text '你跟着寨主劫了一趟官银，寨主从库里挑了一件宝贝赏你。'
        c.script "WebMod.roll_loot([[:missing, WebJianghu::HEIFENG, 1]])\nWebMod.give_loot"
        c.gold(1000)
        c.reward morality: -5, wanted: 1
      else
        c.text '“那就下回。”喽啰嘿嘿一笑，钻回了林子。'
      end
    end
  end.else do
    c.text '林子里一声锣响，几十个山贼围了上来。一个虬髯大汉提着血红的长刀走出。'
    c.text '“就是你三番五次坏我黑风寨的买卖？”'
    c.if_good do
      c.choices(%w[动手 赔罪了事]) do |i|
        if i == 0
          fight.call
        else
          c.if_gold(2000) do
            c.gold(-2000)
            c.text '你赔上两千两银子，寨主哼了一声，挥手让开了路。'
          end.else do
            c.text '“没钱赔罪？那就拿命来！”'
            fight.call
          end
        end
      end
    end.else do
      c.choices(%w[动手 入伙]) do |i|
        if i == 0
          fight.call
        else
          c.text '寨主上下打量你，忽然哈哈大笑：“好！是条道上的汉子！从今往后，黑风寨就是你的家！”'
          c.gain(:armor, 100)
          c.switch(119)
          c.reward morality: -5
          c.text '得到了黑风腰牌！'
        end
      end
    end
  end
end

#--------------------------------------------------------------------------
# 13 捕头相邀  14 六扇门差事
#--------------------------------------------------------------------------
WebEncounter.add 13, '捕头相邀', where: %i[wild suburb town], weight: 5, cooldown: 6,
                 if: -> { WebEncounter.good? && $game_variables[163] >= 4 && !$game_switches[117] } do |c|
  c.text '一个腰挂铁尺的中年汉子拦住你，拱手道：“在下六扇门捕头周铁。”'
  c.text '“少侠屡次路见不平，惩治恶人，周某佩服。六扇门正缺人手，不知少侠可愿屈就？”'
  c.choices(%w[加入六扇门 婉言谢绝]) do |i|
    if i == 0
      c.text '“好！”周捕头取出一副软甲和一块腰牌，“这是门里的规矩，见牌如见官。往后有差事，自会派人找你。”'
      c.gain(:armor, 79)
      c.gain(:armor, 101)
      c.switch(117)
      c.text '得到了六扇门软甲、六扇门腰牌！'
    else
      c.text '“人各有志，周某不勉强。少侠若是改了主意，日后江湖再见。”'
    end
  end
end

WebEncounter.add 14, '六扇门差事', combat: true, where: %i[wild suburb], weight: 3, cooldown: 3,
                 if: -> { $game_switches[117] && WebEncounter.good? } do |c|
  c.text '一个公差快马赶来，递上一纸公文：“周捕头有令，江洋大盗在附近出没，请少侠缉拿！”'
  c.text '不多时，你在路边茶棚里认出了画像上的人。那人也认出了你，拔剑就走。'
  c.fight(151, loot: [[:missing, [[:armor, 89], [:armor, 35]], 1, 60]],
    win: -> { c.gold(800); c.reward exp: 600, pot: 150, morality: 2; c.text '你把大盗交给公差，领了八百两赏银。' },
    escape: -> { c.text '你追丢了人，只好回去复命。' },
    lose: -> { c.text '大盗一脚把你踹翻，跳上屋顶跑了。' })
end

#--------------------------------------------------------------------------
# 15 比武招亲
#--------------------------------------------------------------------------
WebEncounter.add 15, '比武招亲', combat: true, show: { tile: 878 }, where: :town, weight: 3, cooldown: 3,
                 if: -> { !$game_switches[118] && WebEncounter.age >= 16 } do |c|
  c.if_script('$gender == "女"') do
    c.text '街口搭起一座擂台，一位员外高声道：“犬子比武招亲！哪位姑娘打赢他，老夫以鸳鸯剑为聘！”'
  end.else do
    c.text '街口搭起一座擂台，一位员外高声道：“小女比武招亲！哪位少侠打赢她，老夫以鸳鸯剑为聘！”'
  end
  c.choices(%w[上台比武 看看热闹]) do |i|
    if i == 0
      c.fight(152, can_escape: false,
        spared: lambda {
          c.text '员外抚掌大笑，捧出一对鸳鸯剑：“好身手！这口雄剑归你，另一口……”擂主红着脸，把一块鸳鸯佩塞到你手里，转身跑下了台。'
          c.gain(:weapon, 49)
          c.gain(:armor, 57)
          c.switch(118)
          c.text '得到了鸳鸯剑、鸳鸯佩！'
        },
        killed: lambda {
          c.text '……台下一片死寂。员外扑在擂主身上，哭得撕心裂肺。'
          c.text '没有人再看你一眼。'
          c.switch(118)
          c.reward morality: -20, wanted: 1
        },
        lose: -> { c.text '你被一掌推下擂台，台下一片哄笑。' })
    else
      c.text '你挤在人群里看了一会儿热闹，上台的几个汉子都被打了下来。'
    end
  end
end
