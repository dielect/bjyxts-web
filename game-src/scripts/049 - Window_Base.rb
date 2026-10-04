#==============================================================================
# ■ Window_Base
#------------------------------------------------------------------------------
# 　游戏中全部窗口的超级类。
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     x      : 窗口的 X 坐标
  #     y      : 窗口的 Y 坐标
  #     width  : 窗口的宽
  #     height : 窗口的宽
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super()
    @windowskin_name = $game_system.windowskin_name
    self.windowskin = RPG::Cache.windowskin(@windowskin_name)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.z = 100
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    # 如果窗口的内容已经被设置就被释放
    if self.contents != nil
      self.contents.dispose
    end
    super
  end
  #--------------------------------------------------------------------------
  # ● 获取文字色
  #     n : 文字色编号 (0～7)
  #--------------------------------------------------------------------------
  def text_color(n)
    case n
    when 0
      return Color.new(255, 255, 255, 255)
    when 1
      return Color.new(128, 128, 255, 255)
    when 2
      return Color.new(255, 128, 128, 255)
    when 3
      return Color.new(128, 255, 128, 255)
    when 4
      return Color.new(128, 255, 255, 255)
    when 5
      return Color.new(255, 128, 255, 255)
    when 6
      return Color.new(255, 255, 128, 255)
    when 7
      return Color.new(192, 192, 192, 255)
    else
      normal_color
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取普通文字色
  #--------------------------------------------------------------------------
  def normal_color
    return Color.new(0, 0, 0, 255)
  end
  #--------------------------------------------------------------------------
  # ● 获取无效文字色
  #--------------------------------------------------------------------------
  def disabled_color
    return Color.new(0, 0, 0, 128)
  end
  #--------------------------------------------------------------------------
  # ● 获取系统文字色
  #--------------------------------------------------------------------------
  def system_color
    return Color.new(0, 0, 0, 255)
  end
  #--------------------------------------------------------------------------
  # ● 获取危机文字色
  #--------------------------------------------------------------------------
  def crisis_color
    return Color.new(255, 255, 64, 255)
  end
  #--------------------------------------------------------------------------
  # ● 获取战斗不能文字色
  #--------------------------------------------------------------------------
  def knockout_color
    return Color.new(255, 64, 0)
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    super
    # 如果窗口的外观被变更了、再设置
    if $game_system.windowskin_name != @windowskin_name
      @windowskin_name = $game_system.windowskin_name
      self.windowskin = RPG::Cache.windowskin(@windowskin_name)
    end
  end
  #--------------------------------------------------------------------------
  # ● 图形的描绘
  #     actor : 角色
  #     x     : 描画目标 X 坐标
  #     y     : 描画目标 Y 坐标
  #--------------------------------------------------------------------------
  def draw_actor_graphic(actor, x, y)
    bitmap = RPG::Cache.character(actor.character_name, actor.character_hue)
    cw = bitmap.width / 4
    ch = bitmap.height / 4
    src_rect = Rect.new(0, 0, cw, ch)
    self.contents.blt(x - cw / 2, y - ch, bitmap, src_rect)
  end
  #--------------------------------------------------------------------------
  # ● 名称的描绘
  #     actor : 角色
  #     x     : 描画目标 X 坐标
  #     y     : 描画目标 Y 坐标
  #--------------------------------------------------------------------------
  def draw_actor_name(actor, x, y, opt = false)
    if opt
      self.contents.font.color = system_color
      self.contents.draw_text(x, y, 120, 32, "姓名")
      self.contents.font.color = normal_color
      self.contents.draw_text(x + 64, y, 160, 32, actor.name, 2)
      return
    else
      self.contents.font.color = normal_color
      self.contents.draw_text(x, y, 120, 32, actor.name)
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 性别的描画
  #     actor : 角色
  #     x     : 描画目标 X 坐标
  #     y     : 描画目标 Y 坐标
  #--------------------------------------------------------------------------
  def draw_gender(x, y)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 120, 32, "性别")
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 64, y, 160, 32, $gender, 2)
  end
  #--------------------------------------------------------------------------
  # ● 自动换行文字描绘
  #--------------------------------------------------------------------------
  def draw_words(text,align=0)
    self.contents.clear
    self.contents.font.color = normal_color
    self.visible=true
    x = y = 0
    # 限制文字处理
    begin
      last_text = text.clone
      text.gsub!(/\\[Vv]\[([0-9]+)\]/) { $game_variables[$1.to_i] }
    end until text == last_text
    text.gsub!(/\\[Nn]\[([0-9]+)\]/) do
      $game_actors[$1.to_i] != nil ? $game_actors[$1.to_i].name : ""
    end
    # 为了方便、将 "\\\\" 变换为 "\000" 
    text.gsub!(/\\\\/) { "\000" }
    # "\\C" 变为 "\001" 、"\\G" 变为 "\002"
    text.gsub!(/\\[Cc]\[([0-9]+)\]/) { "\001[#{$1}]" }
    text.gsub!(/\\[Gg]/) { "\002" }
    # c 获取 1 个字 (如果不能取得文字就循环)
    while ((c = text.slice!(/./m)) != nil)
      # \\ 的情况下
      if c == "\000"
        # 还原为本来的文字
        c = "\\"
      end
      # \C[n] 的情况下
      if c == "\001"
        # 更改文字色
        text.sub!(/\[([0-9]+)\]/, "")
        color = $1.to_i
        if color >= 0 and color <= 7
          self.contents.font.color = text_color(color)
        end
        # 下面的文字
        next
      end
      # 另起一行文字的情况下
      if c == "\n"
        # y 加 1
        y += 1
        x = 0
        # 下面的文字
        next
      end
      if (x + 4 + self.contents.text_size(c).width) > self.contents.width
        y += 1
        x = 0
      end
      # 描绘文字
      self.contents.draw_text( x + 4, 32 * y, 40, 32, c)
      # x 为要描绘文字的加法运算
      x += self.contents.text_size(c).width
    end
  end
  #--------------------------------------------------------------------------
  # ● 描绘物品名
  #     item : 物品
  #     x    : 描画目标 X 坐标
  #     y    : 描画目标 Y 坐标
  #--------------------------------------------------------------------------
  def draw_item_name(item, x, y)
    if item == nil
      self.contents.font.color = normal_color
      self.contents.draw_text(x + 20, y, 212, 32, "无")
      return
    end
    bitmap = RPG::Cache.icon(item.icon_name)
    self.contents.blt(x, y + 4, bitmap, Rect.new(0, 0, 24, 24))
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 20, y, 212, 32, item.name)
  end
end