#==============================================================================
# ■ Scene_Skill
#------------------------------------------------------------------------------
# 　处理特技画面的类。
#==============================================================================

class Scene_Skill
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     actor_index : 角色索引
  #--------------------------------------------------------------------------
  def initialize(menu=false)
    @menu=menu
    @actor=$game_actors[1]
  end
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    draw_main_menu
    @screen = Spriteset_Map.new
    # 生成窗口
    @help_window=Window_Help.new
    @help_window.x=96
    @help_window.y=416
    @help_window.width=544
    @category_window=Window_Command.new(96,["拳脚","兵刃","轻功","内功","招架","知识"],1)
    @category_window.x=0
    @category_window.y=64
    @category_window.index=0
    @item_window=Window_Skill.new
    # 关联帮助窗口
    @item_window.help_window = @help_window
    @item_window.active=false
    @help_window.visible=false
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
        $scene = Scene_Menu.new(2)
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
          @item_window.refresh
          return
        end
        # 按下 C 键的情况下
        if Input.trigger?(Input::C)
          # 获取物品窗口当前选中的物品数据
          @item = @item_window.item
          if @category_window.index==5 or $data_system.variables[@item]["基本"] != nil
            $game_system.se_play($data_system.buzzer_se)
            return
          end
          # 演奏装备 SE
          $game_system.se_play($data_system.equip_se)
          if @item==$game_variables[29+@category_window.index]
            $game_variables[29+@category_window.index]=0
          else
            $game_variables[29+@category_window.index]=@item
          end
          return_category
          return
        end
      end
    end
  end
end
          