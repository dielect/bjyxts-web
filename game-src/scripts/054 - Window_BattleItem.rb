#==============================================================================
# ■ Window_BattleItem
#------------------------------------------------------------------------------
# 　战斗中使用物品的窗口。
#==============================================================================

class Window_BattleItem < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, 288, 128)
    @category_window=Window_Command.new(96,["药物"],1)
    @category_window.x=128
    @category_window.y=176
    @category_window.height=128
    @category_window.z=500
    @category_window.active=false
    self.x=224
    self.y=176
    self.z=500
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 获取物品
  #--------------------------------------------------------------------------
  def item
    return @data[self.index]
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    if self.contents != nil
      self.contents.dispose
      self.contents = nil
    end
    @data = []
    # 添加药物
    for i in 1...$data_items.size
      if $game_party.item_number(i) > 0 and $data_items[i].type==1
        @data.push($data_items[i])
      end
    end
    # 如果项目数不是 0 就生成位图、重新描绘全部项目
    @item_max = @data.size
    if @item_max > 0
      self.contents = Bitmap.new(width - 32, height - 32)
      for i in 0...@item_max
        draw_item(i)
      end
      self.index=0
    else
      self.active=false
    end
  end
  #--------------------------------------------------------------------------
  # ● 描绘项目
  #     index : 项目编号
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    number = $game_party.item_number(item.id)
    self.contents.font.color = normal_color
    x = 4
    y = index * 32
    rect = Rect.new(x, y, 256, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    bitmap = RPG::Cache.icon(item.icon_name)
    opacity = self.contents.font.color == normal_color ? 255 : 128
    self.contents.blt(x, y + 4, bitmap, Rect.new(0, 0, 24, 24), opacity)
    self.contents.draw_text(x + 28, y, 128, 32, item.name, 0)
    self.contents.draw_text(x + 140, y, 16, 32, "×", 1)
    self.contents.draw_text(x + 200, y, 24, 32, number.to_s, 2)
  end
  #--------------------------------------------------------------------------
  # ● 释放窗口
  #--------------------------------------------------------------------------
  def dispose
    super
    @category_window.dispose
  end
end
