#==============================================================================
# ■ Window_ShopStatus
#------------------------------------------------------------------------------
# 　商店画面、显示物品价格的窗口。
#==============================================================================

class Window_ShopStatus < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize
    super(208, 416, 208, 64)
    self.contents = Bitmap.new(width - 32, height - 32)
    @item = nil
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    if @item == nil
      return
    end
    case @item
    when RPG::Item
      price = $data_items[@item.id].price
    when RPG::Weapon
      price = $data_weapons[@item.id].price
    when RPG::Armor
      price = $data_armors[@item.id].price
    end
    if $game_temp.shop_type==2
      price*=7
      price/=10
    end
    self.contents.font.color = system_color
    self.contents.draw_text(0, 0, 72, 32, "价格:")
    self.contents.font.color = normal_color
    self.contents.draw_text(60, 0, 114, 32, price.to_s, 2)
  end
  #--------------------------------------------------------------------------
  # ● 设置物品
  #     item : 新的物品
  #--------------------------------------------------------------------------
  def item=(item)
    if @item != item
      @item = item
      refresh
    end
  end
end