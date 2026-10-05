#==============================================================================
# ■ 装备特效与套装（构建时紧接江湖奇遇载入，装备本身写在 src/game/mods/*.rb）
#------------------------------------------------------------------------------
#  原版的武器只有攻击力和属性加成，防具只有防御和加成。这里给装备登记“特效”，
#  并支持套装（穿上几件得到对应档位的效果）。只对玩家生效，NPC 拿着同一件兵器不触发。
#
#    WebGear.effect :weapon, 35, :drain, ratio: 0.15
#    WebGear.effect :armor,  36, :reflect, ratio: 0.2
#    WebGear.set :乾坤, '乾坤', pieces: [[:weapon, 40], [:armor, 41], ...],
#                tiers: { 2 => [[:power, ratio: 0.1, when: { skills: [53, 54, 80] }]], 4 => [...] }
#    pieces 里的一项也可以是几件任选其一：[[:weapon, 41], [:weapon, 54]]
#
#  特效（每件最多 2 个；数值相加，有上限）：
#   打中对方时   :crit 暴击 {chance, ratio}  :power 武学威力 {ratio}  :execute 斩杀 {ratio}  :pierce 破甲 {}
#                :drain 吸血 {ratio}  :steal_sp 吸内 {ratio}  :chase 连击 {chance}
#                :poison 中毒 {chance, turns}  :stun 点穴 {chance}  :disarm 缴械 {chance}  :slow 迟滞 {chance}
#   被打时       :dodge 闪避 {chance}  :reduce 减伤 {ratio}  :skill_reduce 化劲 {ratio}  :cap 金刚 {ratio}
#                :reflect 反震 {ratio}  :counter 反击 {chance}  :guard 护心 {}  :steady 定心 {}
#   每次行动前   :regen 回春 {pct}  :sp_regen 回内 {pct}  :self_hurt 反噬 {pct}（自己掉血，不致死，配合强力特效用）
#   武学         :level 武学精进 {skill, n}（战斗中视为等级 +n，同一门最多 +20）  :cost 绝招省力 {ratio, skills}
#   其他         :escape 神行  :gold 财运 {ratio}  :custom {key, value, text}（给别的模块查的数值）
#  通用参数：name（显示的名字，默认按类型）、when（生效条件，见 met?）、text（说明文字，不写自动生成）
#  装备说明在物品栏里分页显示：描述、各项特效、所属套装的件数与各档效果（左右键翻页）。
#  回归测试：node tools/gear-test.mjs
#==============================================================================
module WebGear
  NAMES = {
    crit: '暴击', power: '武学', execute: '斩杀', pierce: '破甲', drain: '吸血', steal_sp: '吸内',
    chase: '连击', poison: '中毒', stun: '点穴', disarm: '缴械', slow: '迟滞',
    dodge: '闪避', reduce: '减伤', skill_reduce: '化劲', cap: '金刚', reflect: '反震', counter: '反击',
    guard: '护心', steady: '定心', regen: '回春', sp_regen: '回内', level: '精进', cost: '省力',
    escape: '神行', gold: '财运', self_hurt: '反噬', custom: '',
  }
  TYPES = NAMES.keys
  LEVEL_CAP  = 20
  STUN_STATES = [1, 2, 11, 19]                    # 木鸡3、木鸡5、木鸡1、木鸡8
  SECTS = %w[江湖小虾 八卦门 花间派 红莲教 尹贺谷 太极门 雪山剑派 逍遥派]

  @weapons = Hash.new { |h, k| h[k] = [] }
  @armors  = Hash.new { |h, k| h[k] = [] }
  @sets    = {}

  class << self
    attr_reader :weapons, :armors, :sets

    # ---------------------------------------------------------------- 登记
    def effect(kind, id, type, **opts)
      table = kind == :weapon ? @weapons : @armors
      raise ArgumentError, "WebGear #{kind} #{id}：特效应是 #{TYPES.join('、')}" unless TYPES.include?(type)
      raise ArgumentError, "WebGear #{kind} #{id}：最多两个特效" if table[id].size >= 2
      check(type, opts, "#{kind} #{id}")
      table[id] << opts.merge(type: type)
    end

    def set(key, name, pieces:, tiers:)
      raise ArgumentError, "WebGear.set #{key}：重复定义" if @sets[key]
      pieces = pieces.map { |p| p[0].is_a?(Symbol) ? [p] : p }
      tiers.each { |n, list| list.each { |type, opts| check(type, opts || {}, "套装 #{name} #{n} 件") } }
      @sets[key] = { key: key, name: name, pieces: pieces,
                     tiers: tiers.sort.map { |n, list| [n, list.map { |type, opts| (opts || {}).merge(type: type) }] } }
    end

    def check(type, opts, where)
      raise ArgumentError, "WebGear #{where}：未知特效 #{type}" unless TYPES.include?(type)
      raise ArgumentError, "WebGear #{where}：:level 要写 skill 和 n" if type == :level && !(opts[:skill] && opts[:n])
      raise ArgumentError, "WebGear #{where}：:cost 要写 skills" if type == :cost && !opts[:skills]
    end

    # 某件装备属于哪套
    def set_of(kind, id)
      @sets.values.find { |s| s[:pieces].any? { |alts| alts.include?([kind, id]) } }
    end

    # ---------------------------------------------------------------- 当前生效的特效
    def actor
      $game_actors && $game_actors[1]
    end

    def equipped
      a = actor or return []
      list = a.weapon_id > 0 ? [[:weapon, a.weapon_id]] : []
      (1..7).each { |i| id = a.instance_variable_get(:"@armor#{i}_id").to_i; list << [:armor, id] if id > 0 }
      list
    end

    def set_count(s, eq = equipped)
      s[:pieces].count { |alts| alts.any? { |p| eq.include?(p) } }
    end

    def active
      eq = equipped
      list = eq.flat_map { |kind, id| (kind == :weapon ? @weapons : @armors).fetch(id, []) }
      @sets.each_value do |s|
        n = set_count(s, eq)
        s[:tiers].each { |need, effects| list.concat(effects) if n >= need }
      end
      list.select { |e| met?(e[:when]) }
    end

    def of(type)
      active.select { |e| e[:type] == type }
    end

    def sum(type, key, cap = nil)
      v = of(type).sum { |e| e[key].to_f }
      cap ? [v, cap].min : v
    end

    def any?(type)
      !of(type).empty?
    end

    def value(key)
      of(:custom).select { |e| e[:key] == key }.sum { |e| e[:value].to_f }
    end

    # 生效条件：
    #   skill: 80 / skills: [...]  当前出手用的武功（有兵器看启用的兵刃，空手看启用的拳脚）
    #   active: 70                  这门武功正在启用（任何一栏）
    #   sect: 1                     本门弟子（变量 21）
    #   unarmed: true               空手
    #   good: 200 / evil: 128       道德 ≥ / < 某值
    def met?(cond)
      return true unless cond
      a = actor
      cond.all? do |k, v|
        case k
        when :skill, :skills then Array(v).include?(attack_skill)
        when :active then (29..33).any? { |i| raw_var(i) == v }
        when :sect then raw_var(21) == v
        when :unarmed then (a.weapon_id == 0) == v
        when :good then raw_var(160) >= v
        when :evil then raw_var(160) < v
        else raise ArgumentError, "WebGear：未知条件 #{k}"
        end
      end
    end

    def raw_var(id)
      $game_variables.raw(id).to_i
    end

    # 当前普通攻击用的武功：空手是启用的拳脚（没启用为基本拳脚）；
    # 拿兵器时，启用的兵刃与兵器同类才算它，否则是兵器对应的基本功夫
    def attack_skill
      a = actor
      if a.weapon_id == 0
        sk = raw_var(29)
        sk == 0 ? 40 : sk
      else
        base = WebSkill.weapon_base(a.weapon_id)
        sk = raw_var(30)
        sk != 0 && WebSkill.base_of(sk) == base ? sk : base
      end
    end

    # ---------------------------------------------------------------- 武学精进（战斗中加等级）
    def level_bonus
      @level_bonus || {}
    end

    def levels_on
      b = Hash.new(0)
      of(:level).each { |e| b[e[:skill]] += e[:n] }
      b.each_key { |k| b[k] = [b[k], LEVEL_CAP].min }
      @level_bonus = b.empty? ? nil : b
    end

    def levels_off
      @level_bonus = nil
    end

    # ---------------------------------------------------------------- 战斗
    def battle_start
      @guard_used = false
      levels_on
    end

    def append(note)
      $defend_text = "#{$defend_text}#{note}" if note && !note.empty?
    end

    def label(e)
      e[:name] || NAMES[e[:type]]
    end

    def roll(e)
      rand(100) < e[:chance].to_i
    end

    # 玩家普通攻击打中之后
    def after_hit(a, t)
      base = t.damage
      notes = []
      ratio = 0.0
      of(:power).each { |e| ratio += e[:ratio] }
      of(:crit).each { |e| if roll(e) then ratio += e[:ratio]; notes << label(e) end }
      if t.hp + base < t.maxhp / 4
        of(:execute).each { |e| ratio += e[:ratio]; notes << label(e) }
      end
      unless of(:pierce).empty?
        p = [($npc_data[28].to_f / 150), 0.4].min
        if p > 0.05
          ratio += p
          notes << label(of(:pierce)[0])
        end
      end
      hurt(t, (base * ratio).to_i)
      dmg = t.damage
      d = sum(:drain, :ratio, 0.5)
      if d > 0 && (heal = [(dmg * d).to_i, a.maxhp - a.hp].min) > 0
        a.hp += heal
        notes << "#{label(of(:drain)[0])}#{heal}"
      end
      s = sum(:steal_sp, :ratio, 0.5)
      if s > 0 && (gain = [(dmg * s).to_i, a.maxsp - a.sp].min) > 0
        a.sp += gain
        notes << "#{label(of(:steal_sp)[0])}#{gain}"
      end
      if t.hp > 0
        of(:chase).each do |e|
          next unless roll(e)
          hurt(t, base / 2)
          notes << label(e)
          break
        end
        of(:poison).each do |e|
          next unless roll(e)
          t.instance_variable_set(:@gear_poison, [e[:turns] || 3, t.instance_variable_get(:@gear_poison).to_i].max)
          t.instance_variable_set(:@gear_poison_name, label(e))
          notes << "#{label(e)}：#{t.name}中招了"
          break
        end
        of(:stun).each do |e|
          next unless roll(e)
          t.add_state(1)
          notes << "#{label(e)}：#{t.name}动弹不得"
          break
        end
        of(:disarm).each do |e|
          w = $npc_data[9].to_i
          next unless w != 0 && roll(e)
          $game_party.gain_weapon(w, 1)
          $npc_data[9] = 0
          notes << "#{label(e)}：打落了#{$data_weapons[w].name}"
          break
        end
        of(:slow).each do |e|
          next unless roll(e)
          $npc_data[25] = $npc_data[25].to_i - 5
          notes << "#{label(e)}：#{t.name}身法迟滞"
          break
        end
      end
      append(notes.map { |n| "（#{n}）" }.join)
    end

    def hurt(t, extra)
      return if extra <= 0
      t.hp -= extra
      t.damage += extra
    end

    # 对方普通攻击之前：闪避
    def dodge?(target)
      c = sum(:dodge, :chance, 40)
      return false unless c > 0 && rand(100) < c
      target.damage = 'Miss'
      target.critical = false
      $defend_text = "但是你身形一晃，让了开去（#{label(of(:dodge)[0])}）"
      true
    end

    # 对方普通攻击打中之后
    def after_hurt(attacker, target)
      notes = []
      r = sum(:reduce, :ratio, 0.5)
      refund(target, (target.damage * r).to_i) if r > 0
      cap_damage(target, target.damage)
      unless of(:reflect).empty?
        back = [(target.damage * sum(:reflect, :ratio, 0.5)).to_i, attacker.hp - 1].min
        if back > 0
          attacker.hp -= back
          notes << "#{label(of(:reflect)[0])}#{back}"
        end
      end
      if target.hp > 0 && attacker.hp > 1
        of(:counter).each do |e|
          next unless roll(e)
          back = [target.damage / 2, attacker.hp - 1].min
          next if back <= 0
          attacker.hp -= back
          notes << "#{label(e)}：还手一击，#{attacker.name}损失#{back}"
          break
        end
      end
      append(notes.map { |n| "（#{n}）" }.join)
      append(guard(target))
    end

    # 绝招打中之后（lost 是这次绝招让玩家损失的气血）
    def after_skill_hurt(target, lost)
      return unless target.is_a?(Game_Actor) && lost > 0
      r = sum(:skill_reduce, :ratio, 0.5)
      refund(target, (lost * r).to_i) if r > 0
      cap_damage(target, lost - (lost * r).to_i)
    end

    def refund(target, n)
      return if n <= 0
      target.hp += n
      target.damage -= n if target.damage.is_a?(Integer)
    end

    def cap_damage(target, lost)
      c = of(:cap)
      return if c.empty?
      limit = (target.maxhp * c.map { |e| e[:ratio] }.min).to_i
      refund(target, lost - limit) if lost > limit
    end

    def guard(target)
      return nil unless target.is_a?(Game_Actor) && target.hp <= 0 && !@guard_used
      e = of(:guard)[0] or return nil
      @guard_used = true
      target.hp = 1
      "（#{label(e)}：护住了心脉，勉强撑住！）"
    end

    # 每次行动前：回春、回内（玩家），中毒发作（敌人）
    def before_action(battler, window)
      if battler.is_a?(Game_Actor)
        return if battler.hp <= 0
        notes = []
        pct = sum(:regen, :pct, 10)
        if pct > 0 && battler.hp < battler.maxhp
          heal = [[(battler.maxhp * pct / 100).to_i, 1].max, battler.maxhp - battler.hp].min
          battler.hp += heal
          notes << "气血回复#{heal}"
        end
        pct = sum(:sp_regen, :pct, 10)
        if pct > 0 && battler.sp < battler.maxsp
          gain = [[(battler.maxsp * pct / 100).to_i, 1].max, battler.maxsp - battler.sp].min
          battler.sp += gain
          notes << "内力回复#{gain}"
        end
        show(window, "一股暖意流遍全身，#{notes.join('，')}") unless notes.empty?
        pct = sum(:self_hurt, :pct, 10)
        if pct > 0 && battler.hp > 1
          lost = [[(battler.maxhp * pct / 100).to_i, 1].max, battler.hp - 1].min
          battler.hp -= lost
          show(window, "#{label(of(:self_hurt)[0])}：一阵心血翻涌，气血损失#{lost}")
        end
      else
        left = battler.instance_variable_get(:@gear_poison).to_i
        return if left <= 0 || battler.hp <= 0
        battler.instance_variable_set(:@gear_poison, left - 1)
        dmg = [[battler.maxhp * 4 / 100, 10].max, battler.hp - 1].min
        return if dmg <= 0
        battler.hp -= dmg
        what = battler.instance_variable_get(:@gear_poison_name) == '灼烧' ? '身上的火毒发作，皮肉焦灼' : '毒性发作，脸色发青'
        show(window, "#{battler.name}#{what}，气血损失#{dmg}点")
      end
    end

    def show(window, text)
      return unless window
      window.draw_words(text)
      30.times { Graphics.update }
    end

    # ---------------------------------------------------------------- 其他
    def cost_rate(skill_id)
      r = of(:cost).select { |e| e[:skills] == :all || Array(e[:skills]).include?(skill_id) }.sum { |e| e[:ratio] }
      1.0 - [r, 0.6].min
    end

    def escape?
      any?(:escape)
    end

    def gold_rate
      1.0 + sum(:gold, :ratio, 1.0)
    end

    def steady?
      any?(:steady)
    end

    # ---------------------------------------------------------------- 说明文字
    def cond_text(c)
      return '' unless c
      c.map do |k, v|
        case k
        when :skill, :skills then "用#{Array(v).map { |s| skill_name(s) }.join('、')}时"
        when :active then "启用#{skill_name(v)}时"
        when :sect then "#{SECTS[v]}弟子"
        when :unarmed then v ? '空手时' : '持兵器时'
        when :good then v > 128 ? "道德≥#{v}时" : '正派时'
        when :evil then v < 128 ? "道德<#{v}时" : '邪派时'
        end
      end.join
    end

    def skill_name(id)
      $data_system.variables[id].to_s
    end

    def pct(x)
      "#{(x * 100).round}%"
    end

    def describe(e)
      return e[:text] if e[:text]
      t = case e[:type]
          when :crit then "#{e[:chance]}%几率伤害+#{pct(e[:ratio])}"
          when :power then "伤害+#{pct(e[:ratio])}"
          when :execute then "对方气血不足四分之一时伤害+#{pct(e[:ratio])}"
          when :pierce then '对方防御越高，伤害加得越多'
          when :drain then "回复伤害#{pct(e[:ratio])}的气血"
          when :steal_sp then "回复伤害#{pct(e[:ratio])}的内力"
          when :chase then "#{e[:chance]}%几率顺势再打半击"
          when :poison then "#{e[:chance]}%几率让对方#{label(e) == '灼烧' ? '着火' : '中毒'}#{e[:turns] || 3}回合"
          when :stun then "#{e[:chance]}%几率定住对方"
          when :disarm then "#{e[:chance]}%几率打落对方兵器"
          when :slow then "#{e[:chance]}%几率降低对方闪避"
          when :dodge then "对方普通攻击#{e[:chance]}%落空"
          when :reduce then "普通攻击伤害-#{pct(e[:ratio])}"
          when :skill_reduce then "绝招伤害-#{pct(e[:ratio])}"
          when :cap then "单次受伤不超过最大气血的#{pct(e[:ratio])}"
          when :reflect then "反弹#{pct(e[:ratio])}普通攻击伤害"
          when :counter then "被打中后#{e[:chance]}%几率还手"
          when :guard then '每场一次，气血将尽时保住一口气'
          when :steady then '不会被定身'
          when :regen then "出手前回复#{e[:pct]}%气血"
          when :sp_regen then "出手前回复#{e[:pct]}%内力"
          when :level then "#{skill_name(e[:skill])}战斗中+#{e[:n]}级"
          when :cost then "#{e[:skills] == :all ? '所有绝招' : Array(e[:skills]).map { |s| $data_skills[s].name }.uniq.join('、')}耗内力-#{pct(e[:ratio])}"
          when :escape then '逃跑必定成功'
          when :gold then "战斗所得银两+#{pct(e[:ratio])}"
          when :self_hurt then "出手前自损#{e[:pct]}%气血"
          else ''
          end
      "#{cond_text(e[:when])}#{t}"
    end

    # 一档套装效果：几门武功加同样的级数时合成一句
    def describe_all(effects)
      levels, rest = effects.partition { |e| e[:type] == :level && !e[:when] && !e[:text] }
      parts = levels.group_by { |e| e[:n] }.map { |n, list| "#{list.map { |e| skill_name(e[:skill]) }.join('、')}战斗中+#{n}级" }
      (parts + rest.map { |e| describe(e) }).join('，')
    end

    def effect_line(e)
      n = label(e)
      n.empty? ? describe(e) : "【#{n}】#{describe(e)}"
    end

    # 物品栏的说明分页：描述（按原版 75 字节一页）、各项特效、套装
    PAGE_BYTES = 75
    def help_pages(item)
      kind = item.is_a?(RPG::Weapon) ? :weapon : item.is_a?(RPG::Armor) ? :armor : nil
      lines = []
      if kind
        (kind == :weapon ? @weapons : @armors).fetch(item.id, []).each { |e| lines << effect_line(e) }
        lines.concat(WebLife.rod_lines(item.id)) if kind == :armor && defined?(WebLife)
        if (s = set_of(kind, item.id))
          n = set_count(s)
          lines << "【#{s[:name]}套 #{n}/#{s[:pieces].size}】#{s[:pieces].map { |alts| alts.map { |k, i| (k == :weapon ? $data_weapons : $data_armors)[i].name }.join('或') }.join('、')}"
          s[:tiers].each do |need, effects|
            lines << "#{n >= need ? '●' : '○'}#{need}件：#{describe_all(effects)}"
          end
        end
      end
      pages = split(item.description.to_s)
      lines.each { |l| pages.concat(split(l)) }
      pages = [''] if pages.empty?
      return pages if pages.size == 1
      pages.each_with_index.map { |p, i| "#{i > 0 ? '← ' : ''}#{p}#{i < pages.size - 1 ? ' →' : ''}" }
    end

    # 商店顶栏的一行：描述【特效·特效·某某套】
    def shop_hint(item)
      return '要买什么你自己看看吧！' unless item
      kind = item.is_a?(RPG::Weapon) ? :weapon : item.is_a?(RPG::Armor) ? :armor : nil
      return item.description.to_s unless kind
      tags = (kind == :weapon ? @weapons : @armors).fetch(item.id, []).map { |e| label(e) }.reject(&:empty?)
      if (st = set_of(kind, item.id))
        tags << "#{st[:name]}套"
      end
      tags.empty? ? item.description.to_s : "#{item.description}【#{tags.join('·')}】"
    end

    # 按页宽拆开，尽量断在标点后面
    def split(text)
      out = []
      until text.empty?
        part = RGWeb.bslice(text, 0, PAGE_BYTES)
        part = text[0, 1] if part.empty?
        if part.size < text.size && (cut = part.rindex(/[，、：】]/)) && cut >= part.size / 2
          part = part[0..cut]
        end
        out << part
        text = text[part.size..]
      end
      out
    end
  end
end

#--------------------------------------------------------------------------
# 接入点
#--------------------------------------------------------------------------
class Game_Variables
  def raw(id)
    id <= 5000 && @data[id] ? @data[id] : 0
  end

  # 武学精进：战斗中读武功等级时加上装备的加成；写回时扣掉，存档里的等级不变
  alias __gear_get []
  def [](id)
    v = __gear_get(id)
    b = WebGear.level_bonus[id]
    b && v.is_a?(Integer) && v > 0 ? v + b : v
  end

  alias __gear_set []=
  def []=(id, value)
    b = WebGear.level_bonus[id]
    value = [value - b, 0].max if b && value.is_a?(Integer) && raw(id).to_i > 0
    __gear_set(id, value)
  end
end

class Game_Battler
  alias __gear_attack_effect attack_effect
  def attack_effect(attacker, s_atk1, s_atk2, s_atk3)
    return false if attacker.is_a?(Game_Enemy) && is_a?(Game_Actor) && WebGear.dodge?(self)
    r = __gear_attack_effect(attacker, s_atk1, s_atk2, s_atk3)
    if damage.is_a?(Integer) && damage > 0
      if attacker.is_a?(Game_Actor) && is_a?(Game_Enemy)
        WebGear.after_hit(attacker, self)
      elsif attacker.is_a?(Game_Enemy) && is_a?(Game_Actor)
        WebGear.after_hurt(attacker, self)
      end
    end
    r
  end

  alias __gear_skill_effect skill_effect
  def skill_effect(user, skill, window)
    hp0 = hp
    r = __gear_skill_effect(user, skill, window)
    WebGear.after_skill_hurt(self, hp0 - hp) if user.is_a?(Game_Enemy)
    WebGear.append(WebGear.guard(self))
    r
  end
end

class Game_Actor
  # 定心：不会被定身
  alias __gear_add_state add_state
  def add_state(state_id, force = false)
    return if WebGear::STUN_STATES.include?(state_id) && WebGear.steady?
    __gear_add_state(state_id, force)
  end
end

class Game_Enemy
  # 财运
  alias __gear_gold gold
  def gold
    (__gear_gold * WebGear.gold_rate).to_i
  end
end

module WebSkill
  class << self
    alias __gear_sp_cost sp_cost
    def sp_cost(battler, skill_id)
      c = __gear_sp_cost(battler, skill_id)
      battler.is_a?(Game_Actor) ? (c * WebGear.cost_rate(skill_id)).to_i : c
    end
  end
end

class Window_Item
  def help_pages
    item ? WebGear.help_pages(item).size : 1
  end

  def update_help(help_id = 0)
    pages = item ? WebGear.help_pages(item) : ['']
    @help_window.set_text(pages[help_id % pages.size])
  end
end

# 商店（66RPG 商店脚本）：购买时顶栏原本写死“要买什么你自己看看吧！”，看不到商品说明。
# 改为显示光标所在商品的描述，装备再接上特效与套装名，买之前就知道是什么
class Window_ShopCommand
  def show_hint(text)
    return if text == @hint
    @hint = text
    contents.clear
    contents.draw_text(4, 0, 602, 32, text)
  end
end

class Scene_Shop
  alias __gear_update_buy update_buy
  def update_buy
    __gear_update_buy
    return unless $scene.equal?(self) && $game_temp.shop_type == 1 && @buy_window.active
    @command_window.show_hint(WebGear.shop_hint(@buy_window.item))
  end
end

class Scene_Battle
  alias __gear_start_phase1 start_phase1
  def start_phase1
    WebGear.battle_start
    __gear_start_phase1
  end

  alias __gear_battle_end battle_end
  def battle_end(result)
    WebGear.levels_off
    __gear_battle_end(result)
  end

  alias __gear_update_phase4_step2 update_phase4_step2
  def update_phase4_step2
    WebGear.before_action(@active_battler, @help_window) if @active_battler
    __gear_update_phase4_step2
  end
end

class Scene_Map
  alias __gear_main main
  def main
    WebGear.levels_off                             # 保险：无论战斗怎样结束，回到地图时加成一定撤掉
    __gear_main
  end
end
