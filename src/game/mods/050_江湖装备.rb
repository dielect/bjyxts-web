#==============================================================================
# ■ 装备池扩充：4 件兵器、7 件防具，其中 7 件带特效（src/game/web_gear.rb）
#------------------------------------------------------------------------------
#  来源大多在江湖奇遇里（060_江湖奇遇.rb），少数在原版商人处添货：
#    秋水剑    温青报恩赠剑；与温青结仇时打赢他夺得               【秋水】两成几率多打五成伤害
#    黑风刀    山贼头目掉落                                       【饮血】回复伤害一成半的气血
#    蛇骨鞭    赏金猎人掉落                                       【蛇毒】两成半几率让对方中毒 3 回合
#    铁骨折扇  兵器行何铁手                                       【点穴】一成几率定住对方
#    斗笠      裁缝店小裁缝、山贼掉落
#    千层底布鞋 裁缝店小裁缝、帮卖菜老汉解围后他送的
#    狼皮袄    山贼头目掉落
#    护心镜    恶霸、赏金猎人掉落                                 【护心】每场一次，气血将尽时保住一口气
#    金丝软甲  江湖传闻里的大盗藏宝                               【反震】反弹两成普通攻击的伤害
#    回春玉佩  江湖传闻里五指山的大石头下                         【回春】每次行动前回复 3% 气血
#    灌铅骰子  揭穿骰子摊的老千后得到                             【出千】赌骰子时胜算大增（只在骰子摊有用）
#
#  编号：武器 34～37，防具 32～38
#==============================================================================

#--------------------------------------------------------------------------
# 兵器
#--------------------------------------------------------------------------
WebMod.weapon 34, like: 16, name: '秋水剑', atk: 58, price: 12000, dex_plus: 0,
              description: '剑身清亮如一泓秋水，是温家家传的宝剑。【秋水】两成几率多打五成伤害'
WebMod.weapon 35, like: 10, name: '黑风刀', atk: 45, price: 8000, str_plus: 0, dex_plus: -1,
              description: '黑风寨头目的佩刀，刀身乌沉沉的。【饮血】回复伤害一成半的气血'
WebMod.weapon 36, like: 21, name: '蛇骨鞭', atk: 42, price: 9000, dex_plus: 0,
              description: '用蛇骨节节串成的软鞭，倒刺上泛着青光。【蛇毒】命中时可能让对方中毒'
WebMod.weapon 37, like: 3, name: '铁骨折扇', atk: 30, price: 3000, dex_plus: 0,
              description: '精钢扇骨的折扇，合起来可以点穴。【点穴】一成几率定住对方'
WebSkill.weapon_type 41, [34, 37]           # 剑（扇子在原版也算剑类）
WebSkill.weapon_type 42, [35]               # 刀
WebSkill.weapon_type 44, [36]               # 鞭

WebGear.effect :weapon, 34, :crit,   chance: 20, ratio: 0.5, name: '秋水：剑气透体'
WebGear.effect :weapon, 35, :drain,  ratio: 0.15, name: '饮血'
WebGear.effect :weapon, 36, :poison, chance: 25, turns: 3, name: '蛇毒'
WebGear.effect :weapon, 37, :stun,   chance: 10, name: '点穴'

#--------------------------------------------------------------------------
# 防具（kind：0 鞋 1 头饰 2 外衣 3 盔甲）。以 24 金锁子甲为模板，把各项加成都写明
#--------------------------------------------------------------------------
ARMOR_BASE = { like: 24, pdef: 0, str_plus: 0, dex_plus: 0, int_plus: 0, auto_state_id: 0 }
def_armor = lambda { |id, **attrs| WebMod.armor(id, **ARMOR_BASE.merge(attrs)) }

def_armor.call 32, name: '斗笠', kind: 1, pdef: 4, dex_plus: 1, price: 120,
             description: '竹篾编的斗笠，遮阳挡雨，行走江湖的必备之物'
def_armor.call 33, name: '千层底布鞋', kind: 0, pdef: 6, dex_plus: 3, price: 400,
             description: '一针一线纳出来的千层底，走起路来又软又轻'
def_armor.call 34, name: '狼皮袄', kind: 2, pdef: 22, price: 1800,
             description: '整张狼皮缝成的皮袄，又厚又暖，就是有股腥膻味'
def_armor.call 35, name: '护心镜', kind: 3, pdef: 25, dex_plus: -1, price: 4000,
             description: '护在胸口的一面铜镜。【护心】每场战斗一次，气血将尽时保住一口气'
def_armor.call 36, name: '金丝软甲', kind: 3, pdef: 40, price: 30000,
             description: '金丝细细织成的软甲，轻若无物。【反震】反弹两成普通攻击的伤害'
def_armor.call 37, name: '回春玉佩', kind: 1, pdef: 2, price: 15000,
             description: '一块温润的暖玉，贴身佩戴，气血自生。【回春】每次出手前回复些许气血'
def_armor.call 38, name: '灌铅骰子', kind: 1, pdef: 0, price: 50,
             description: '一枚灌了铅的骰子，掷出去十有八九是六。【出千】赌骰子时胜算大增'

WebGear.effect :armor, 35, :guard,   name: '护心'
WebGear.effect :armor, 36, :reflect, ratio: 0.2, name: '反震'
WebGear.effect :armor, 37, :regen,   pct: 3, name: '回春'

#--------------------------------------------------------------------------
# 商人添货
#--------------------------------------------------------------------------
WebMod.edit 7 do |m|                                # 裁缝店
  m.goods '小裁缝', [[:armor, 32], [:armor, 33]]
end

WebMod.edit 19 do |m|                               # 兵器行
  m.goods '何铁手', [[:weapon, 37]]
end
