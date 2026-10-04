#检查武功等级与经验
def ckeck_exp_maxlv(id,opt=1)
  return true if nil==$game_variables[id]
  lv=$game_variables[id]+opt
  return true if (lv<3 or lv==nil)
  key=lv*lv*lv/10-0.3*lv*lv+0.4*lv-2
  key=key.truncate
  if key>$game_variables[19]
    return false
  else
    return true
  end
end
#获取兵刃武功对应的基本武功
def weapon_skill_base(skill_number)
  if skill_number>=80 and skill_number<=83
    return 42
  elsif skill_number>=85 and skill_number<=87
    return 41
  elsif skill_number==88
    return 44
  elsif skill_number==89
    return 43
  end
end
#获取拳脚、轻功对应的基本武功
def get_all_skill_base(skill_id)
  if skill_id>=53 and skill_id<=61
    return 40
  elsif skill_id>=64 and skill_id<=69
    return 46
  else
    return weapon_skill_base(skill_id)
  end
end
#获取兵刃对应的基本武功
def get_weapon_base_skill
  actor=$game_party.actors[0]
  if (actor.weapon_id>=8 and actor.weapon_id<15) or [1,28,29].include?(actor.weapon_id)
    return 42
  elsif (actor.weapon_id>=15 and actor.weapon_id<21) or [2,3,4,6,7,30].include?(actor.weapon_id)
    return 41
  elsif (actor.weapon_id>=21 and actor.weapon_id<25) or actor.weapon_id==5
    return 44
  elsif (actor.weapon_id>24 and actor.weapon_id<28)
    return 43
  end
end
#检查武器匹配兵刃技
def weapon_matching_skill?(skill_number=$game_variables[30])
  if get_weapon_base_skill == weapon_skill_base(skill_number)
    return true
  else
    return false
  end
end
#描绘主菜单
def draw_main_menu
  @top_menu_list=["查看", "物品", "技能", "功能"]
  @top_menu = Window_Base.new(0, 0, 640, 64)
  @top_menu.contents = Bitmap.new(608, 32)
  @top_menu.contents.font.size = 24
  @top_menu.contents.font.color.set(0,0,0)
  for i in 0..3
     @top_menu.contents.draw_text(i * 152+52, 0 , 48 , 32, @top_menu_list[i],1)
  end
end
#---------------------------------------------------------------------------
# 计算角色等级
#---------------------------------------------------------------------------
def get_actor_level
  if $game_party.actors[0].weapon_id==0
    #没有装备武器的情况下
    sk_1=$game_variables[40]+$game_variables[$game_variables[29]]*2
    sk_1*=2
    sk_2=$game_variables[46]+$game_variables[$game_variables[31]]*2
    sk_3=$game_variables[47]
    if $game_variables[33]==$game_variables[29]
      sk_3 +=$game_variables[$game_variables[33]]*2
    end
    return (sk_1+sk_2+sk_3)/12
  else
    sk_2=$game_variables[46]+$game_variables[$game_variables[31]]*2
    if weapon_matching_skill?
      sk_1=$game_variables[get_weapon_base_skill]+$game_variables[$game_variables[30]]*2
      sk_3=$game_variables[47]
      if $game_variables[33]==$game_variables[30]
        sk_3 +=$game_variables[$game_variables[30]]*2
      end
    else
      sk_3=$game_variables[47]
      sk_1=$game_variables[get_weapon_base_skill]
    end
    sk_1*=2
    return (sk_1+sk_2+sk_3)/12
  end
end
#--------------------------------------------------------------------------
# ● 读取存档数据
#     file : 读取用文件对像 (已经打开)
#--------------------------------------------------------------------------
def read_save_data(file)
  # 读取描绘存档文件用的角色数据
  characters = Marshal.load(file)
  # 读取测量游戏时间用画面计数
  Graphics.frame_count = Marshal.load(file)
  # 读取文档字串
  strings = Marshal.load(file)
  # 读取校验
  crcs = Marshal.load(file)
  # 校验
  key = 5370
  strings.each_index do |i|
    key = Zlib.crc32(strings[i],key)
    unless crcs[i] == key
      file.close
      p "无效存档！"
      $scene=nil
    end
  end
  # 读取各种游戏对像
  $game_system        = Marshal.load(Zlib::Inflate.inflate(strings[0]))
  $game_switches      = Marshal.load(Zlib::Inflate.inflate(strings[1]))
  $game_variables     = Marshal.load(Zlib::Inflate.inflate(strings[2]))
  $game_self_switches = Marshal.load(Zlib::Inflate.inflate(strings[3]))
  $game_screen        = Marshal.load(Zlib::Inflate.inflate(strings[4]))
  $game_actors        = Marshal.load(Zlib::Inflate.inflate(strings[5]))
  $game_party         = Marshal.load(Zlib::Inflate.inflate(strings[6]))
  $game_troop         = Marshal.load(Zlib::Inflate.inflate(strings[7]))
  $game_map           = Marshal.load(Zlib::Inflate.inflate(strings[8]))
  $game_player        = Marshal.load(Zlib::Inflate.inflate(strings[9]))
  $gender             = Marshal.load(Zlib::Inflate.inflate(strings[10]))
  $live               = Marshal.load(Zlib::Inflate.inflate(strings[11]))
  # 魔法编号与保存时有差异的情况下
  # (加入编辑器的编辑过的数据)
  if $game_system.magic_number != $data_system.magic_number
    # 重新装载地图
    $game_map.setup($game_map.map_id)
    $game_player.center($game_player.x, $game_player.y)
  end
  # 刷新同伴成员
  $game_party.refresh
  # 卸下所有装备
  $game_actors[1].unequipall
  $save_time=Graphics.frame_count/Graphics.frame_rate
  #清空任务残留信息
  for i in 1..10
    $game_variables[i]=0
  end
  $game_variables[5]=1
  for i in 10..18
    $game_switches[i]=false
  end
  $game_switches[98]=false
  $game_variables[98]=0
  $game_party.lose_item(21,99) if $game_party.item_number(21)>0
  for i in 49..94
    $game_switches[i]=false
  end
  $game_variables[2]=1
  #清空属性加成
  for i in 91..96
    $game_variables[i]=0
  end
  $game_map.setup(4)
  $game_player.moveto(9,7)
  $game_player.turn_down
  $game_player.straighten
  $game_system.timer=0
end
#--------------------------------------------------------------------------
# ● 写入存档数据
#    file : 写入用文件对像 (已经打开)
#--------------------------------------------------------------------------
def write_save_data(file)
  # 生成描绘存档文件用的角色图形
  characters = []
  for i in 0...$game_party.actors.size
    actor = $game_party.actors[i]
    characters.push([actor.character_name, actor.character_hue])
  end
  strings = []
  # 写入描绘存档文件用的角色数据
  Marshal.dump(characters, file)
  # 写入测量游戏时间用画面计数
  Marshal.dump(Graphics.frame_count, file)
  # 增加 1 次存档次数
  $game_system.save_count += 1
  # 保存魔法编号
  # (将编辑器保存的值以随机值替换)
  $game_system.magic_number = $data_system.magic_number
  # 写入各种游戏对像
  strings.push(Zlib::Deflate.deflate(Marshal.dump($game_system)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($game_switches)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($game_variables)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($game_self_switches)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($game_screen)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($game_actors)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($game_party)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($game_troop)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($game_map)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($game_player)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($gender)))
  strings.push(Zlib::Deflate.deflate(Marshal.dump($live)))
  # 计算校验值
  crcs = []
  key = 5370
  strings.each do |i|
    key = Zlib.crc32(i,key)
    crcs.push(key)
  end
  Marshal.dump(strings,file)
  Marshal.dump(crcs,file)
end
def get_sp_name(aid=0)
  sp_array=["头部","颈部","胸口","後心","左肩","右肩","左臂","右臂","左手",
  "右手","腰间","小腹","左腿","右腿","左脚","右脚"]
  id=rand(sp_array.size-1)
  id=aid if aid !=0
  return sp_array[id]+'|'+id.to_s
end