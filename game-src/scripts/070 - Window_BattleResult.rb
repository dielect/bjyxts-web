#==============================================================================
# ■ Window_BattleResult
#------------------------------------------------------------------------------
# 　战斗结束时、显示获得的 EXP 及金钱的窗口。
#==============================================================================

class Window_BattleResult < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     gold      : 金钱
  #     trea1     : 宝物1
  #     trea2     : 宝物2
  #     trea3     : 宝物3
  #     trea4     : 宝物4
  #--------------------------------------------------------------------------
  def initialize(gold, trea1="", trea2="", trea3="", trea4="")
    @gold = gold
    @trea1=trea1
    @trea2=trea2
    @trea3=trea3
    @trea4=trea4
    super(160, 0, 320, 224)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.y = 160 - height / 2
    self.z =300
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.color = normal_color
    self.contents.font.color = system_color
    self.contents.draw_text(0,0,320,32,"大获全胜！战斗获得")
    self.contents.draw_text(0,32,192,32,"金钱："+@gold.to_s)
    self.contents.draw_text(0,64,192,32,"物品：")
    self.contents.draw_text(66,64,192,32,@trea1) if @trea1 !=nil
    self.contents.draw_text(66,96,192,32,@trea2) if @trea2 !=nil
    self.contents.draw_text(66,128,192,32,@trea3) if @trea3 !=nil
    self.contents.draw_text(66,160,192,32,@trea4) if @trea4 !=nil
  end
end
