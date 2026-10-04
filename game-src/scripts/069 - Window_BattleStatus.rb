#==============================================================================
# ■ Window_BattleStatus
#------------------------------------------------------------------------------
# 　显示战斗画面同伴状态的窗口。
#==============================================================================

class Window_BattleStatus < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
    super(0, 200, 640, 128)
    self.contents = Bitmap.new(width - 32, height - 32)
    @actor = $game_party.actors[0]
    @org_maxhp=100+$game_variables[24]/4
    @org_maxhp+=[($game_variables[157]-14)*20,300].min
    @enemy=$game_troop.enemies[0]
    @s=@enemy.id
    self.z=170
    @level_up_flags = [false, false, false, false]
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    super
  end
  #--------------------------------------------------------------------------
  # ● 设置升级标志
  #     actor_index : 角色索引
  #--------------------------------------------------------------------------
  def level_up(actor_index)
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.size = 18
    @item_max = 1
    self.contents.font.bold = false
    self.contents.font.color = Color.new(0,0, 0, 255)
    self.contents.font.color =Color.new(0,0, 0, 255)
    draw_HP1(@actor, 0, 24)
    draw_SP1(@actor, 0, 48) if @actor.maxsp>0
    draw_HP2(@enemy, 320, 24)
    draw_SP2(@enemy, 320, 48) if @enemy.maxsp>0
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    super
  end
  def draw_HP1(actor,x, y, w1=100)
    # 边框
    kw=[w1 * actor.maxhp / @org_maxhp,w1].min
    self.contents.fill_rect(x+28, y+25, kw, 2, Color.new(0,0,0,255))
    # 条长度
    w = [w1 * actor.hp / @org_maxhp,w1].min
    # 条颜色
    self.contents.fill_rect(x+28, y+16, w,6, Color.new(0,0, 0, 255))
    self.contents.draw_text(x+136,y+6,216,32,actor.hp.to_s+"/"+actor.maxhp.to_s)
  end
  def draw_SP1(actor,x, y, w1=100)
    # 边框
    self.contents.fill_rect(x+28, y+25, w1, 2, Color.new(0,0,0,255))
    # 条长度
    w = [w1 * actor.sp / $game_variables[24],100].min
    # 条颜色
    self.contents.fill_rect(x+28, y+16, w,6, Color.new(0,0, 0, 255))
    self.contents.draw_text(x+136,y+6,216,32,actor.sp.to_s+"/"+$game_variables[24].to_s)
  end
  def draw_HP2(actor,x, y, w1=100)
    # 边框
    self.contents.fill_rect(x+28, y+25, w1,2, Color.new(0, 0, 0, 255))
    # 条长度
    w = [w1 * actor.hp / actor.maxhp,100].min
    # 条颜色
    self.contents.fill_rect(x+28, y+16, w,6, Color.new(0,0, 0, 255))
  end
  def draw_SP2(actor,x,y, w1=100)
    # 边框
    self.contents.fill_rect(x+28, y+25, w1, 2, Color.new(0,0,0,255))
    # 条长度
    w = [w1 * actor.sp / actor.maxsp,100].min
    # 条颜色
    self.contents.fill_rect(x+28, y+16, w,6, Color.new(0,0, 0, 255))
  end
end
