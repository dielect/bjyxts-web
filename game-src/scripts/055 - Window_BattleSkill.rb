#==============================================================================
# ■ Window_BattleSkill
#------------------------------------------------------------------------------
# 　战斗中使用绝招的窗口。
#==============================================================================

class Window_BattleSkill < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
    super(0, 300, 640, 180)
    self.contents = Bitmap.new(width - 32, height - 32)
    @actor=$game_actors[1]
    study_skill
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 获取绝招
  #--------------------------------------------------------------------------
  def skill
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
    for i in 0...@actor.skills.size
      skill = $data_skills[@actor.skills[i]]
      if skill != nil
        @data.push(skill)
      end
    end
    # 如果项目数不是 0 就生成位图、重新描绘全部项目
    @item_max = @data.size
    if @item_max > 0
      self.contents = Bitmap.new(width - 32, row_max * 32)
      for i in 0...@item_max
        draw_item(i)
      end
      self.index=0
    end
  end
  #--------------------------------------------------------------------------
  # ● 描绘项目
  #     index : 项目编号
  #--------------------------------------------------------------------------
  def draw_item(index)
    skill = @data[index]
    self.contents.font.color = normal_color
    x = 4
    y = index * 32
    rect = Rect.new(x, y, self.width - 32, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    bitmap = RPG::Cache.icon(skill.icon_name)
    opacity = self.contents.font.color == normal_color ? 255 : 128
    self.contents.blt(x, y + 4, bitmap, Rect.new(0, 0, 24, 24), opacity)
    self.contents.draw_text(x + 28, y, 204, 32, skill.name, 0)
    self.contents.draw_text(x + 232, y, 48, 32, skill.sp_cost.to_s, 2)
  end
end
