#==============================================================================
# ■ Window_ShopNumber
#------------------------------------------------------------------------------
# 　商店画面、输入买卖数量的窗口。
#==============================================================================

class Window_ShopNumber < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
    super(0, 192, 416, 96)
    self.contents = Bitmap.new(width - 32, height - 32)
    @item = nil
    @max = 1
    @price = 0
    @number = 1
  end
  #--------------------------------------------------------------------------
  # ● 设置物品、最大个数、价格
  #--------------------------------------------------------------------------
  def set(item, max, price)
    @item = item
    @max = max
    @price = price
    @number = 1
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 被输入的件数设置
  #--------------------------------------------------------------------------
  def number
    return @number
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    draw_item_name(@item, 4, 0)
    self.contents.font.color = normal_color
    self.contents.draw_text(172, 0, 32, 32, "×")
    self.contents.draw_text(208, 0, 24, 32, @number.to_s, 2)
    self.cursor_rect.set(204, 0, 32, 32)
    # 描绘合计价格和货币单位
    total_price = @price * @number
    self.contents.font.color = normal_color
    self.contents.draw_text(0, 32, 384, 32, "总价:"+total_price.truncate.to_s, 2)
    self.contents.font.color = system_color
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    super
    if self.active
      # 光标右 (+1)
      if Input.repeat?(Input::RIGHT) and @number < @max
        $game_system.se_play($data_system.cursor_se)
        @number += 1
        refresh
      end
      # 光标左 (-1)
      if Input.repeat?(Input::LEFT) and @number > 1
        $game_system.se_play($data_system.cursor_se)
        @number -= 1
        refresh
      end
      # 光标上 (+10)
      if Input.repeat?(Input::UP) and @number < @max
        $game_system.se_play($data_system.cursor_se)
        @number = [@number + 10, @max].min
        refresh
      end
      # 光标下 (-10)
      if Input.repeat?(Input::DOWN) and @number > 1
        $game_system.se_play($data_system.cursor_se)
        @number = [@number - 10, 1].max
        refresh
      end
    end
  end
end
