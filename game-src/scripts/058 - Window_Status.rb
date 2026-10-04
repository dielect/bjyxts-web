#==============================================================================
# ■ Window_Status
#------------------------------------------------------------------------------
# 　显示状态画面、完全规格的状态窗口。
#==============================================================================

class Window_Status < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     actor : 角色
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(122, 160, 396, 280)
    self.contents = Bitmap.new(width - 32, height - 32)
    @actor = actor
    @lv=get_actor_level
    self.contents.font.size = 24
    self.contents.font.color = system_color
  end
  #--------------------------------------------------------------------------
  # ● 状态
  #--------------------------------------------------------------------------
  def look0
    self.contents.clear
    self.contents.draw_text(32,32,80,32,"食物：")
    self.contents.draw_text(32,64,80,32,"饮水：")
    self.contents.draw_text(32,96,80,32,"生命：")
    self.contents.draw_text(32,128,80,32,"内力：")
    self.contents.draw_text(32,160,80,32,"经验：")
    self.contents.draw_text(32,192,80,32,"潜能：")
    full_hp=100+$game_variables[24]/4
    full_hp+=[($game_variables[157]-14)*20,300].min
    p=[100*@actor.maxhp/full_hp,100].min
    self.contents.draw_text(104,32,200,32,$game_variables[15].to_s+"/"+$game_variables[16].to_s)
    self.contents.draw_text(104,64,200,32,$game_variables[17].to_s+"/"+$game_variables[18].to_s)
    self.contents.draw_text(104,96,200,32,@actor.hp.to_s+"/"+@actor.maxhp.to_s+"("+p.to_s+"%)")
    self.contents.draw_text(104,128,200,32,@actor.sp.to_s+"/"+$game_variables[24].to_s+"(+"+$game_variables[23].to_s+")")
    self.contents.draw_text(104,160,200,32,$game_variables[19].to_s)
    self.contents.draw_text(104,192,200,32,$game_variables[20].to_s)
  end
  #--------------------------------------------------------------------------
  # ● 描述
  #--------------------------------------------------------------------------
  def look1
    self.contents.clear
    self.contents.draw_text(32, 32, 240, 32, "["+$school[$game_variables[21]]+"]"+@actor.name)
    while $game_variables[158]>=3000
      $game_variables[158]-=3000
      $game_variables[157]+=1
      $game_variables[157]=255 if $game_variables[157]>=255
      if $game_variables[157]%4==0
        $game_variables[34]=1
        $game_switches[97]=true
      else
        $game_variables[34]=0
        $game_switches[97]=false
      end
    end    
    age=$game_variables[157]
    self.contents.draw_text(32, 64, 300, 32, "你是一位"+age.to_s+"岁的"+$gender+"性")
    if $game_variables[157]<16
      face="一脸稚气"
    else
      face_lv=$game_variables[22]+($game_variables[49]/10)
      if face_lv>31
        face_lv=31
      end
      if face_lv<10
        face_lv=10
      end
      case $gender
      when "男"
        face=$boy[7-(face_lv-10)/3]
      when "女"
        face=$girl[7-(face_lv-10)/3]
      when "？"
        face=$girl[7-(face_lv-10)/3]
      end
    end
    self.contents.draw_text(32, 96, 300, 32, "你"+face)
    lv=$levels[@lv/5]
    n = $game_variables[11]+$game_variables[23]/2+$game_variables[40]/10+$game_variables[91]
    weapon = $data_weapons[$game_party.actors[0].weapon_id]
    if weapon != nil
      n+=weapon.atk
    end
    attack=$attacks[[n,100].min/20]
    self.contents.draw_text(32,128,340,32,"武艺看起来"+lv)
    self.contents.draw_text(32,160,340,32,"出手似乎"+attack)
  end
  #--------------------------------------------------------------------------
  # ● 属性
  #--------------------------------------------------------------------------
  def look2
    self.contents.clear
    self.contents.draw_text(32, 32,120,32,"金钱：")
    self.contents.draw_text(32, 64, 120, 32, "膂力：")
    self.contents.draw_text(32, 96, 120, 32, "敏捷：")
    self.contents.draw_text(32, 128, 120, 32, "悟性：")
    self.contents.draw_text(32, 160, 120, 32, "根骨：")
    a=$game_variables[40]/10+$game_variables[11]+$game_variables[91]
    b=$game_variables[46]/10+$game_variables[12]+$game_variables[92]
    a=[255,a].min
    b=[255,b].min
    c=$game_variables[48]/10+$game_variables[13]
    d=$game_variables[45]/10+$game_variables[14]
    self.contents.draw_text(104, 32,288,32,$game_party.gold.to_s)
    self.contents.draw_text(104, 64, 192, 32, "["+a.to_s+"/"+$game_variables[11].to_s+"]")
    self.contents.draw_text(104, 96, 192, 32, "["+b.to_s+"/"+$game_variables[12].to_s+"]")
    self.contents.draw_text(104, 128, 192, 32, "["+c.to_s+"/"+$game_variables[13].to_s+"]")
    self.contents.draw_text(104, 160, 192, 32, "["+d.to_s+"/"+$game_variables[14].to_s+"]") 
    self.contents.draw_text(216, 64, 192, 32, "命中：")
    self.contents.draw_text(216, 96, 192, 32, "闪避：")
    self.contents.draw_text(216, 128, 192, 32, "攻击：")
    self.contents.draw_text(216, 160, 192, 32, "防御：")
    new_status
    e=@actor.weapon_id
    self.contents.draw_text(288, 64, 192, 32, "["+@b.to_s+"]")
    self.contents.draw_text(288, 96, 192, 32, "["+@c.to_s+"]")
    self.contents.draw_text(288, 128, 192, 32, "["+@d.to_s+"]")
    self.contents.draw_text(288, 160, 192, 32, "["+@a.to_s+"]")
  end
  #获取命中闪避
  def new_status
    @a=0
    @b=0
    @c=0
    @d=0
    weapon = $data_weapons[@actor.weapon_id]
    armor1 = $data_armors[@actor.armor1_id]
    armor2 = $data_armors[@actor.armor2_id]
    armor3 = $data_armors[@actor.armor3_id]
    armor4 = $data_armors[@actor.armor4_id]
    armor5 = $data_armors[@actor.armor5_id]
    armor6 = $data_armors[@actor.armor6_id]
    armor7 = $data_armors[@actor.armor7_id]
    @a += armor1 != nil ? armor1.pdef : 0
    @a += armor2 != nil ? armor2.pdef : 0
    @a += armor3 != nil ? armor3.pdef : 0
    @a += armor4 != nil ? armor4.pdef : 0
    @a += armor5 != nil ? armor5.pdef : 0
    @a += armor6 != nil ? armor6.pdef : 0
    @a += armor7 != nil ? armor7.pdef : 0
    @a += $game_variables[96]
    @a=0 if @a<0
    @a=[255,@a].min
    @b += weapon != nil ? weapon.str_plus : 0
    @b += armor1 != nil ? armor1.str_plus : 0
    @b += armor2 != nil ? armor2.str_plus : 0
    @b += armor3 != nil ? armor3.str_plus : 0
    @b += armor4 != nil ? armor4.str_plus : 0
    @b += armor5 != nil ? armor5.str_plus : 0
    @b += armor6 != nil ? armor6.str_plus : 0
    @b += armor7 != nil ? armor7.str_plus : 0
    @b += $game_variables[94]
    @b=0 if @b<0
    @b=[255,@b].min
    @c += weapon != nil ? weapon.dex_plus : 0
    @c += armor1 != nil ? armor1.dex_plus : 0
    @c += armor2 != nil ? armor2.dex_plus : 0
    @c += armor3 != nil ? armor3.dex_plus : 0
    @c += armor4 != nil ? armor4.dex_plus : 0
    @c += armor5 != nil ? armor5.dex_plus : 0
    @c += armor6 != nil ? armor6.dex_plus : 0
    @c += armor7 != nil ? armor7.dex_plus : 0
    @c += $game_variables[95]
    @c=0 if @c<0
    @c=[255,@c].min
    @d += weapon != nil ? weapon.atk : 0
  end
end