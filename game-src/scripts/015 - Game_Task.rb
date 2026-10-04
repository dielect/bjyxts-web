#==============================================================================
# ■ Game_Task
#------------------------------------------------------------------------------
# 　处理游戏中各种任务以及奖励。
#==============================================================================  
  #扫地
  def task1
    $game_party.actors[0].hp-=30
    task= Window_Base.new((640-160)/2,128,185,60)
    task.contents = Bitmap.new(task.width - 32, task.height - 32)
    task.contents.font.color.set(0,0,0)
    task.contents.draw_text(0,0,240,32,"扫地扫地我扫地")
    for i in 0..40
      Graphics.update
    end
    task.contents.clear
    task.contents.draw_text(0,0,240,32,"地上还有西瓜皮")
    for i in 0..40
      Graphics.update
    end
    task.contents.clear
    task.contents.draw_text(0,0,240,32,"婆婆家中欠打扫")
    for i in 0..40
      Graphics.update
    end
    task.contents.clear
    task.contents.draw_text(0,0,240,32,"尘土满天难呼吸")
    for i in 0..40
      Graphics.update
    end
    for i in 0..10
      task.opacity -= 20
      task.contents_opacity -= 20
    end
    task.dispose
  end
  #挑水
  def task2
    $game_party.actors[0].hp-=40
    task= Window_Base.new((640-160)/2,128,185,60)
    task.contents = Bitmap.new(task.width - 32, task.height - 32)
    task.contents.font.color.set(0,0,0)
    task.contents.draw_text(0,0,240,32,"挑水挑水我挑水")
    for i in 0..40
      Graphics.update
    end
    task.contents.clear
    task.contents.draw_text(0,0,240,32,"倒水进缸水花飞")
    for i in 0..40
      Graphics.update
    end
    task.contents.clear
    task.contents.draw_text(0,0,240,32,"一桶两桶三四桶")
    for i in 0..40
      Graphics.update
    end
    task.contents.clear
    task.contents.draw_text(0,0,240,32,"反正不用交水费")
    for i in 0..40
      Graphics.update
    end
    for i in 0..12
      task.opacity -= 20
      task.contents_opacity -= 20
    end
    task.dispose
  end
  #劈柴
  def task3
    $game_party.actors[0].hp-=50
    task= Window_Base.new((640-160)/2,128,185,60)
    task.contents = Bitmap.new(task.width - 32, task.height - 32)
    task.contents.font.color.set(0,0,0)
    task.contents.draw_text(0,0,240,32,"劈柴劈柴我劈柴")
    for i in 0..40
      Graphics.update
    end
    task.contents.clear
    task.contents.draw_text(0,0,240,32,"抡起斧子劈起来")
    for i in 0..40
      Graphics.update
    end
    task.contents.clear
    task.contents.draw_text(0,0,240,32,"保护树木讲环保")
    for i in 0..40
      Graphics.update
    end
    task.contents.clear
    task.contents.draw_text(0,0,240,32,"婆婆没事别乱烧")
    for i in 0..40
      Graphics.update
    end
    for i in 0..12
      task.opacity -= 20
      task.contents_opacity -= 20
    end
    task.dispose
  end
  #老婆婆任务结束
  def finishtask
    $game_variables[152]=Zlib.crc32(($game_variables[19]+100).to_s,51)
    $game_variables[19]+=100
    $game_variables[20]+=50
    $game_variables[153]+=50
    $game_party.gain_gold(250)
    task = Window_Base.new((640-300)/2,128,300,64)
    task.contents = Bitmap.new(task.width - 32, task.height - 32)
    task.contents.font.color.set(0,0,0)
    task.contents.draw_text(0,0,300,32,"费了老大力气，总算干完了！")
    for i in 0..50
      Graphics.update
    end
    for i in 0..12
      task.opacity -= 20
      task.contents_opacity -= 20
    end
    task.dispose
  end
  #村长任务
  def task4
    #生成任务列表
    @task=[]
    for i in 5..124
      if $live[i]
        @task.push i
      end
    end
    #检查人是否杀光
    if @task==nil
      $kill=false
    else
      $kill=true
      id=rand(@task.size)
      $game_actors[3].name=""
      $game_variables[2]=@task[id]
      $game_actors[3].name=$data_enemies[@task[id]].name
    end
  end
  #检查中年妇女任务
  def checktask5?
    type=$game_variables[4]/100
    id=$game_variables[4]%100
    case type
    when 1
      if $game_party.weapon_number(id)>0
        if $game_actors[1].weapon_id==id
          if $game_party.weapon_number(id)>1
            $game_party.gain_weapon(id,-1)
            return true
          else
            return false
          end
        else
          $game_party.gain_weapon(id,-1)
          return true
        end
      else
        return false
      end
    when 2
      if $game_party.item_number(id)>0
        $game_party.gain_item(id,-1)
        return true
      else
        return false
      end
    when 3
      if $game_party.armor_number(id)>0
        if $game_actors[1].armor_equiped?(id)
          if $game_party.armor_number(id)>1
            $game_party.gain_armor(id,-1)
            return true
          else
            return false
          end
        else
          $game_party.gain_armor(id,-1)
          return true
        end
      else
        return false
      end
    end
  end
  #中年妇女任务
  def task5
    #随机选择类型
    $game_variables[4]=100*(rand(3)+1)
    #随机确定任务物品
    case $game_variables[4]
    when 100 #武器
      if $game_variables[19]<10000
        id=rand(8)+1 #1-8
      elsif $game_variables[19]<30000
        id=rand(13)+1
      else
        id=rand($data_weapons.size-3)+1
      end
      name=$data_weapons[id].name
    when 200 #物品
      if $game_variables[19]<15000
        id=rand(7)+1 #1-7
      else
        id=rand(18)+1
      end
      name=$data_items[id].name
    when 300 #防具
      if $game_variables[19]<13000
        id=rand(4)+2
      elsif $game_variables[19]<25000
        id=rand(12)+1
      else
        id=rand($data_armors.size-1)+1
      end
      name=$data_armors[id].name
    end
    $game_actors[5].name=""
    $game_actors[5].name=name
    $game_variables[4] +=id
  end
  #平一指任务
  def task6
    #生成任务列表
    @task=[]
    for i in 5..124
      if $live[i]
        @task.push i
      end
    end
    #检查人是否杀光
    if @task==[]
      $kill=false
    else
      $kill=true
      id=rand(@task.size)
      $game_actors[4].name=""
      $game_variables[5]=@task[id]
      $game_actors[4].name=$data_enemies[@task[id]].name
    end
  end
  #捕快任务
  def task7
    $bad_man_data=[]
    $data_enemies[125].lv=0
    $game_switches[$game_variables[8]+46]=true
    $game_actors[6].name=""
    $game_actors[6].name=$task1[0][$game_variables[6]]+$task1[1][$game_variables[7]]
    $data_enemies[125].name=$game_actors[6].name
    $game_actors[7].name=""
    $game_actors[7].name=$data_mapinfos[$game_variables[8]].name
    if $game_variables[7]<4
      $data_enemies[125].battler_name="NPC_Tile_03.png"
    else
      $data_enemies[125].battler_name="NPC_Tile_11.png"
    end
    if $bad_man_count%10==0
      $bad_man_count=0
      $bad_man_turn+=1
    end
    $bad_man_count+=1
  end
  #任务奖励（杀人，寻物，拜访）
  def one_award
    #奖励经验
    if $game_variables[9]<6
      i=1
      if $game_variables[19]>=56000
        e=90+rand(204)
      else
        e=rand(156)+60
      end
    else
    #奖励潜能
      i=2
      if $game_variables[19]>=40000
        e=53+rand(127)
      else
        e=rand(83)+27
      end
    end
    e*=($game_variables[13]+$game_variables[48]/10+$game_variables[93])
    e/=20
    e=[e,3492/i].min
    case i
    when 1
      $game_variables[152]=Zlib.crc32(($game_variables[19]+e).to_s,51)
      $game_variables[19]+=e
    when 2
      $game_variables[20]+=e
      $game_variables[153]+=e
    end
    $game_variables[26]=e
  end
  #捕快任务奖励
  def two_award
    if $game_variables[19]>=63000
      e=200+rand(80)
    else
      e=rand(40)+180
    end
    t=$bad_man_count
    add=e/2
    while t>1
      e+=(add+$bad_man_count+$bad_man_turn*5)
      t-=1
    end
    e*=($game_variables[13]+$game_variables[48]/10)
    e/=20
    e=[e.truncate,5692].min
    q=e/4
    $game_variables[27]=e
    $game_variables[152]=Zlib.crc32(($game_variables[19]+e).to_s,51)
    $game_variables[19]+=e
    $game_variables[28]=q
    $game_variables[153]+=q
    $game_variables[20]+=q
  end
    