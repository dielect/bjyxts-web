class Scene_ThrowBall
  def main
    Audio.bgm_play("Audio/BGM/投篮.mp3",100,100)
    @score=0
    @dir=1 #1:right 2:left
    @step=1
    @ball_x=114
    @other_ball_x=155
    @other_ball_y=220
    @help_window = Window_Help.new
    @help_window.y=416
    #@help_window.opacity=160
    @char_pic=Bitmap.new("Graphics/Characters/"+$game_party.actors[0].character_name)
    ch = @char_pic.rect.height / 4
    @right_char_rect=Rect.new(0,2*ch,@char_pic.rect.width / 4,ch)
    @main_window=Window_Base.new(0,0,640,416)
    @main_window.contents=Bitmap.new(608,384)
    @main_window.contents.font.color.set(0,0,0)
    @wrong=0
    Graphics.frame_rate = 40
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      if $scene != self
        break
      end
    end
    #Detect.make_snapshot
    Graphics.freeze
    Graphics.frame_rate = 40
    @main_window.dispose
    @help_window.dispose
  end
  def update
    @main_window.contents.clear
    update_main
    if Input.trigger?(Input::B)
      Audio.bgm_stop
      $scene = Scene_Map.new
      Audio.bgm_play("Audio/BGM/失落的世界1.mp3",100,100)
      return
    end
    if Input.trigger?(Input::C)
      case @step
      when 1
        @step=2
      when 2
        if @ball_x>107 and @ball_x<121
          @step=3
          @score+=10
        else
          @step=1
          @ball_x=114
          @wrong +=1
          for i in 0..10
            Graphics.update
          end
          if @wrong==7
            Audio.bgm_stop
            $scene = Scene_Map.new
            Audio.bgm_play("Audio/BGM/失落的世界1.mp3",100,100)
            return
          end
        end
      end
    end
    $game_variables[156]=@score if $game_variables[156]<@score
    update_score
  end
  def update_score
    @help_window.set_text("SCORE:"+@score.to_s+"    TOP:"+
      $game_variables[156].to_s,1)
  end
  def update_main
    draw_frame
    update_ball
  end
  def draw_frame
    @main_window.contents.fill_rect(450, 100, 2, 210,Color.new(0,0,0))
    @main_window.contents.fill_rect(400, 85, 2, 60,Color.new(0,0,0))
    @main_window.contents.fill_rect(400, 105, 50, 1,Color.new(0,0,0))
    @main_window.contents.fill_rect(400, 135, 50, 1,Color.new(0,0,0))
    @main_window.contents.fill_rect(370, 125, 30, 1,Color.new(0,0,0))
    @main_window.contents.fill_rect(375, 135, 20, 1,Color.new(0,0,0))
    @main_window.contents.fill_rect(375, 125, 1, 17,Color.new(0,0,0))
    @main_window.contents.fill_rect(395, 125, 1, 17,Color.new(0,0,0))
    @main_window.contents.fill_rect(20, 310, 568, 1,Color.new(0,0,0))
    @main_window.contents.blt(125,265,@char_pic,@right_char_rect)
    @main_window.contents.fill_rect(50, 60, 150, 1,Color.new(0,0,0))
    @main_window.contents.fill_rect(50, 83, 150, 1,Color.new(0,0,0))
    @main_window.contents.fill_rect(50, 60, 1, 23,Color.new(0,0,0))
    @main_window.contents.fill_rect(200, 60, 1, 24,Color.new(0,0,0))
    @main_window.contents.fill_rect(115, 83, 1, 5,Color.new(0,0,0))
    @main_window.contents.fill_rect(135, 83, 1, 5,Color.new(0,0,0))
  end
  def update_ball
    case @step
    when 1
      @other_ball_x=155
      @ball_x=114
      @main_window.contents.draw_text(@ball_x,56,32,32,"◎")
      @main_window.contents.draw_text(@other_ball_x,283,32,32,"◎")
    when 2
      case @dir
      when 1
        @ball_x+=rand(4)+1
        @dir=2 if @ball_x>=178
      when 2
        @ball_x-=rand(4)+1
        @dir=1 if @ball_x<=53
      end
      @main_window.contents.draw_text(@ball_x,56,32,32,"◎")
      @main_window.contents.draw_text(@other_ball_x,283,32,32,"◎")
    when 3
      @main_window.contents.draw_text(@ball_x,56,32,32,"◎")
      y=get_ball_y
      @main_window.contents.draw_text(@other_ball_x,y,32,32,"◎")
      @other_ball_x+=2 if @other_ball_x<375
      #@main_window.contents.draw_text(375,100,32,32,"◎")
    end
  end
  def get_ball_y
    if @other_ball_x==155
      @other_ball_y=100
      return 283
    end
    if @other_ball_x==375
      @other_ball_y+=2
      @step=1 if @other_ball_y>=283
      return @other_ball_y
    end
    ss=(375-@other_ball_x)**2
    ss*=0.004162330905
    return ss+95
  end
end