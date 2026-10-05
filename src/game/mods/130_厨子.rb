#==============================================================================
# ■ 厨子路线（设计见 docs/职业生活与武林互动设计.md；引擎在 src/game/web_life.rb 末尾）
#------------------------------------------------------------------------------
#  入行：给客栈厨师交满三单鱼后，他教你四道家常菜，后厨的灶台（厨师身边那口锅）随你用。
#  菜谱来源：厨师（家常菜；交过两单菜后再教两道）、荷西（三道海鲜，入行后问他）、独行大侠（远行带回香料，两道香辣菜）、
#           漂流瓶（偶尔夹着八宝鱼翅的方子）。
#  做菜：备齐食材，选火候、调味，看成色（普通 / 好 / 极品，极品出两份）。厨艺熟练度：学徒、帮厨、掌勺、大厨、御厨。
#  吃菜：填饱肚子，接下来两三场战斗带着这道菜的增益（同一时间只算最后吃的一道）。
#  销路：客栈订单开始收菜；独行大侠成了熟客——来吃饭、记得你的手艺、远行回来带香料、介绍朋友（之后菜单报酬更高）。
#
#  编号：物品 52～63 菜、64 西域香料；公共事件 37～48 吃菜
#==============================================================================

#--------------------------------------------------------------------------
# 十二道菜：[物品, 名字, 食材, 火候, 调味, 讲究, 吃了的增益, 管几场, 价钱, 描述, 辣]
#   火候 0 文火 1 武火 2 先武后文；调味 0 清淡 1 咸鲜 2 重口
#--------------------------------------------------------------------------
DISHES = [
  [52, '鲫鱼豆腐汤', { 28 => 2, 7 => 1 },          0, 0, '汤要慢慢熬才白，鲫鱼本身就鲜，不用多放盐。',
   [[:regen, pct: 3]], 3, 120, '奶白的鱼汤，豆腐嫩，鱼肉鲜'],
  [53, '红烧鲤鱼',   { 17 => 1 },                   2, 2, '大火煎香，再小火慢烧入味；红烧嘛，酱要下得足。',
   [[:power, ratio: 0.08]], 2, 150, '酱色红亮的鲤鱼，鱼皮微焦'],
  [54, '红烧肉',     { 5 => 2 },                    2, 2, '先爆再焖，肥而不腻；酱油冰糖不要省。',
   [[:power, ratio: 0.12]], 2, 220, '颤巍巍的红烧肉，入口即化'],
  [55, '鸡汤',       { 1 => 2 },                    0, 0, '老鸡要文火炖上半天，什么都不用放，原汁原味。',
   [[:regen, pct: 3], [:sp_regen, pct: 2]], 3, 140, '一锅清亮的鸡汤，油花金黄'],
  [56, '麻婆豆腐',   { 4 => 1, 5 => 1, 64 => 1 },  1, 2, '大火快炒，麻辣烫一样不能少，西域香料是魂。',
   [[:crit, chance: 15, ratio: 0.5]], 2, 180, '红油翻滚的豆腐，麻得人直吸气', true],
  [57, '清蒸鳜鱼',   { 32 => 1 },                   1, 0, '鳜鱼肉嫩，大火足汽蒸一刻就好，火小了腥，盐多了压鲜。',
   [[:sp_regen, pct: 5], [:dodge, chance: 5]], 3, 400, '雪白的鳜鱼卧在盘里，葱丝青翠'],
  [58, '糖醋黄鱼',   { 34 => 2, 6 => 1 },           1, 2, '炸得外酥里嫩全靠大火；糖醋汁要浓，酸甜才够劲。',
   [[:chase, chance: 10]], 2, 200, '金黄酥脆的黄鱼，浇着亮晶晶的糖醋汁'],
  [59, '干煎带鱼',   { 35 => 2 },                   1, 1, '大火两面煎黄，撒点盐就是一道好菜。',
   [[:reduce, ratio: 0.08]], 2, 180, '两面金黄的带鱼段，咸香下饭'],
  [60, '清蒸石斑',   { 37 => 1 },                   1, 0, '石斑最讲究原味，大火蒸，淡淡地浇一勺豉油就够。',
   [[:guard], [:regen, pct: 2]], 3, 500, '一整条石斑鱼，肉质紧实雪白'],
  [61, '孜然烤鱼',   { 29 => 1, 64 => 1 },          1, 2, '炭火要旺，孜然辣子撒得满满当当，西域的吃法。',
   [[:power, ratio: 0.15], [:crit, chance: 10, ratio: 0.5]], 2, 320, '外焦里嫩的烤鱼，孜然香飘满街', true],
  [62, '酥油茶煮雪鱼', { 50 => 1, 3 => 1 },         0, 1, '雪山的吃法：酥油茶文火慢煮，咸香暖身。',
   [[:skill_reduce, ratio: 0.15], [:steady]], 3, 450, '酥油茶里煮着细鳞鱼，热气腾腾'],
  [63, '八宝鱼翅',   { 32 => 1, 37 => 1, 5 => 1, 1 => 1 }, 2, 1, '御膳的方子：先武后文，咸鲜为本，八样料一样不能马虎。',
   [[:power, ratio: 0.15], [:regen, pct: 3], [:reduce, ratio: 0.1]], 3, 1200, '金碗盛着的八宝鱼翅，香气扑鼻'],
]

DISHES.each_with_index do |(id, name, needs, heat, taste, hint, fx, battles, price, text, spicy), i|
  ce = 37 + i
  WebMod.item id, like: 2, name: name, price: price, common_event_id: ce, occasion: 2, consumable: true, description: text
  WebLife.recipe id, name: name, needs: needs, heat: heat, taste: taste, hint: hint, fx: fx, battles: battles, spicy: !!spicy
  WebMod.common_event ce, "吃-#{name}" do |c|
    c.say "WebLife.eat_dish(#{id})"
  end
end
WebMod.item 64, like: 22, name: '西域香料', price: 200, description: '独行大侠从西域带回的香料，孜然辣子都有'

# 菜都归“食物”（原版按编号分类，见 120 的说明）
class RPG::Item
  alias __cook_type type
  def type
    (52..63).include?(id) ? 0 : __cook_type
  end
end

#--------------------------------------------------------------------------
# 菜谱来源与熟客独行大侠
#--------------------------------------------------------------------------
module WebLife
  class << self
    def kitchen? = flag?(:kitchen)

    # ---- 厨师：交满三单鱼后教家常菜、借灶台；交过两单菜后再教两道
    def kitchen_offer_due?
      !kitchen? && cook[:done] >= 3
    end

    def open_kitchen
      set_flag(:kitchen)
      names = learn(52, 53, 54, 55)
      "厨师把围裙一解：“你天天给我送鱼，不如我教你几手！”他教会了你#{names}。“后厨那口锅，你随时来用。”"
    end

    def cook_advanced_due?
      kitchen? && (cook[:dishes] || 0) >= 2 && !known?(57)
    end

    def cook_advanced
      names = learn(57, 62)
      "“你这手艺，可以学点难的了。”厨师又教了你#{names}。"
    end

    # ---- 荷西：入行后教海鲜
    def jose_recipes_due?
      kitchen? && !flag?(:jose_recipes)
    end

    def jose_recipes
      set_flag(:jose_recipes)
      names = learn(58, 59, 60)
      "听说你在客栈学做菜了？我们老家靠海，我教你几道海鲜！（学会了#{names}）"
    end

    # ---- 订单也收菜（入行后一半是菜，报酬更高；独行大侠介绍朋友后再高三成）
    def dish_order?
      kitchen? && !cook_data[:recipes].empty? && rand(2) == 0
    end

    def new_dish_order
      id = cook_data[:recipes].sample
      qty = 1 + rand(2)
      rate = flag?(:sword_friends) ? 2.1 : 1.6
      data[:order] = { client: :cook, item: id, qty: qty, pay: ($data_items[id].price * qty * rate).to_i, day: day, dish: true }
    end

    # ---- 熟客：独行大侠
    def sword
      client(:sword)
    end

    SWORD_CALL = [[0, '店家'], [2, :young], [5, :close]]
    def sword_call
      f = sword[:favor]
      t = SWORD_CALL.select { |n, _| f >= n }.last[1]
      case t
      when :young then $gender == '女' ? '小姑娘' : '小兄弟'
      when :close then $gender == '女' ? '妹子' : '老弟'
      else t
      end
    end

    # 他这次想吃什么（不吃辣：他带回香料时说过，以后从不点辣的）
    def sword_want
      return sword[:want] if sword[:want] && known?(sword[:want])
      pool = cook_data[:recipes].reject { |id| RECIPES[id][:spicy] }
      sword[:want] = pool.sample
    end

    def sword_back?
      sword[:away] && day >= sword[:away]
    end

    def sword_line
      if sword_back? && !flag?(:spice)
        set_flag(:spice)
        sword[:away] = nil
        $game_party.gain_item(64, 3)
        names = learn(56, 61)
        return "#{sword_call}，我回来了！西域的香料，给你带了一包——孜然辣子，那边的人顿顿离不了。" \
               "我自己可不吃辣，你记着。（得到西域香料三份，学会了#{names}）"
      end
      return "过些日子我要出趟远门，等我回来。" if sword[:away]
      w = sword_want or return "#{sword_call}也学做菜了？学会了做给我尝尝。"
      prefix = flag?(:spice) ? '老规矩，不要辣。' : ''
      "#{sword_call}，#{prefix}今天想吃#{RECIPES[w][:name]}，有吗？"
    end

    def sword_can_serve?
      !sword[:away] && (w = sword_want) && $game_party.item_number(w) > 0
    end

    def serve_sword
      w = sword_want
      $game_party.lose_item(w, 1)
      pay = ($data_items[w].price * 1.5).to_i
      $game_party.gain_gold(pay)
      sword[:favor] += 1
      sword[:want] = nil
      text = "独行大侠吃得干干净净，放下#{pay}两银子：“好手艺！”"
      case sword[:favor]
      when 3
        sword[:away] = day + 20
        text += "他擦擦嘴：“过些日子我要出趟远门，回来给你带点好东西。”"
      when 6
        set_flag(:sword_friends)
        text += "“我那些江湖朋友都想尝尝你的手艺，我跟客栈打过招呼了，往后点菜的人多着呢。”（客栈的菜单报酬提高）"
      end
      text
    end
  end
end

#--------------------------------------------------------------------------
# 灶台：客栈厨师身边那口锅（地图 20 墙边 11,7，站在厨师左边那一格朝下）
#--------------------------------------------------------------------------
WebMod.edit 20 do |m|
  m.event 11, 7, name: '灶台', tile: 510 do |c|
    c.if_script('WebLife.kitchen?') do
      c.script '$scene = Scene_Cook.new'
    end.else do
      c.text '厨师的灶台。没他点头，可不能乱动。'
    end
  end
end
