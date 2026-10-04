#----------------------------------------------------------------------------
# ■ Scene_Begin 开场
#----------------------------------------------------------------------------
class Scene_Begin
  CREDIT=<<_b_
    在这件事没发生之前，我一直在平静地生活着；如果这件事没
    
有发生，那么我会依然这样平静地甚至有点单调地继续生活下去。

可是最终它还是发生了，就是现在，在我按下按钮的时候，我启动

了远古大陆英雄坛的时空转换装置。当我从时空扭曲的强大力场中

恢复知觉的时候，我已经来到了这片传说中的神秘土地。这里无法

考证年代，我所来到的地方好像是中原偏西的位置，一个不大不小

的小镇，镇上行人混杂，还算热闹，从他们的交谈中我得知这里叫

“平安小镇”，而当我注视自己的时候才发现，我已经变成了一个

十四岁的少年！                                            

这里有什么秘密？                                          

这里是造就英雄的熔炉或是邪恶的渊源？                      

我不知道，我只知道，从今以后，我的生活将完全改变……      

_b_
end
class Scene_Begin
  def initialize(return_scene = nil)
    @sprite = Sprite.new
    @sprite.bitmap = Bitmap.new("Graphics/Pictures/BG.png")
    @sprite.x = 0
    @sprite.y = 0
    @tit=Sprite.new
    @tit.bitmap=Bitmap.new(640,24)
    color=Color.new(144,176,87)
    temp_rect=@tit.bitmap.rect
    n="===========================序幕==========================="
    @tit.bitmap.fill_rect(temp_rect,color)
    @tit.bitmap.font.color.set(0,0,0)
    @tit.bitmap.draw_text(0,0,640,24,n)
  end
  def scene_start
    credit_lines = CREDIT.split(/\n/)
    @credit_bitmap = Bitmap.new(640,32 * credit_lines.size)
    @credit_bitmap.font.color.set(0,0,0)
    credit_lines.each_index do |i|
      line = credit_lines[i]
      @credit_bitmap.draw_text(0,i * 32,640,32,line,1)
    end
    @credit_sprite = Sprite.new(Viewport.new(0,50,640,380))
    @credit_sprite.bitmap = @credit_bitmap
    @credit_sprite.oy = -430
    @frame_index = 0
    @last_flag = false
  end
  def scene_end
    @credit_bitmap.clear
    @credit_sprite.dispose
    @credit_bitmap.dispose
    @tit.bitmap.clear
    @tit.bitmap.dispose
    @tit.dispose
    @sprite.dispose
  end
  def last?
    return (@frame_index >= @credit_sprite.bitmap.height + 480)
  end
  def last
    if not @last_flag
      Audio.bgm_fade(3000)
      @last_flag = true
      @last_count = 0
    else
      @last_count += 1
    end
    if @last_count >= 15
      command_new_game
    end
  end
  def update
    @frame_index += 1
    return if cancel?
    last if last?
    @credit_sprite.oy += 1
  end
  def cancel?
    if Input.trigger?(Input::B)
      $scene = Scene_Create.new
      return true
    end
    return false
  end
  def main
    scene_start
    Audio.bgm_play("Audio/BGM/开场.mp3") 
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
    scene_end
    command_new_game
  end
end
def command_new_game
  Audio.bgm_stop
  Graphics.frame_count = 0
  $game_temp          = Game_Temp.new
  $game_system        = Game_System.new
  $game_switches      = Game_Switches.new
  $game_variables     = Game_Variables.new
  $game_self_switches = Game_SelfSwitches.new
  $game_screen        = Game_Screen.new
  $game_actors        = Game_Actors.new
  $game_party         = Game_Party.new
  $game_troop         = Game_Troop.new
  $game_map           = Game_Map.new
  $game_player        = Game_Player.new
  # 设置初期同伴位置
  $game_party.setup_starting_members
  # 设置初期位置的地图
  $game_map.setup($data_system.start_map_id)
  # 主角向初期位置移动
  $game_player.moveto($data_system.start_x, $data_system.start_y)
  # 刷新主角
  $game_player.refresh
  # 执行地图设置的 BGM 与 BGS 的自动切换
  $game_map.autoplay
  # 刷新地图 (执行并行事件)
  $game_map.update
  # 切换创建角色画面
  $scene = Scene_Create.new
end
#==============================================================================
# 本脚本来自www.66RPG.com，使用和转载请保留此信息
#============================================================================== 
