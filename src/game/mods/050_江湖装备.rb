#==============================================================================
# ■ 装备池：武器 34～73、防具 32～102 与 13 套套装（设计见 docs/装备设计.md）
#------------------------------------------------------------------------------
#  特效与套装的引擎在 src/game/web_gear.rb。说明文字（【特效】……、【某某套 n/6】……）
#  由引擎按登记的数据自动生成，物品栏里左右键翻页查看，这里的 description 只写一句描述。
#  来源：原版商店添货在本文件末尾；门派军需官在 070_门派军需官.rb；奇遇掉落在 060 及以后的奇遇文件。
#==============================================================================

#--------------------------------------------------------------------------
# 写法
#--------------------------------------------------------------------------
module WebEquip
  # 兵器类型 => [基础武功, 模板]
  WEAPON_KIND = { 刀: [42, 10], 剑: [41, 16], 扇: [41, 3], 鞭: [44, 21], 拂尘: [44, 23], 杖: [43, 25], 棍: [39, 25] }
  # 防具部位 => kind（0 鞋 1 头饰 2 外衣 3 盔甲 4 披风 5 腰带）
  ARMOR_KIND = { 鞋: 0, 头饰: 1, 外衣: 2, 盔甲: 3, 披风: 4, 腰带: 5 }
  CLEAR = { str_plus: 0, dex_plus: 0, agi_plus: 0, int_plus: 0, pdef: 0 }

  module_function

  # WebEquip.weapon 38, '雁翎刀', :刀, 32, 1200, '……', dex: 1, fx: [[:chase, chance: 15]]
  def weapon(id, name, kind, atk, price, text, str: 0, dex: 0, fx: [])
    base, like = WEAPON_KIND.fetch(kind)
    WebMod.weapon id, like: like, **CLEAR.merge(name: name, atk: atk, price: price,
                  str_plus: str, dex_plus: dex, description: text)
    WebSkill.weapon_type base, [id]
    fx.each { |type, opts| WebGear.effect :weapon, id, type, **(opts || {}) }
  end

  def armor(id, name, part, pdef, price, text, str: 0, dex: 0, fx: [])
    WebMod.armor id, like: 24, **CLEAR.merge(auto_state_id: 0, name: name, kind: ARMOR_KIND.fetch(part),
                 pdef: pdef, price: price, str_plus: str, dex_plus: dex, description: text)
    fx.each { |type, opts| WebGear.effect :armor, id, type, **(opts || {}) }
  end
end

#==========================================================================
# 兵器
#==========================================================================
W = WebEquip
# ---- 第一批（江湖奇遇）
W.weapon 34, '秋水剑',   :剑, 58, 12000, '剑身清亮如一泓秋水，是温家家传的宝剑',     fx: [[:crit, chance: 20, ratio: 0.5, name: '秋水']]
W.weapon 35, '黑风刀',   :刀, 45, 8000,  '黑风寨头目的佩刀，刀身乌沉沉的', dex: -1,  fx: [[:drain, ratio: 0.15, name: '饮血']]
W.weapon 36, '蛇骨鞭',   :鞭, 42, 9000,  '用蛇骨节节串成的软鞭，倒刺上泛着青光',     fx: [[:poison, chance: 25, turns: 3, name: '蛇毒']]
W.weapon 37, '铁骨折扇', :扇, 30, 3000,  '精钢扇骨的折扇，合起来可以点穴',           fx: [[:stun, chance: 10]]
# ---- 刀
W.weapon 38, '雁翎刀',   :刀, 32, 1200,  '刀身狭长，形如雁翎，官军常用'
W.weapon 39, '斩马刀',   :刀, 50, 9000,  '长柄阔刃的大刀，一刀能斩断马腿', str: 2, dex: -2, fx: [[:execute, ratio: 0.5]]
W.weapon 40, '八卦紫金刀', :刀, 62, 22000, '刀背錾着八卦图，八卦门传了三代的宝刀', fx: [[:level, skill: 80, n: 15]]
W.weapon 41, '柳絮刀',   :刀, 48, 15000, '薄如柳叶的弯刀，舞起来如柳絮翻飞', dex: 3, fx: [[:chase, chance: 15]]
W.weapon 42, '川枫野太刀', :刀, 60, 22000, '扶桑名匠所铸的长刀，刃纹如枫叶', fx: [[:crit, chance: 15, ratio: 0.8]]
W.weapon 43, '玄虚刀',   :刀, 58, 20000, '武当玄虚一脉的佩刀，刀意空灵', fx: [[:power, ratio: 0.2, when: { skill: 83 }]]
W.weapon 44, '血饮狂刀', :刀, 70, 30000, '黑风寨寨主的狂刀，刀身隐隐泛红', dex: -3, fx: [[:drain, ratio: 0.2, when: { evil: 128 }, name: '血饮']]
W.weapon 71, '忍刀·影', :刀, 52, 18000, '尹贺谷忍者的短刀，刀鞘漆黑无光', dex: 3, fx: [[:dodge, chance: 8, name: '影遁']]
# ---- 剑
W.weapon 45, '松纹古剑', :剑, 40, 4000,  '剑身上有松树般的天然纹路，古意盎然'
W.weapon 46, '真武剑',   :剑, 66, 24000, '武当镇山之剑，剑柄刻着真武二字', fx: [[:level, skill: 85, n: 15]]
W.weapon 47, '雪山寒铁剑', :剑, 62, 22000, '大雪山寒铁所铸，剑身终年带霜', fx: [[:slow, chance: 20, name: '寒铁']]
W.weapon 48, '白虹剑',   :剑, 72, 32000, '出鞘时一道白光如虹，削铁如泥', fx: [[:pierce]]
W.weapon 49, '鸳鸯剑',   :剑, 56, 16000, '一对鸳鸯剑中的一把，剑穗系着红绳'
W.weapon 50, '青竹剑',   :剑, 35, 900,   '青竹削成的剑，轻巧灵便，练剑正好', dex: 2
W.weapon 51, '君子剑',   :剑, 60, 20000, '剑身平直无饰，剑脊刻“君子”二字', fx: [[:power, ratio: 0.2, when: { good: 200 }, name: '浩然']]
W.weapon 52, '倚天剑',   :剑, 95, 50000, '“倚天不出，谁与争锋”，天下第一神剑', fx: [[:pierce], [:crit, chance: 15, ratio: 0.5]]
W.weapon 68, '描金折扇', :扇, 26, 1500,  '扇面描金山水，书生最爱的风雅之物'
W.weapon 69, '判官笔',   :剑, 45, 12000, '精钢打造的大笔，笔锋专点穴道', fx: [[:stun, chance: 12]]
W.weapon 70, '峨眉刺',   :剑, 40, 14000, '两头尖细的短刺，套在指上贴身而用', dex: 4, fx: [[:chase, chance: 25]]
W.weapon 72, '金蛇剑',   :剑, 76, 40000, '剑身弯曲如蛇，剑尖分叉如蛇信', fx: [[:poison, chance: 30, turns: 3, name: '金蛇毒'], [:disarm, chance: 10]]
W.weapon 73, '玄铁重剑', :剑, 99, 50000, '重剑无锋，大巧不工', str: 8, dex: -10, fx: [[:pierce, name: '无锋'], [:execute, ratio: 0.3]]
# ---- 鞭
W.weapon 53, '软金鞭',   :鞭, 38, 10000, '金丝绞成的软鞭，专缠对手兵刃', fx: [[:disarm, chance: 15]]
W.weapon 54, '花团锦鞭', :鞭, 58, 22000, '鞭上缀满绢花，舞动时花团锦簇', fx: [[:power, ratio: 0.2, when: { skill: 88 }]]
W.weapon 55, '九节鞭',   :鞭, 46, 11000, '九节钢环相连，一抖一收连环而至', fx: [[:chase, chance: 20]]
W.weapon 56, '银丝拂尘', :拂尘, 44, 12000, '银丝为尾的拂尘，拂过之处吸人内力', fx: [[:steal_sp, ratio: 0.1]]
W.weapon 57, '天蚕丝鞭', :鞭, 66, 30000, '天蚕丝绞成的长鞭，柔韧无比', fx: [[:stun, chance: 12, name: '缠缚']]
# ---- 杖
W.weapon 58, '红莲禅杖', :杖, 64, 22000, '杖头铸一朵铜莲，红莲教长老的法杖', fx: [[:level, skill: 89, n: 15]]
W.weapon 59, '镔铁杖',   :杖, 42, 3500,  '镔铁打造的长杖，专破硬功', fx: [[:pierce]]
W.weapon 60, '龙头拐杖', :杖, 52, 12000, '杖头雕成龙首，拄着走路也能护身', fx: [[:reduce, ratio: 0.1, name: '护身']]
W.weapon 61, '盘龙杖',   :杖, 70, 30000, '杖身盘着一条铁龙，重逾百斤', dex: -3, fx: [[:stun, chance: 10, name: '震']]
W.weapon 62, '乌木短杖', :杖, 30, 600,   '乌木削成的短杖，结实耐用'
# ---- 棍
W.weapon 63, '枣木棍',   :棍, 28, 800,   '枣木又硬又沉，做棍最好', dex: 1
W.weapon 64, '镔铁齐眉棍', :棍, 48, 7000, '镔铁包头的齐眉棍，两头都能打人', fx: [[:chase, chance: 15]]
W.weapon 65, '蟠龙棍',   :棍, 60, 20000, '棍身缠着铜铸的蟠龙，专打落水狗', fx: [[:execute, ratio: 0.4]]
W.weapon 66, '风火棍',   :棍, 55, 18000, '两头包着赤铜，舞起来呼呼带火', fx: [[:crit, chance: 15, ratio: 0.6, name: '风火']]
W.weapon 67, '混铁棍',   :棍, 78, 35000, '生铁混铸的大棍，砸在甲上甲碎', dex: -4, fx: [[:pierce]]

#==========================================================================
# 防具
#==========================================================================
# ---- 第一批（江湖奇遇）
W.armor 32, '斗笠',       :头饰, 4, 120,  '竹篾编的斗笠，遮阳挡雨，行走江湖的必备之物', dex: 1
W.armor 33, '千层底布鞋', :鞋, 6, 400,    '一针一线纳出来的千层底，走起路来又软又轻', dex: 3
W.armor 34, '狼皮袄',     :外衣, 22, 1800, '整张狼皮缝成的皮袄，又厚又暖，就是有股腥膻味'
W.armor 35, '护心镜',     :盔甲, 25, 4000, '护在胸口的一面铜镜', dex: -1, fx: [[:guard]]
W.armor 36, '金丝软甲',   :盔甲, 40, 30000, '金丝细细织成的软甲，轻若无物', fx: [[:reflect, ratio: 0.2]]
W.armor 37, '回春玉佩',   :头饰, 2, 15000, '一块温润的暖玉，贴身佩戴，气血自生', fx: [[:regen, pct: 3]]
W.armor 38, '灌铅骰子',   :头饰, 0, 50,   '一枚灌了铅的骰子，掷出去十有八九是六', fx: [[:custom, key: :dice, value: 1, name: '出千', text: '赌骰子时胜算大增']]
# ---- 鞋
W.armor 39, '草鞋',       :鞋, 2, 20,     '稻草编的鞋，穷人家的孩子都穿这个', dex: 1
W.armor 40, '快靴',       :鞋, 5, 800,    '薄底快靴，官府的公差最爱穿', dex: 4
W.armor 41, '游龙靴',     :鞋, 8, 1500,   '靴面绣着游龙，八卦门弟子的制式靴', dex: 6, fx: [[:level, skill: 64, n: 10]]
W.armor 42, '飞蝶绣鞋',   :鞋, 6, 1500,   '鞋尖绣着一对彩蝶，走起来像要飞', dex: 8
W.armor 43, '赤焰靴',     :鞋, 8, 1500,   '赤红的皮靴，红莲教众的标记', dex: 5
W.armor 44, '忍足袋',     :鞋, 4, 1500,   '分趾的黑布袜，落地无声', dex: 9
W.armor 45, '云履',       :鞋, 7, 1500,   '白底青面的道履，步履如行云', dex: 6, fx: [[:level, skill: 68, n: 10]]
W.armor 46, '踏雪靴',     :鞋, 10, 1500,  '雪山派的毡靴，踏雪不陷', dex: 6, fx: [[:level, skill: 69, n: 10]]
W.armor 47, '凌波鞋',     :鞋, 5, 20000,  '一双素白的软鞋，鞋底绣着水纹', dex: 10
W.armor 48, '神行太保靴', :鞋, 6, 25000,  '据说穿上它一日能走八百里', dex: 12, fx: [[:escape]]
# ---- 头饰
W.armor 49, '方巾',       :头饰, 2, 200,  '读书人戴的方巾'
W.armor 50, '八卦护额',   :头饰, 6, 3000, '铜片缀成的护额，正中一个八卦'
W.armor 51, '梅花簪',     :头饰, 3, 3000, '白玉雕成的梅花簪，花间派弟子的信物', dex: 3
W.armor 52, '红莲头巾',   :头饰, 5, 3000, '绣着红莲的头巾，红莲教众人人都有'
W.armor 53, '鬼面具',     :头饰, 6, 3000, '青面獠牙的面具，戴上后对手出手发虚', fx: [[:dodge, chance: 10, name: '鬼面']]
W.armor 54, '道冠',       :头饰, 4, 3000, '武当道士的莲花冠'
W.armor 55, '白狐皮帽',   :头饰, 8, 3000, '白狐皮缝的暖帽，雪山上离不了它'
W.armor 56, '逍遥玉冠',   :头饰, 5, 20000, '一顶白玉冠，玉质通透', fx: [[:sp_regen, pct: 3]]
W.armor 57, '鸳鸯佩',     :头饰, 2, 8000, '一对鸳鸯玉佩中的一块'
W.armor 58, '虎骨扳指',   :头饰, 2, 9000, '虎骨磨成的扳指，戴上拳头更硬', str: 3, fx: [[:power, ratio: 0.15, when: { unarmed: true }]]
W.armor 59, '金丝手套',   :头饰, 4, 20000, '金丝织的手套，刀剑割不破', fx: [[:disarm, chance: 10, when: { unarmed: true }, name: '空手夺白刃']]
W.armor 60, '平安符',     :头饰, 1, 500,  '庙里求来的平安符，针脚细密', fx: [[:guard]]
W.armor 61, '舍利子',     :头饰, 0, 30000, '高僧坐化后留下的舍利，戴着心神宁定', fx: [[:skill_reduce, ratio: 0.2], [:skill_reduce, ratio: 0.1, when: { good: 200 }, name: '佛光']]
W.armor 62, '夜明珠',     :头饰, 0, 40000, '夜里自生光华的宝珠，价值连城', fx: [[:gold, ratio: 0.3]]
# ---- 外衣
W.armor 63, '青布长衫',   :外衣, 8, 300,  '一件洗得发白的青布长衫'
W.armor 64, '儒衫',       :外衣, 6, 600,  '宽袍大袖的儒衫，穿上斯文了许多'
W.armor 65, '乾坤袍',     :外衣, 18, 6000, '袍上用金线绣着乾坤八卦'
W.armor 66, '百花罗裙',   :外衣, 12, 6000, '绣着百花的罗衫罗裙，花间派弟子的服饰', dex: 4
W.armor 67, '红莲法衣',   :外衣, 16, 6000, '大红的法衣，前后各绣一朵红莲'
W.armor 68, '夜行忍装',   :外衣, 10, 6000, '贴身的黑色忍装，夜里几乎看不见', dex: 6
W.armor 69, '太极道袍',   :外衣, 15, 6000, '背后绣着太极图的道袍'
W.armor 70, '雪山白狐裘', :外衣, 20, 6000, '整张白狐皮做的皮裘，雪地里看不出人影'
W.armor 71, '逍遥青衫',   :外衣, 12, 20000, '一件洗得干干净净的青衫，飘飘有出尘之意', dex: 5
W.armor 72, '蓑衣',       :外衣, 10, 400, '棕丝编的蓑衣，下雨天钓鱼正好'
W.armor 73, '百衲衣',     :外衣, 14, 0,   '百块补丁缝成的衣服，丐帮长老才穿'
W.armor 74, '锦袍',       :外衣, 10, 15000, '织金的锦袍，穿上像个财主', fx: [[:gold, ratio: 0.15]]
# ---- 盔甲
W.armor 75, '藤甲',       :盔甲, 20, 2500, '桐油浸过的藤甲，又轻又韧'
W.armor 76, '鳞甲',       :盔甲, 35, 9000, '铁片如鱼鳞般缀成的铠甲', dex: -2
W.armor 77, '八卦护心镜', :盔甲, 30, 12000, '八卦形的护心镜，镜背刻着先天八卦', fx: [[:guard]]
W.armor 78, '黑风铁甲',   :盔甲, 40, 15000, '黑风寨头领们穿的铁甲，漆得乌黑', dex: -3
W.armor 79, '六扇门软甲', :盔甲, 28, 10000, '六扇门捕头的贴身软甲'
W.armor 80, '金刚护体甲', :盔甲, 50, 35000, '厚重的铁甲，内衬牛皮，刀枪难入', dex: -4, fx: [[:cap, ratio: 0.2]]
W.armor 81, '天蚕宝衣',   :盔甲, 35, 40000, '天蚕丝织成的宝衣，柔软却刀剑不入', fx: [[:skill_reduce, ratio: 0.25]]
W.armor 82, '乌蚕衣',     :盔甲, 30, 20000, '乌蚕丝织成的黑衣，穿上心神安定', dex: 2, fx: [[:steady]]
W.armor 83, '软猬甲',     :盔甲, 38, 45000, '甲上满是倒刺，打人者先伤了自己', fx: [[:reflect, ratio: 0.3]]
W.armor 84, '雪蚕甲',     :盔甲, 32, 12000, '雪蚕丝编成的软甲，冰凉贴身'
# ---- 披风
W.armor 85, '粗布披风',   :披风, 3, 150,  '一块粗布缝成的披风，挡风挡雨'
W.armor 86, '黑风大氅',   :披风, 8, 4000, '黑色的大氅，一抖就是一阵黑风'
W.armor 87, '红莲披风',   :披风, 8, 4000, '红底黑边的披风，背后一朵红莲'
W.armor 88, '鹤氅',       :披风, 7, 12000, '鹤羽织成的大氅，穿上身轻如鹤', dex: 4, fx: [[:dodge, chance: 6]]
W.armor 89, '六扇门斗篷', :披风, 6, 4000, '六扇门公差的斗篷'
W.armor 90, '忍者黑斗篷', :披风, 5, 4000, '一裹就能隐进阴影里的黑斗篷', dex: 5
W.armor 91, '太极鹤氅',   :披风, 6, 4000, '黑白两色的鹤氅，背后一个太极图'
W.armor 92, '雪狐披风',   :披风, 9, 4000, '雪狐皮的披风，又轻又暖'
W.armor 93, '破麻袋',     :披风, 2, 0,    '一只打着补丁的破麻袋，丐帮弟子背着它要饭', fx: [[:sp_regen, pct: 3]]
# ---- 腰带
W.armor 94, '布腰带',     :腰带, 1, 50,   '一条普通的布腰带'
W.armor 95, '八卦玉带',   :腰带, 4, 1200, '镶着八块玉的腰带'
W.armor 96, '花间丝绦',   :腰带, 2, 1200, '五色丝线编成的丝绦', dex: 3
W.armor 97, '红莲腰索',   :腰带, 3, 1200, '红绳编成的腰索，打着莲花结'
W.armor 98, '忍具腰带',   :腰带, 3, 1200, '插满暗器和忍具的腰带', dex: 2
W.armor 99, '太极丝绦',   :腰带, 3, 1200, '黑白两色丝线编成的丝绦'
W.armor 100, '黑风腰牌',  :腰带, 3, 3000, '黑风寨的腰牌，道上的人见了都让三分'
W.armor 101, '六扇门腰牌', :腰带, 2, 3000, '六扇门的腰牌，见牌如见官'
W.armor 102, '酒葫芦',    :腰带, 0, 2000, '挂在腰间的酒葫芦，喝一口精神百倍', fx: [[:sp_regen, pct: 5, name: '醉意']]

#==========================================================================
# 套装
#==========================================================================
BAGUA = [2, 3, 4, 5]                                 # 化掌为刀、八卦/八阵刀影掌
WebGear.set :乾坤, '乾坤',
  pieces: [[:weapon, 40], [:armor, 41], [:armor, 50], [:armor, 65], [:armor, 77], [:armor, 95]],
  tiers: { 2 => [[:power, ratio: 0.1, when: { skills: [53, 54, 80] }]],
           4 => [[:cost, ratio: 0.3, skills: BAGUA]],
           6 => [[:level, skill: 80, n: 20], [:level, skill: 53, n: 20], [:level, skill: 54, n: 20],
                 [:power, ratio: 0.1, when: { sect: 1 }]] }
WebGear.set :落英, '落英',
  pieces: [[[:weapon, 41], [:weapon, 54], [:weapon, 70]], [:armor, 42], [:armor, 51], [:armor, 66], [:armor, 96]],
  tiers: { 2 => [[:dodge, chance: 5]],
           4 => [[:cost, ratio: 0.3, skills: [6, 7, 8]]],
           5 => [[:chase, chance: 15], [:dodge, chance: 5, when: { sect: 2 }]] }
WebGear.set :业火, '业火',
  pieces: [[:weapon, 58], [:armor, 43], [:armor, 52], [:armor, 67], [:armor, 87], [:armor, 97]],
  tiers: { 2 => [[:poison, chance: 15, turns: 3, name: '灼烧']],
           4 => [[:cost, ratio: 0.3, skills: [9, 10]]],
           6 => [[:level, skill: 50, n: 20], [:level, skill: 89, n: 20], [:drain, ratio: 0.1]] }
WebGear.set :影, '影',
  pieces: [[[:weapon, 42], [:weapon, 71]], [:armor, 44], [:armor, 53], [:armor, 68], [:armor, 90], [:armor, 98]],
  tiers: { 2 => [[:dodge, chance: 8]],
           4 => [[:cost, ratio: 0.4, skills: [12, 13]]],
           6 => [[:crit, chance: 15, ratio: 0.5], [:escape]] }
WebGear.set :两仪, '两仪',
  pieces: [[[:weapon, 46], [:weapon, 43]], [:armor, 45], [:armor, 54], [:armor, 69], [:armor, 91], [:armor, 99]],
  tiers: { 2 => [[:skill_reduce, ratio: 0.15]],
           4 => [[:cost, ratio: 0.3, skills: (16..22).to_a]],
           6 => [[:level, skill: 85, n: 20], [:level, skill: 58, n: 20], [:level, skill: 76, n: 20], [:reflect, ratio: 0.2]] }
WebGear.set :凌霄, '凌霄',
  pieces: [[:weapon, 47], [:armor, 46], [:armor, 55], [:armor, 70], [:armor, 84], [:armor, 92]],
  tiers: { 2 => [[:steady]],
           4 => [[:cost, ratio: 0.3, skills: [23, 24, 25]]],
           6 => [[:stun, chance: 15, name: '寒气'], [:reduce, ratio: 0.1, when: { sect: 6 }]] }
WebGear.set :逍遥, '逍遥',
  pieces: [[:armor, 47], [:armor, 56], [:armor, 71]],
  tiers: { 2 => [[:dodge, chance: 8], [:dodge, chance: 7, when: { active: 70 }, name: '凌波']],
           3 => [[:custom, key: :xwx_mimic, value: 0.2, text: '小无相功模仿度+20%'],
                 [:custom, key: :zhemei_chase, value: 10, text: '折梅手追加一击几率+10%']] }
WebGear.set :丐帮, '丐帮',
  pieces: [[:weapon, 33], [:armor, 73], [:armor, 93], [:armor, 102]],
  tiers: { 2 => [[:power, ratio: 0.15, when: { skill: 84 }]],
           4 => [[:cost, ratio: 0.4, skills: [28]]] }
WebGear.set :黑风寨, '黑风寨',
  pieces: [[[:weapon, 44], [:weapon, 35]], [:armor, 34], [:armor, 78], [:armor, 86], [:armor, 100]],
  tiers: { 2 => [[:power, ratio: 0.1, when: { evil: 128 }]],
           4 => [[:drain, ratio: 0.1], [:crit, chance: 10, ratio: 0.5, when: { evil: 64 }]],
           5 => [[:custom, key: :no_bounty, value: 1, text: '赏金猎人见了绕道走']] }
WebGear.set :六扇门, '六扇门',
  pieces: [[:armor, 35], [:armor, 79], [:armor, 89], [:armor, 101]],
  tiers: { 2 => [[:power, ratio: 0.1, when: { good: 128 }]],
           4 => [[:disarm, chance: 15], [:reduce, ratio: 0.1]] }
WebGear.set :鸳鸯, '鸳鸯',
  pieces: [[:weapon, 49], [:armor, 57]],
  tiers: { 2 => [[:cost, ratio: 0.5, skills: [27]], [:power, ratio: 0.1]] }
WebGear.set :书生, '书生',
  pieces: [[:weapon, 68], [:armor, 49], [:armor, 64]],
  tiers: { 2 => [[:level, skill: 48, n: 20]],
           3 => [[:cost, ratio: 0.15, skills: :all]] }
WebGear.set :渔樵, '渔樵',
  pieces: [[:armor, 32], [:armor, 72], [:armor, 31]],
  tiers: { 2 => [[:regen, pct: 2]],
           3 => [[:gold, ratio: 0.3], [:regen, pct: 2]] }

#--------------------------------------------------------------------------
# 逍遥套接到小无相功、天山折梅手
#--------------------------------------------------------------------------
class << WebXwx
  alias __gear_mimic mimic
  def mimic
    [__gear_mimic + WebGear.value(:xwx_mimic), 1.0].min
  end
end

class << WebZhemei
  def chase(attacker, target)
    lv = level
    chance = [lv / 10, 30].min + WebGear.value(:zhemei_chase).to_i
    return nil if lv < 30 || target.hp <= 0 || rand(100) >= chance
    extra_damage(target, 0.5) > 0 ? '（折梅：顺势又是一掌）' : nil
  end
end

#==========================================================================
# 原版商店添货（普通装备）
#==========================================================================
WebMod.edit 7 do |m|                                # 裁缝店
  m.goods '小裁缝', [[:armor, 32], [:armor, 33], [:armor, 40], [:armor, 49], [:armor, 63], [:armor, 64],
                    [:armor, 85], [:armor, 94]]
end

WebMod.edit 16 do |m|                               # 杂货店
  m.goods '杂货贩', [[:weapon, 50], [:weapon, 68], [:armor, 39]]
  m.goods '荷西', [[:armor, 72]]                    # 卖钓竿的，顺便卖蓑衣
end

WebMod.edit 19 do |m|                               # 兵器行
  m.goods '何铁手', [[:weapon, 37], [:weapon, 38], [:weapon, 45], [:weapon, 59], [:weapon, 62],
                    [:armor, 75], [:armor, 76]]
end
