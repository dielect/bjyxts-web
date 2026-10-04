#==============================================================================
# ■ Window_Create
#------------------------------------------------------------------------------
# 　角色创建窗口
#==============================================================================
class Window_Create < Window_Base
  
  #--------------------------------------------------------------------------
  # ● 创建“角色创建”窗口
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, 640, 480)
    self.contents = Bitmap.new(width - 32, height - 32)
    @index = 0
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 光标矩形
  #--------------------------------------------------------------------------
  def index=(index)
    @index = index
    self.cursor_rect.set(136, @index * 32 + 96, 240, 32)
  end
  #--------------------------------------------------------------------------
  # ● 标题“角色创建”
  #--------------------------------------------------------------------------
  def draw_header
    self.contents.font.size = 32
    self.contents.font.bold = true
    self.contents.font.color.set(0,0,0)
    self.contents.draw_text(0, 0, 640-32, 32, "角色创建", 1)
    self.contents.font.bold = false
    self.contents.font.size = 24
    self.contents.fill_rect(0, 32, 640, 1, normal_color)
  end
  #--------------------------------------------------------------------------
  # ● 列表描绘
  #--------------------------------------------------------------------------
  def draw_content(actor, x, y)
    draw_actor_name(actor, x, y,true)
    draw_gender(x, y + 32)
    draw_actor_ability(actor, x, y + 64)
    self.contents.draw_text(x, y + 192, 160, 32, "开始创建")
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    draw_header
    draw_content($game_actors[1], 140, 96)
  end
  #--------------------------------------------------------------------------
  # ● 更新窗口
  #--------------------------------------------------------------------------
  def update
    super
    refresh
  end  
  #--------------------------------------------------------------------------
  # ● 四项属性值描绘
  #     actor : 角色
  #     x     : 描画目标 X 坐标
  #     y     : 描画目标 Y 坐标
  #--------------------------------------------------------------------------
  def draw_actor_ability(actor, x, y)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 120, 32, "膂力")
    self.contents.draw_text(x, y+32, 120, 32, "敏捷")
    self.contents.draw_text(x, y+64, 120, 32, "悟性")
    self.contents.draw_text(x, y+96, 120, 32, "根骨")
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 64, y, 160, 32, $game_variables[11].to_s, 2)
    self.contents.draw_text(x + 64, y+32, 160, 32, $game_variables[12].to_s, 2)
    self.contents.draw_text(x + 64, y+64, 160, 32, $game_variables[13].to_s, 2)
    self.contents.draw_text(x + 64, y+96, 160, 32, $game_variables[14].to_s, 2)
      
    self.contents.draw_text(x+200, 96+192, 64, 32, (80-$game_variables[11]-
    $game_variables[12]-$game_variables[13]-$game_variables[14]).abs.to_s)
  end
end