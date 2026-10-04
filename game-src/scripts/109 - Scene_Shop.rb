#==============================================================================
# ■ Scene_Shop
#------------------------------------------------------------------------------
# 　处理商店画面的类。
#      只能购买的商店：
#      在商店前面一行事件添加脚本：$game_temp.shop_type = 1
#      只能卖出的商店：
#      在商店前面一行事件添加脚本：$game_temp.shop_type = 2
#==============================================================================
class Scene_Shop
  def main
    @screen = Spriteset_Map.new
    @command_window = Window_ShopCommand.new
    @gold_window = Window_Gold.new
    @gold_window.x = 0
    @gold_window.y = 416
    #购买窗口
    @buy_window = Window_ShopBuy.new($game_temp.shop_goods)
    @buy_window.active = false
    @buy_window.visible = false
    #卖出窗口
    @sell_window = Window_ShopSell.new
    @sell_window.active = false
    @sell_window.visible = false
    #个数窗口
    @number_window = Window_ShopNumber.new
    @number_window.active = false
    @number_window.visible = false
    @number_window.z=200
    @status_window = Window_ShopStatus.new
    @status_window.visible = false
    if $game_temp.shop_type == 1
      @command_window.index = 0
      @command_window.active = false
      @buy_window.active = true
      @buy_window.visible = true
      @buy_window.refresh
      @status_window.visible = true
      @gold_window.y=$game_temp.shop_goods.size*32+96
      @status_window.y=$game_temp.shop_goods.size*32+96
    else
      @command_window.index = 1
      @command_window.active = false
      @sell_window.active = true
      @sell_window.visible = true
      @status_window.visible = true
      @sell_window.refresh
      @gold_window.x=0
    end
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      if $scene != self
        break
      end
    end
    Graphics.freeze
    @status_window.item = nil
    @status_window.refresh
    @command_window.dispose
    @gold_window.dispose
    @buy_window.dispose
    @sell_window.dispose
    @number_window.dispose
    @status_window.dispose
    @screen.dispose
    $game_temp.shop_type = 1
  end
  # 刷新--------------------------
  def update
    @command_window.update
    @gold_window.update
    @buy_window.update
    @sell_window.update
    @number_window.update
    @status_window.update
    if @command_window.active
      update_command
      return
    end
    if @buy_window.active
      update_buy
      return
    end
    if @sell_window.active
      update_sell
      return
    end
    if @number_window.active
      update_number
      return
    end
  end
  # --------------------------
  def update_command
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      $scene = Scene_Map.new
      return
    end
    if Input.trigger?(Input::C)
      case @command_window.index
      when 0
        $game_system.se_play($data_system.decision_se)
        @command_window.active = false
        @buy_window.active = true
        @buy_window.visible = true
        @buy_window.refresh
        @status_window.visible = true
      when 1
        $game_system.se_play($data_system.decision_se)
        @command_window.active = false
        @sell_window.active = true
        @sell_window.visible = true
        @sell_window.refresh
        @status_window.visible = true
      when 2
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_Map.new
      end
      return
    end
  end
  # --------------------------
  def update_buy
    @status_window.item = @buy_window.item
    if Input.trigger?(Input::B)
      if $game_temp.shop_type == 1
        $game_system.se_play($data_system.cancel_se)
        $scene = Scene_Map.new
      else
        $game_system.se_play($data_system.cancel_se)
        @command_window.active = true
        @buy_window.active = false
        @buy_window.visible = true
        @status_window.visible = false
        @status_window.item = nil
      end
      return
    end
    if Input.trigger?(Input::C)
      @item = @buy_window.item
      if @item == nil or @item.price > $game_party.gold
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      case @item
      when RPG::Item
        number = $game_party.item_number(@item.id)
      when RPG::Weapon
        number = $game_party.weapon_number(@item.id)
      when RPG::Armor
        number = $game_party.armor_number(@item.id)
      end
      if number == 99
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      $game_system.se_play($data_system.decision_se)
      max = @item.price == 0 ? 99 : $game_party.gold / @item.price
      max = [max, 99 - number].min
      @buy_window.active = false
      @buy_window.visible = true
      @number_window.set(@item, max, @item.price)
      @number_window.active = true
      @number_window.visible = true
    end
  end
  # --------------------------
  def update_sell
    @number_window.y=128
    @item = @sell_window.item
    @status_window.item = @item
    if Input.trigger?(Input::B)
      if $game_temp.shop_type == 2
        $game_system.se_play($data_system.cancel_se)
        $scene = Scene_Map.new
      else
        $game_system.se_play($data_system.cancel_se)
        @command_window.active = true
        @sell_window.active = false
        @sell_window.visible = false
        @status_window.visible = false
        @status_window.item = nil
        return
      end
    end
    if Input.trigger?(Input::C)
      @item = @sell_window.item
      if @item == nil
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      $game_system.se_play($data_system.decision_se)
      case @item
      when RPG::Item
        number = $game_party.item_number(@item.id)
      when RPG::Weapon
        number = $game_party.weapon_number(@item.id)
        number-=1 if $game_actors[1].weapon_id==@item.id
      when RPG::Armor
        number = $game_party.armor_number(@item.id)
        number-=1 if $game_actors[1].armor_equiped?(@item.id)
      end
      max = number
      @sell_window.active = false
      #@sell_window.visible = false
      @number_window.set(@item, max, @item.price/2+@item.price/5)
      @number_window.active = true
      @number_window.visible = true
      #@status_window.visible = true
    end
  end
  # --------------------------
  def update_number
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      @number_window.active = false
      @number_window.visible = false
      case @command_window.index
      when 0
        @buy_window.active = true
        @buy_window.visible = true
      when 1
        @sell_window.active = true
        @sell_window.visible = true
      end
      return
    end
    if Input.trigger?(Input::C)
      $game_system.se_play($data_system.shop_se)
      @number_window.active = false
      @number_window.visible = false
      case @command_window.index
      when 0
        $game_party.lose_gold(@number_window.number * @item.price)
        case @item
        when RPG::Item
          $game_party.gain_item(@item.id, @number_window.number)
        when RPG::Weapon
          $game_party.gain_weapon(@item.id, @number_window.number)
        when RPG::Armor
          $game_party.gain_armor(@item.id, @number_window.number)
        end
        @gold_window.refresh
        @buy_window.refresh
        @status_window.refresh
        @buy_window.active = true
        @buy_window.visible = true
      when 1
        $game_party.gain_gold(@number_window.number * (@item.price/2+@item.price/5))
        case @item
        when RPG::Item
          $game_party.lose_item(@item.id, @number_window.number)
        when RPG::Weapon
          $game_party.lose_weapon(@item.id, @number_window.number)
        when RPG::Armor
          $game_party.lose_armor(@item.id, @number_window.number)
        end
        @gold_window.refresh
        @sell_window.refresh
        @status_window.refresh
        @sell_window.active = true
        @sell_window.visible = true
        @status_window.visible = true
      end
      return
    end
  end
end