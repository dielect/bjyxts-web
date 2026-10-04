#==============================================================================
# 本脚本来自www.66RPG.com，使用和转载请保留此信息
#============================================================================== 
#==============================================================================
# ■ Window_Command
#
#     与Window_Command功能一致,不同点就是可以自己给定行、列的值，使菜单像轩辕剑
# 系列的排列……
#
# 举例：                            行  列               -命令列表-
#      Window_Command.new(160, ["攻击","法术","物品","绝技","防御","逃跑"],2)
#==============================================================================
#==============================================================================
# ■ Window_Command
#------------------------------------------------------------------------------
# 　一般的命令选择行窗口。
#==============================================================================

class Window_Command < Window_Selectable
 #--------------------------------------------------------------------------
 # ● 初始化对像
 #     width    : 每格的的宽
 #     row      : 行数   自己根据命令数算好行列的值
 #     column   : 列数
 #     commands : 命令字符串序列
 #--------------------------------------------------------------------------
 def initialize(width, commands, column=1)
   row = commands.size / column
   # 由命令的个数计算出窗口的宽和高
   super(0, 0, width,row * 32 + 32)
   @item_max = commands.size
   @commands = commands
   @row = row
   @width_txt = (width-32)/column
   @column_max = column
   self.contents = Bitmap.new(width-32, row * 32)
   refresh
   self.index = 0
 end
 #--------------------------------------------------------------------------
 # ● 刷新
 #--------------------------------------------------------------------------
 def refresh
   self.contents.clear
   self.contents.font.size = 24
   for i in 0...@item_max
     draw_item(i, normal_color)
   end
 end
 #--------------------------------------------------------------------------
 # ● 描绘项目
 #     index : 项目编号
 #     color : 文字色
 #--------------------------------------------------------------------------
 def draw_item(index, color)
   self.contents.font.color = color
   # 计算得出当前index所对应的内容所在的行
   row_index = index / @column_max
   # 根据余数得出所在的列
   for y in 0...@column_max
     if index % @column_max == y
       rect = Rect.new(y * @width_txt, 32 * row_index , @width_txt, 32)
       self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
       self.contents.draw_text(rect, @commands[index],1)
       break
     end
   end
 end
 #--------------------------------------------------------------------------
 # ● 项目无效化
 #     index : 项目编号
 #--------------------------------------------------------------------------
 def disable_item(index)
   draw_item(index, disabled_color)
 end
 #--------------------------------------------------------------------------
 # ● 项目有效化
 #     index : 项目编号
 #--------------------------------------------------------------------------
 def able_item(index)
   draw_item(index, normal_color)
 end
  #--------------------------------------------------------------------------
  # ● 更新光标矩形
  #--------------------------------------------------------------------------
  def update_cursor_rect
    # 光标位置不满 0 的情况下
    if @index < 0
      self.cursor_rect.empty
      return
    end
    # 获取当前的行
    row = @index / @column_max
    # 当前行被显示开头行前面的情况下
    if row < self.top_row
      # 从当前行向开头行滚动
      self.top_row = row
    end
    # 当前行被显示末尾行之后的情况下
    if row > self.top_row + (self.page_row_max - 1)
      # 从当前行向末尾滚动
      self.top_row = row - (self.page_row_max - 1)
    end
    # 计算光标的宽
    cursor_width = @width_txt
    # 计算光标坐标
    x = @index % @column_max * cursor_width
    y = @index / @column_max * 32 - self.oy
    # 更新光标矩形
    self.cursor_rect.set(x, y, @width_txt, 32)
  end
end
#==============================================================================
# 本脚本来自www.66RPG.com，使用和转载请保留此信息
#==============================================================================