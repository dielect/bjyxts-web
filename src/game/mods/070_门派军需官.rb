#==============================================================================
# ■ 门派军需官：六大门派各一名，只把本门套装卖给本门弟子（装备见 050_江湖装备.rb）
#------------------------------------------------------------------------------
#  按本门内功等级分批开放：30 级鞋、腰带；60 级头饰、披风；100 级外衣、盔甲；150 级兵器。
#  门派编号（变量 21）：1 八卦门 2 花间派 3 红莲教 4 尹贺谷 5 太极门 6 雪山剑派
#==============================================================================
module WebQuartermaster
  TIERS = [30, 60, 100, 150]

  # 门派 => [地图, x, y, 头像, 称呼, 本门内功, { 等级 => 货 }, 交谈, 查看]
  LIST = {
    1 => [30, 13, 8, 852, '八卦门军需', 72,
          { 30 => [[:armor, 41], [:armor, 95]], 60 => [[:armor, 50]], 100 => [[:armor, 65], [:armor, 77]], 150 => [[:weapon, 40]] },
          '商家堡的东西，都是给自家人用的。混元一气功练得越深，库房里能拿的越多。',
          '一个账房模样的中年人，算盘打得噼啪响，腰里却别着一口八卦刀。'],
    2 => [23, 12, 22, 860, '花间派军需', 73,
          { 30 => [[:armor, 42], [:armor, 96]], 60 => [[:armor, 51]], 100 => [[:armor, 66]], 150 => [[:weapon, 41], [:weapon, 54], [:weapon, 70]] },
          '姐妹们的衣裳首饰都在我这儿。三花聚顶练到火候，自然有好东西给你。',
          '一位手巧的绣娘，膝上摊着一件没绣完的百花罗裙。'],
    3 => [25, 12, 10, 850, '红莲教军需', 74,
          { 30 => [[:armor, 43], [:armor, 97]], 60 => [[:armor, 52], [:armor, 87]], 100 => [[:armor, 67]], 150 => [[:weapon, 58]] },
          '红莲圣火，普照众生。普天同济练得越好，教里赐下的法器越多。',
          '一个红衣执事，身后堆着几只贴了封条的木箱。'],
    4 => [36, 15, 9, 845, '尹贺谷军需', 75,
          { 30 => [[:armor, 44], [:armor, 98]], 60 => [[:armor, 53], [:armor, 90]], 100 => [[:armor, 68]], 150 => [[:weapon, 42], [:weapon, 71]] },
          '忍具、刀剑，都由我管。扶桑忍术不到家的人，拿了也是白白送命。',
          '一个蒙着面的忍者，盘腿坐在一排忍刀前面。'],
    5 => [27, 13, 8, 843, '太极门军需', 76,
          { 30 => [[:armor, 45], [:armor, 99]], 60 => [[:armor, 54], [:armor, 91]], 100 => [[:armor, 69]], 150 => [[:weapon, 46], [:weapon, 43]] },
          '武当的衣冠剑器，贫道替掌门收着。太极神功练到哪一层，便给到哪一层。',
          '一位管库房的老道，袖子上沾着灰，正在清点道袍。'],
    6 => [42, 13, 7, 879, '雪山派军需', 77,
          { 30 => [[:armor, 46]], 60 => [[:armor, 55], [:armor, 92]], 100 => [[:armor, 70], [:armor, 84]], 150 => [[:weapon, 47]] },
          '大雪山上冷，穿得不够要冻死人。雪山内功练得深了，库里的好东西随你挑。',
          '一个裹着皮裘的汉子，眉毛上结着白霜。'],
  }

  module_function

  def goods_upto(table, level)
    TIERS.select { |t| t <= level }.flat_map { |t| table[t] || [] }
  end
end

WebQuartermaster::LIST.each do |sect, (map, x, y, tile, name, inner, table, talk, look)|
  school = WebGear::SECTS[sect]
  WebMod.edit map do |m|
    m.npc x, y, name: name, tile: tile, look: { age: 4, level: 10, attack: 3, items: '布衣', text: look },
          shop: lambda { |c|
            c.if_variable(21, sect) do
              chain = lambda do |tiers|
                lv = tiers[0]
                c.if_variable(inner, lv, 1) do
                  c.shop(WebQuartermaster.goods_upto(table, lv))
                end.else do
                  if tiers.size > 1
                    chain.call(tiers[1..])
                  else
                    c.text '你的本门内功还不到 30 级，库房里的东西还轮不到你。'
                  end
                end
              end
              chain.call(WebQuartermaster::TIERS.reverse)
            end.else do
              c.text "这是#{school}的库房，只供本门弟子。"
            end
          } do |c|
      c.text talk
      c.text '（本门内功 30 级起可领鞋子腰带，60 级头饰披风，100 级衣甲，150 级兵器。）'
    end
  end
end
