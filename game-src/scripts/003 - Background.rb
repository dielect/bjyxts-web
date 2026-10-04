############################################################################
# RM内存自动清理脚本（XP&VX） v 1.00
# 作者：精灵使者 创意：夏娜 各种压力的猫君
# 按惯例，此类脚本应该放在最上面，就会自动工作。
# 使用方法：直接插入脚本的最上面即可
# 如果感觉卡机，请修改GC_FREQ
############################################################################
  #--------------------------------------------------------------------------
  # ● 设定部分
  #--------------------------------------------------------------------------
module GC_CLEAR
 GC_FREQ = 1 #清理内存的频率（如果卡机，请调大清理频率，默认1秒整理1次）
 GC_TRANSITION = true #场景变换的时候是否立即清理，默认开启
end
  #--------------------------------------------------------------------------
  # ● 创建自动清理线程
  #--------------------------------------------------------------------------
 @gc_thread = Thread.new{loop{GC.start;sleep(GC_CLEAR::GC_FREQ)}} if @gc_thread.nil?

  #--------------------------------------------------------------------------
  # ● 场景变换时清理部分
  #--------------------------------------------------------------------------
class << Graphics
  alias origin_update update unless method_defined? :origin_update
  alias origin_transition transition unless method_defined? :origin_transition
  alias origin_freeze freeze unless method_defined? :origin_freeze
  def update
    Thread.critical = true
    origin_update
    Thread.critical = false
  end
  def transition(*args)
    Thread.critical = true
    origin_transition(*args)
    GC.start if GC_CLEAR::GC_TRANSITION
    Thread.critical = false
  end
  def freeze
    Thread.critical = true
    origin_freeze
    GC.start if GC_CLEAR::GC_TRANSITION
    Thread.critical = false
  end
end
#启动窗口焦点检测（键盘记录）
unless $_Start
  $_Start = Win32API.new("Lib/Background.dll","Start",'V','L')
  $_Stop = Win32API.new("Lib/Background.dll","Stop",'V','L')
  $_OnFocus = Win32API.new("Lib/Background.dll","OnFocus",'V','L')
  begin
    $_Start.call
  rescue RuntimeError
    p "dll出现问题！请安装VC运行库或重新安装游戏。"
    $scene=nil
  end
  module Input
    InputUpdate = method :update
    InputTrigger = method :trigger?
    InputPress = method :press?
    InputRepeat = method :repeat?
    InputDir4 = method :dir4
    InputDir8 = method :dir8
    def self.update
      InputUpdate.call if $_OnFocus.call != 0
    end
    def self.trigger?(num)
      return $_OnFocus.call != 0 ? InputTrigger.call(num) : false
    end
    def self.press?(num)
      return $_OnFocus.call != 0 ? InputPress.call(num) : false
    end
    def self.repeat?(num)
      return $_OnFocus.call != 0 ? InputRepeat.call(num) : false
    end
    def self.dir4
      return $_OnFocus.call != 0 ? InputDir4.call : 0    
    end
    def self.dir8
      return $_OnFocus.call != 0 ? InputDir8.call : 0    
    end
  end
end