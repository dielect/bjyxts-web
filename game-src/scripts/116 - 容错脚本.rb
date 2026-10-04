 #==============================================================================
 # ■ 凌的容错脚本 v3 [120929]
 #------------------------------------------------------------------------------
 # 　解决游戏因发布时缺少文件等错误而使游戏无法正常进行的问题。
 #   附赠功能：创建多层文件夹
 #==============================================================================
 # 　[120927]：基础版，支持Bitmap及Audio容错
 # 　[120928]：修正IOError问题，感谢orzFly和雷达喵
 # 　[120928]：支持Graphics.transition容错及save_data自动创建目录
 #             修正部分BUG，感谢霜月冬音
 #==============================================================================
 File.open("errors.txt","w+"){|io|}
 class Dir
   class << self
     alias :lynn_mkdir :mkdir unless $@
   end
   def self.mkdir(path, mode = 0777)
     last_dir = ""
     path.gsub(/\w*\//) {|m|
       m.gsub(/\/|\\/){}
       if last_dir != ""
         last_dir = "#{last_dir}/#{m}"
       else
         last_dir = "#{m}"
       end
       if !FileTest.exist?(m) && !FileTest.directory?(m) 
         self.lynn_mkdir(last_dir)
       end
     }
   end
 end
 module Kernel
   def write_errors(argu)
     open("errors.txt","a+"){|io| io.write(argu+"\n")if !io.read.to_s.include?(argu)}
   end
   def save_data(obj, filename)
     Dir.mkdir(filename) unless FileTest.exist?(filename)
     File.open(filename, "wb") { |io|
       Marshal.dump(obj, io)
     }
   end
 end
 class Bitmap
   alias :lynn_initialize :initialize unless $@
   def initialize(* argu)
     begin
       lynn_initialize(* argu)
     rescue Errno::ENOENT
       lynn_initialize(1,1)
       write_errors "Error:File not found on Bitmap.new\n#{argu[0]}"
     end
   end
 end
 module Audio
   class << self
     alias_method :lynn_bgm_play, :bgm_play unless $@
     alias_method :lynn_bgs_play, :bgs_play unless $@
     alias_method :lynn_me_play, :me_play unless $@
     alias_method :lynn_se_play, :se_play unless $@
   end
   def self.bgm_play(* argu)
     begin
       self.lynn_bgm_play(* argu)
     rescue Errno::ENOENT
       write_errors "Error:File not found on Audio.bgm_play\n#{argu[0]}"
     end
   end
   def self.bgs_play(* argu)
     begin
       self.lynn_bgs_play(* argu)
     rescue Errno::ENOENT
       write_errors "Error:File not found on Audio.bgs_play\n#{argu[0]}"
     end
   end
   def self.me_play(* argu) 
     begin
       self.lynn_me_play(* argu)
     rescue Errno::ENOENT
       write_errors "Error:File not found on Audio.me_play\n#{argu[0]}"
     end
   end
   def self.se_play(* argu) 
     begin
       self.lynn_se_play(* argu)
     rescue Errno::ENOENT
       write_errors "Error:File not found on Audio.se_play\n#{argu[0]}"
     end
   end
 end
 module Graphics
   class << self
     alias_method :lynn_transition, :transition unless $@
   end
   def self.transition(duration = 8, filename = "", vague = 40)
     if filename != ""
       if !FileTest.exist?(filename)
         write_errors "Error:File not found on Graphics.transition\n#{filename}"
         filename = ""
       end
     end
     self.lynn_transition(duration,filename,vague)
   end
 end
 #==============================================================================
 # ■ 凌的容错脚本 v3 附加包 [120929] [RMXP版本]
 #------------------------------------------------------------------------------
 # 　解决游戏因发布时缺少文件等错误而使游戏无法正常进行的问题。
 #==============================================================================
 # 　[120929]：支援在事件中执行脚本的容错功能，同时输出所在地图与事件ID
 #==============================================================================
 # 　* 注意本脚本只能用于标准事件解释器结构的工程
 #==============================================================================
 class Interpreter
   #--------------------------------------------------------------------------
   # ● 脚本
   #--------------------------------------------------------------------------
   def command_355
     # script 设置第一行
     script = @list[@index].parameters[0] + "\n"
     # 循环
     loop do
       # 下一个事件指令在脚本 2 行以上的情况下
       if @list[@index+1].code == 655
         # 添加到 script 2 行以后
         script += @list[@index+1].parameters[0] + "\n"
       # 事件指令不在脚本 2 行以上的情况下
       else
         # 中断循环
         break
       end
       # 推进索引
       @index += 1
     end
     # 评价
     result = eval(script)
     # 返回值为 false 的情况下
     if result == false
       # 结束
       return false
     end
     # 继续
     return true
   end
 end