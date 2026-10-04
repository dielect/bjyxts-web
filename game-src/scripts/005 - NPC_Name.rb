class Draw_event_name
  attr_reader :n
  def initialize
    get_name
    draw
  end
  def get_name
    @name=$game_map.events[$game_system.map_interpreter.event_id].event.name
    $game_actors[2].name=""
    $game_actors[2].name=@name
    if @name=="恶人"
      @name=$game_actors[6].name
      get_npc_data(125)
    end
  end
  def draw
    v=Viewport.new(80,280,@name.size*8,24)
    @n=Sprite.new(v)
    @n.bitmap = Bitmap.new(@name.size*8, 24)
    color=Color.new(144,176,87)
    temp_rect=@n.bitmap.rect
    @n.bitmap.fill_rect(temp_rect,color)
    @n.bitmap.font.color.set(0,0,0)
    @n.bitmap.draw_text(0,0,@name.size*8,24,@name)
  end
  def clear
    if @n!=nil
      @n.contents.clear
    end
  end
  def dispose
    if @n != nil 
      @n.dispose
    end
    @n=nil
  end
end