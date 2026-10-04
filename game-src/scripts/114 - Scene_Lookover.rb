#==============================================================================
# ■ lookover
#------------------------------------------------------------------------------
# 　处理查看事件
#   每行介绍最多25个字
#==============================================================================

class Lookover
  def initialize(name,age,level,attack,items="",str1="",str2="",str3="",str4="",str5="")
    @name=name
    @age=age
    @lv=level
    @attack=attack
    @items=items
    @str1=str1
    @str2=str2
    @str3=str3
    @str4=str4
    @str5=str5
  end
  def main
    @screen = Spriteset_Map.new
    look = Window_Base.new((640-512)/2,(480-320)/2,512,320)
    look.contents = Bitmap.new(look.width - 32, look.height - 32)
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      look.contents.clear
      look.contents.font.color.set(0,0,0)
      look.contents.font.size=24
      look.contents.draw_text(0,0,480,32,@name+"看起来约"+@age+"0多岁")
      look.contents.draw_text(0,32,480,32,"武艺看起来"+@lv)
      look.contents.draw_text(0,64,480,32,"出手似乎"+@attack)
      look.contents.draw_text(0,96,480,32,"带着："+@items)
      look.contents.draw_text(0,128,480,32,@str1)
      look.contents.draw_text(0,160,480,32,@str2)
      look.contents.draw_text(0,192,480,32,@str3)
      look.contents.draw_text(0,224,480,32,@str4)
      look.contents.draw_text(0,256,480,32,@str5)
      update_command
      # 如果画面切换就中断循环
      if $scene != self
        break
      end
    end
    # 准备过渡
    Graphics.freeze
    # 释放窗口
    Input.update
    look.dispose
    @screen.dispose
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (命令窗口被激活的情况下)
  #--------------------------------------------------------------------------
  def update_command
    # 按下 B 键的情况下
    if Input.trigger?(Input::B)
       $scene = Scene_Map.new
    end
    # 按下 C 键的情况下
    if Input.trigger?(Input::C)
      $scene = Scene_Map.new
    end
  end
end