class Scene_Dance
  def initialize
    $game_temp.map_bgm = $game_system.playing_bgm
    Audio.bgs_stop
  end
  def main
    @count=0
    @hit=false
    @score=0
    @help_window = Window_Help.new
    @help_window.y=416
    @backgound=Sprite.new
    @backgound.bitmap = Bitmap.new("Graphics/Pictures/BG")
    @char_pic=$game_party.actors[0].character_name
    @dir_window=Window_Base.new(0,0,640,96)
    @dir_window.contents=Bitmap.new(608,64)
    @char_window=Window_Base.new(320,96,320,320)
    @char_window.contents=Bitmap.new(288,288)
    @pad_window=Window_Base.new(0,96,320,320)
    @pad_window.contents=Bitmap.new(288,288)
    bitmap = RPG::Cache.picture("PAD")
    @pad_window.contents.blt(98, 98, bitmap, Rect.new(0, 0, 93, 93),255)
    @char_pic=Bitmap.new("Graphics/Characters/"+@char_pic)
    cw = @char_pic.rect.width / 4
    ch = @char_pic.rect.height / 4
    @up_char_rect=Rect.new(3*cw,3*ch,cw,ch)
    @left_char_rect=Rect.new(cw,ch,cw,ch)
    @right_char_rect=Rect.new(cw,2*ch,cw,ch)
    @down_char_rect=Rect.new(0,0,cw,ch)
    @dir_pic=Bitmap.new("Graphics/Pictures/Dir")
    @last_rect=@down_char_rect
    Graphics.frame_rate =40
    Audio.bgm_play("Audio/BGM/跳舞.mp3",100,100)
    # 执行过渡
    Graphics.transition
    # 主循环
    loop do
      # 刷新游戏画面
      Graphics.update
      # 刷新输入情报
      Input.update
      # 刷新画面
      update
      # 如果画面切换的话就中断循环
      if $scene != self
        break
      end
    end
    # 准备过渡
    #Detect.make_snapshot
    Graphics.freeze
    Graphics.frame_rate =40
    # 释放窗口
    @help_window.dispose
    @backgound.bitmap.dispose
    @backgound.dispose
    @pad_window.dispose
    @char_window.dispose
    @dir_window.dispose
  end
  def update_score
    @help_window.set_text("SCORE:"+@score.to_s+"    TOP:"+
      $game_variables[155].to_s,1)
  end
  def update
    if @count==0
      make_new_dir
    else
      @count-=1
    end
    if Input.trigger?(Input::B)
      Audio.bgm_stop
      $scene = Scene_Map.new
      Audio.bgm_play("Audio/BGM/失落的世界1.mp3",100,100)
      return
    end
    update_dir
    update_char
    if Input.repeat?(Input::LEFT)
      if @char_status==0 and @count>4
        @char_status=1
        @char_status_count=28
        if @dir==1
          @score+=3 
        else
          Audio.bgm_stop
          $scene = Scene_Map.new
          Audio.bgm_play("Audio/BGM/失落的世界1.mp3",100,100)
          return
        end
      end
    end
    if Input.repeat?(Input::UP)
      if @char_status==0 and @count>4
        @char_status=2
        @char_status_count=28
        if @dir==2
          @score+=3 
        else
          Audio.bgm_stop
          $scene = Scene_Map.new
          Audio.bgm_play("Audio/BGM/失落的世界1.mp3",100,100)
          return
        end
      end
    end
    if Input.repeat?(Input::DOWN)
      if @char_status==0 and @count>4
        @char_status=3
        @char_status_count=28
        if @dir==3
          @score+=3 
        else
          Audio.bgm_stop
          $scene = Scene_Map.new
          Audio.bgm_play("Audio/BGM/失落的世界1.mp3",100,100)
          return
        end
      end
    end
    if Input.repeat?(Input::RIGHT)
      if @char_status==0 and @count>4
        @char_status=4
        @char_status_count=28
        if @dir==4
          @score+=3
        else
          Audio.bgm_stop
          $scene = Scene_Map.new
          Audio.bgm_play("Audio/BGM/失落的世界1.mp3",100,100)
          return
        end
      end
    end
    $game_variables[155]=@score if @score>$game_variables[155]
    update_score
  end
  def update_dir
    @dir_window.contents.clear
    case @dir
    #left
    when 1
      @dir_window.contents.blt(39,10,@dir_pic,Rect.new(31,0,31,31))
    #up
    when 2
      @dir_window.contents.blt(192,10,@dir_pic,Rect.new(0,0,31,31))
    #down
    when 3
      @dir_window.contents.blt(343,10,@dir_pic,Rect.new(62,0,31,31))
    #right
    when 4
      @dir_window.contents.blt(495,10,@dir_pic,Rect.new(93,0,31,31))
    end
  end
  def update_char
    @char_window.contents.clear
    @char_window.contents.fill_rect(20, 220, 288, 1,Color.new(0,0,0))
    if @char_status_count >0
      #@char_status=0
    #else
      @char_status_count-=1
    end
    case @char_status
    when 0
      @char_window.contents.blt(144,175,@char_pic,@last_rect)
    when 1
      @char_window.contents.blt(144,175,@char_pic,@left_char_rect)
      @last_rect=@left_char_rect
    when 2
      @char_window.contents.blt(144,175,@char_pic,@up_char_rect)
      @last_rect=@up_char_rect
    when 3
      @char_window.contents.blt(144,175,@char_pic,@down_char_rect)
      @last_rect=@down_char_rect
    when 4
      @char_window.contents.blt(144,175,@char_pic,@right_char_rect)
      @last_rect=@right_char_rect
    end
  end
  def make_new_dir
    new_dir=@dir
    while new_dir==@dir
      new_dir=rand(4)+1
    end
    @dir=new_dir
    @count=28
    @char_status=0
    @char_status_count=0
  end
end