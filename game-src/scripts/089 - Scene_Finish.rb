#----------------------------------------------------------------------------
# ■ Scene_Finish 
#    结局字幕
#----------------------------------------------------------------------------
class Scene_Finish
  $credit=[]
  $credit[2]=<<_END_
道德和尚：你赢了。但是请施主记住，正义终将战胜邪恶。

只可惜你却看不到那一天了。                          
          
我慢慢走近，一刀劈了下去。                          

就象砍进棉花里，没有任何声音，道德和尚在一瞬间消失  

了。难道说。。。                                    

轰－！                                              

我惊异地发现，这一刀斩在了时空转换装置上。          
    
周围的景物在迅速的变更，感觉如同掉进了无尽的深渊。  
    
                    。。。。。。                     

_END_
  $credit[1]=<<_END_
东方求败：为了所谓的正义，可以不择手段吗？我只是做
    
了自己想做的事，我错了吗？倒是你，一直生活在正义的
    
阴影下，失去了自我，那才是可悲呢。                
    
住口！你这样的人也配谈正义吗？                    
    
东方求败：想杀人灭口吗？可惜我还不想死。再见了。  
    
不知什么时候东方求败打开了时空转换装置。看着他渐渐
    
变小的背影，我毫不犹豫地冲了上去。                
    
                    。。。。。。                    

_END_
  $credit[3]=<<_END_
我是谁：不要以为你真的打败了我，这只是剧情的安排。
    
其实还有两个更精采的结……                        
    
画外音：快下场！你已经说的够多了。                
    
我走到六芒星阵中央，按下了时空转换的按钮。        
    
                  。。。。。。                    
                      
_END_
end
class Scene_Finish
  def initialize(id,return_scene = nil)
    @id=id
    @sprite = Sprite.new
    @sprite.bitmap = Bitmap.new("Graphics/Pictures/BG.png")
    @sprite.x = 0
    @sprite.y = 0
    @tit=Sprite.new
    @tit.bitmap=Bitmap.new(640,24)
    color=Color.new(144,176,87)
    temp_rect=@tit.bitmap.rect
    n="                          *尾声*                          "
    @tit.bitmap.fill_rect(temp_rect,color)
    @tit.bitmap.font.color.set(0,0,0)
    @tit.bitmap.draw_text(0,0,640,24,n)
  end
  def scene_start
    credit_lines = $credit[@id].split(/\n/)
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
      @last_flag = true
      @last_count = 0
    else
      @last_count += 1
    end
    if @last_count >= 15
      @time=Graphics.frame_count/Graphics.frame_rate
      final_end
    end
  end
  def update
    @frame_index += 1
    last if last?
    @credit_sprite.oy += 1
  end
  def final_end
    window=Window_Base.new(0,0,640,480)
    window.contents=Bitmap.new(608,448)
    window.contents.font.color.set(0,0,0)
    window.contents.clear
    hour=@time/60/60
    min=@time/60%60
    sec=@time%60
    dead=0
    for i in 1..124
      dead+=1 if $live[i]==false
    end
    #普通菜鸟
    i=0
    #舞林高手，灌篮高手
    i=9 if $game_variables[155]>=5000 and $game_variables[156]<=$game_variables[155]
    i=10 if $game_variables[156]>=5000 and $game_variables[155]<=$game_variables[156]
    #神行太保
    i=2 if $game_variables[157]<20
    #浪子杀手
    i=1 if $game_variables[154]>47
    #冷血屠夫
    i=3 if dead>63
    #绝代佳人
    i=8 if $game_variables[22]+$game_variables[49]/10>47 and $gender=="女"
    #邪恶天使
    i=4 if i==8 and dead>63
    #无情名捕
    i=7 if $game_variables[159]>63
    #好好先生
    i=6 if $game_variables[159]==0 and dead==0
    #盖世大侠
    i=5 if $game_variables[160]==160
    time_string = sprintf("%02d:%02d:%02d", hour, min, sec)
    window.contents.draw_text(152,144,304,32,"时间："+time_string)
    window.contents.draw_text(152,176,304,32,"杀NPC数："+dead.to_s)
    window.contents.draw_text(152,208,304,32,"追杀数："+$game_variables[159].to_s)
    window.contents.draw_text(152,240,304,32,"名声："+$game_variables[160].to_s)
    window.contents.draw_text(152,272,304,32,"等级评定："+$end_com[i])
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::C)
        window.contents.clear
        break
      end
    end
    if rand(160)<$game_variables[160]
      enflag=1
    else
      enflag=2
    end
    window.contents.clear
    case enflag
    when 1
      window.contents.draw_text(32,128,576,32,"“喂，喂！醒醒！太阳都晒到屁股了。")
      window.contents.draw_text(32,160,576,32,"再不起床就要迟到啦。”")
      window.contents.draw_text(32,192,576,32,"？？？")
      window.contents.draw_text(32,224,576,32,"一阵忙乱之后。")
      window.contents.draw_text(32,256,576,32,"“有没有搞错？今天可是星期日啊！”")
      window.contents.draw_text(32,288,576,32,"。。。。。。")
    when 2
      window.contents.draw_text(32,128,576,32,"终于着陆了。眼前是一个嘈杂的市场。")
      window.contents.draw_text(32,160,576,32,"到处都是蓝眼睛白皮肤的外国人，而且装扮也很奇怪。")
      window.contents.draw_text(32,192,576,32,"“请问，这里是拍片现场吗？”")
      window.contents.draw_text(32,224,576,32,"“WHAT YOU SAY？”")
      window.contents.draw_text(32,256,576,32,"不会吧？竟然来到了中世纪的欧洲。")
      window.contents.draw_text(32,288,576,32,"MY GOD！")
    end
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::C)
        break
      end
    end
    window.contents.dispose
    window.dispose
    $scene=nil
  end
  def main
    scene_start
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
  end
end