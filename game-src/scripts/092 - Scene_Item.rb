#==============================================================================
# ■ Scene_Item
#------------------------------------------------------------------------------
# 　处理物品画面的类。
#==============================================================================

class Scene_Item
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #--------------------------------------------------------------------------
  def initialize(menu=false)
    @actor=$game_actors[1]
  end
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    draw_main_menu
    @screen = Spriteset_Map.new
    # 生成分类窗口
    @category_window=Window_Command.new(96,["食物","药物","武器","装备","其他","丢弃"],1)
    @category_window.x=0
    @category_window.y=64
    @category_window.index=0
    # 生成帮助窗口、物品窗口
    @help_window = Window_Help.new
    @help_window.y=416
    @item_window = Window_Item.new
    @item_window.y=64
    # 关联帮助窗口
    @item_window.help_window = @help_window
    @help_window.visible=false
    @item_window.active=false
    #@help_window.contents.clear
    @category_window.active=true
    # 执行过度
    Graphics.transition
    # 主循环
    loop do
      # 刷新游戏画面
      Graphics.update
      # 刷新输入信息
      Input.update
      # 刷新画面
      update
      # 如果画面切换就中断循环
      if $scene != self
        break
      end
    end
    # 装备过渡
    Graphics.freeze
    # 释放窗口
    @screen.dispose
    @category_window.dispose
    @help_window.dispose
    @item_window.dispose
    @top_menu.dispose
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    # 刷新窗口
    @help_window.update
    @help_window.visible=false
    @category_window.update
    @item_window.category=@category_window.index
    @item_window.update
    @item_window.refresh
    update_item
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (物品窗口被激活的情况下)
  #--------------------------------------------------------------------------
  def update_item
    if @category_window.active
      @item_window.category=@category_window.index
      @item_window.update
      if Input.trigger?(Input::B)
        # 演奏取消 SE
        $game_system.se_play($data_system.cancel_se)
        # 切换到菜单画面
        $scene = Scene_Menu.new(1)
        return
      end
      if Input.trigger?(Input::C)
        @category_window.active=false
        @item_window.active=true
        @item_window.index=0
        if @item_window.item==nil
          $game_system.se_play($data_system.buzzer_se)
          return_category
          return
        end
        $game_system.se_play($data_system.decision_se)
        @item_window.refresh
        @help_window.visible=true
      end
    else
      if @item_window.active
        # 按下 B 键的情况下
        if Input.trigger?(Input::B)
          # 演奏取消 SE
          $game_system.se_play($data_system.cancel_se)
          # 切换到分类
          return_category
          return
        end
        # 按下 C 键的情况下
        if Input.trigger?(Input::C)
          # 获取物品窗口当前选中的物品数据
          @item = @item_window.item
          # 武器窗口处理
          unless @category_window.index !=2
            equip_weapon
            return
          end
          # 装备窗口处理
          unless @category_window.index !=3
            equip_armor
            return
          end
          # 丢弃窗口处理
          unless @category_window.index !=5
            drop_item
            return
          end
          # 不能使用的情况下
          unless $game_party.item_can_use?(@item.id)
            # 演奏冻结 SE
            $game_system.se_play($data_system.buzzer_se)
            return
          end
          # 如果物品用完的情况下
          if $game_party.item_number(@item.id) == 0
            # 演奏冻结 SE
            $game_system.se_play($data_system.buzzer_se)
            return
          end
          # 演奏物品使用时的 SE
          $game_system.se_play(@item.menu_se)
          # 消耗品的情况下
          if @item.consumable
            # 使用的物品数减 1
            $game_party.lose_item(@item.id, 1)
            # 再描绘物品窗口的项目
            @item_window.draw_item(@item_window.index)
          end
          # 公共事件 ID 有效的情况下
          if @item.common_event_id > 0
            a=@item.common_event_id
            if (a>=19 and a<=22) or a==9
              # 预约调用公共事件
              $game_temp.common_event_id = a
              $scene=Scene_Map.new
            else
              common_event=Game_CommonEvent.new(@item.common_event_id)
              list=common_event.list
              event_interpreter=Interpreter.new
            end
            if event_interpreter != nil
              # 如果不是在执行中就设置
              unless event_interpreter.running?
                event_interpreter.setup(list, @item.common_event_id)
              end
              # 更新解释器
              event_interpreter.update
            end
          end
          return_category
        end
        return
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 返回分类
  #--------------------------------------------------------------------------
  def return_category
    @item_window.refresh
    @item_window.active=false
    @item_window.index=-1
    @category_window.active=true
    @help_window.visible=false
  end
  #--------------------------------------------------------------------------
  # ● 武器窗口
  #--------------------------------------------------------------------------
  def equip_weapon
    if $game_actors[1].weapon_id==@item.id
      @actor.equip(0,0)
    else
      @actor.equip(0,@item.id)
    end
    $game_system.se_play($data_system.equip_se)
    return_category
  end
  #--------------------------------------------------------------------------
  # ● 装备窗口
  #--------------------------------------------------------------------------
  def equip_armor
    if  $game_actors[1].armor_equiped?(@item.id)
      @actor.equip(@item.kind+1,0)
    else
      @actor.equip(@item.kind+1,@item.id)
    end
    $game_system.se_play($data_system.equip_se)
    #@item_window.draw_item(@item_window.index)
    return_category
  end
  #--------------------------------------------------------------------------
  # ● 丢弃物品
  #--------------------------------------------------------------------------
  def drop_item
    $game_system.se_play($data_system.decision_se)
    id=@item.id
    case @item
    when RPG::Item
      $game_party.gain_item(id,-99)
    when RPG::Weapon
      if $game_actors[1].weapon_id==id 
        $game_party.gain_weapon(id,1-$game_party.weapon_number(id))
      else
        $game_party.gain_weapon(id,-99)
      end
    when RPG::Armor
      if $game_actors[1].armor_equiped?(id)
        $game_party.gain_armor(id,1-$game_party.armor_number(id))
      else
        $game_party.gain_armor(id,-99)
      end
    end
    $game_system.se_play($data_system.decision_se)
    @item_window.draw_item(@item_window.index)
    return_category
  end
end