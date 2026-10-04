#==============================================================================
# ■ Window_Item
#------------------------------------------------------------------------------
# 　物品画面、战斗画面、显示浏览物品的窗口。
#==============================================================================

class Window_Item < Window_Selectable
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
    @category=self.category
    case @category
    when 0
      # 添加食物
      for i in 1...$data_items.size
        if $game_party.item_number(i) > 0 and $data_items[i].type==0
          @data.push($data_items[i])
        end
      end
    when 1
      # 添加药物
      for i in 1...$data_items.size
        if $game_party.item_number(i) > 0 and $data_items[i].type==1
          @data.push($data_items[i])
        end
      end
    when 2
      # 添加武器
      for i in 1...$data_weapons.size
        if $game_party.weapon_number(i) > 0
          @data.push($data_weapons[i])
        end
      end
    when 3
      # 添加防具
      for i in 1...$data_armors.size
        if $game_party.armor_number(i) > 0
          @data.push($data_armors[i])
        end
      end
    when 4
      # 添加其他
      for i in 1...$data_items.size
        if $game_party.item_number(i) > 0 and $data_items[i].type==2
          @data.push($data_items[i])
        end
      end
    when 5
      # 添加可丢弃物品
      for i in 1...$data_items.size
        if $game_party.item_number(i) > 0 and $data_items[i].id !=19
          @data.push($data_items[i])
        end
      end
      for i in 1...$data_weapons.size
        if $game_party.weapon_number(i) > 0
          if $game_actors[1].weapon_id !=i
            @data.push($data_weapons[i])
          else
            @data.push($data_weapons[i]) if $game_party.weapon_number(i) > 1
          end 
        end
      end
      for i in 1...$data_armors.size
        if $game_party.armor_number(i) > 0
          if $game_actors[1].armor_equiped?(i)
            @data.push($data_armors[i]) if $game_party.armor_number(i) > 1
          else
            @data.push($data_armors[i])
          end
        end
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
    case item
    when RPG::Item
      number = $game_party.item_number(item.id)
    when RPG::Weapon
      number = $game_party.weapon_number(item.id)
    when RPG::Armor
      number = $game_party.armor_number(item.id)
    end
    self.contents.font.color = normal_color
    x = 4
    y = index * 32
    rect = Rect.new(x, y, self.width / @column_max - 32, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    bitmap = RPG::Cache.icon("051-Item_unequip.png")
    if item.is_a?(RPG::Weapon) and $game_actors[1].weapon_id==item.id
      bitmap = RPG::Cache.icon("052-Item_equip.png")
    end
    if item.is_a?(RPG::Armor) and $game_actors[1].armor_equiped?(item.id)
      bitmap = RPG::Cache.icon("052-Item_equip.png")
    end
    opacity = self.contents.font.color == normal_color ? 255 : 128
    self.contents.blt(x, y + 4, bitmap, Rect.new(0, 0, 24, 24), opacity)
    self.contents.draw_text(x + 28, y, 212, 32, item.name, 0)
    self.contents.draw_text(x + 240, y, 16, 32, "×", 1)
    self.contents.draw_text(x + 256, y, 24, 32, number.to_s, 2)
  end
  #--------------------------------------------------------------------------
  # ● 刷新帮助文本
  #--------------------------------------------------------------------------
  def update_help(help_id=0)
    help_text=[]
    text=self.item == nil ? "" : self.item.description
    if text.size<=75
      @help_window.set_text(text)
    else
      help_text[0]=text.slice(0,75)+" →"
      help_text[1]="← "+text.slice(75,text.size-75)
      @help_window.set_text(help_text[help_id])
    end
  end
end