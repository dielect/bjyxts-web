#==============================================================================
# ■ Window_Skill
#------------------------------------------------------------------------------
# 　特技画面、战斗画面、显示可以使用的特技浏览的窗口。
#==============================================================================

class Window_Skill < Window_Selectable
  attr_accessor :category
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
    super(96, 64, 544, 352)
    @column_max = 1
    @category=0
    refresh
  end  
  #--------------------------------------------------------------------------
  # ● 获取技能
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
    @category=self.category
    case @category
    when 0
      # 添加拳脚
      if $game_variables[40]>0
        @data.push 40
      end
      for i in 53..60
        @data.push i if $game_variables[i]>0
      end
    when 1
      # 添加兵刃
      for i in 41..44
        @data.push i if $game_variables[i]>0
      end
      @data.push 39 if $game_variables[39]>0
      for i in 85..89
        @data.push i if $game_variables[i]>0
      end
      for i in 80..83
        @data.push i if $game_variables[i]>0
      end
    when 2 
      # 添加轻功
      @data.push 46 if $game_variables[46]>0
      for i in 64..69
        @data.push i if $game_variables[i]>0
      end
    when 3 
      # 添加内功
      @data.push 45 if $game_variables[45]>0
      for i in 72..77
        @data.push i if $game_variables[i]>0
      end
    when 4 
      # 添加招架
      @data.push 47 if $game_variables[47]>0
      for i in 29..30
        a=$game_variables[i]
        @data.push a if $game_variables[a]>0
      end
    when 5
      # 添加知识
      for i in 48..52
        @data.push i if $game_variables[i]>0
      end
    end
    # 如果项目数不是 0 就生成位图、重新描绘全部项目
    @item_max = @data.size
    if @item_max > 0
      self.contents = Bitmap.new(width - 32, row_max * 32)
      for i in 0...@item_max
        draw_item(i)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 描绘项目
  #     index : 项目编号
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    self.contents.font.color = normal_color
    x = 4
    y = index * 32
    rect = Rect.new(x, y, self.width / @column_max - 32, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    if item==$game_variables[29+@category]
      bitmap = RPG::Cache.icon("052-Item_equip.png")
    else
      bitmap = RPG::Cache.icon("051-Item_unequip.png")
    end
    opacity = self.contents.font.color == normal_color ? 255 : 128
    self.contents.blt(x, y + 4, bitmap, Rect.new(0, 0, 24, 24), opacity)
    self.contents.draw_text(x + 28, y, 212, 32, $data_system.variables[item], 0)
  end
  #--------------------------------------------------------------------------
  # ● 刷新帮助文本
  #--------------------------------------------------------------------------
  def update_help
    if @data[self.index]!=nil
      @help_window.set_text($data_system.variables[@data[self.index]]+"  "+
      $game_variables[@data[self.index]].to_s+"/"+
      $game_variables[@data[self.index]+60].to_s+"  "+
      $levels[$game_variables[@data[self.index]]/5])
    else
      @help_window.set_text("")
    end
  end
end
