#==============================================================================
# ■ Scene_Title
#------------------------------------------------------------------------------
# 　处理标题画面的类。
#==============================================================================

class Scene_Title
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    # 战斗测试的情况下
    if $BTEST
      battle_test
      return
    end
    # 载入数据库
    $data_actors        = load_data("Data/Actors.rxdata")
    $data_classes       = load_data("Data/Classes.rxdata")
    $data_skills        = load_data("Data/Skills.rxdata")
    $data_items         = load_data("Data/Items.rxdata")
    $data_weapons       = load_data("Data/Weapons.rxdata")
    $data_armors        = load_data("Data/Armors.rxdata")
    $data_enemies       = load_data("Data/Enemies.rxdata")
    $data_troops        = load_data("Data/Troops.rxdata")
    $data_states        = load_data("Data/States.rxdata")
    $data_animations    = load_data("Data/Animations.rxdata")
    $data_tilesets      = load_data("Data/Tilesets.rxdata")
    $data_common_events = load_data("Data/CommonEvents.rxdata")
    $data_system        = load_data("Data/System.rxdata")
    $data_mapinfos      = load_data("Data/MapInfos.rxdata")
    # 生成系统对像
    $game_system = Game_System.new
    $bad_man_count=0
    $bad_man_turn=0
    $stone_tm=-180
    $data_enemies[125].lv=0
    $save_time=Graphics.frame_count/Graphics.frame_rate
    if FileTest.exist?("Gmud.sav")
      $game_temp = Game_Temp.new
      file=File.open("Gmud.sav", "rb")
      read_save_data(file)
      file.close     
      $save_time=Graphics.frame_count/Graphics.frame_rate
      p_time=($game_variables[157]-14)*6000+$game_variables[158]+1
      if save_test(p_time)
        for i in 1..160
          $game_variables[i]=0
        end
        file=File.open("Gmud.sav","wb")
        write_save_data(file)
        file.close
        p "系统数值异常！"
        exit
      end
      $game_variables[152]=Zlib.crc32($game_variables[19].to_s,51) if $game_variables[152]==0
      $game_variables[153]=$game_variables[20]+3 if $game_variables[153]==0
      $game_variables[151]=Zlib.crc32($game_party.gold.to_s,51) if $game_variables[151]==0
      $game_switches[3]=true
      if $game_variables[21]==3
        $game_actors[1].maxhp=$game_variables[24]/4+100+[($game_variables[157]-14)*20,300].min
        $game_actors[1].hp=$game_actors[1].maxhp if $game_actors[1].hp>$game_actors[1].maxhp
      end
      $game_party.lose_weapon(30,1) if $game_switches[101]==true and $game_party.weapon_number(30)>0
      # 还原 BGM、BGS
      $game_map.autoplay
      # 刷新地图 (执行并行事件)
      $game_map.update
      $scene=Scene_Map.new
    else
      $gender="男"
      $live=[]
      for i in 0..124
        $live.push true
      end
      $scene=Scene_Begin.new
    end
  end
  #--------------------------------------------------------------------------
  # ● 战斗测试
  #--------------------------------------------------------------------------
  def battle_test
    # 载入数据库 (战斗测试用)
    $data_actors        = load_data("Data/BT_Actors.rxdata")
    $data_classes       = load_data("Data/BT_Classes.rxdata")
    $data_skills        = load_data("Data/BT_Skills.rxdata")
    $data_items         = load_data("Data/BT_Items.rxdata")
    $data_weapons       = load_data("Data/BT_Weapons.rxdata")
    $data_armors        = load_data("Data/BT_Armors.rxdata")
    $data_enemies       = load_data("Data/BT_Enemies.rxdata")
    $data_troops        = load_data("Data/BT_Troops.rxdata")
    $data_states        = load_data("Data/BT_States.rxdata")
    $data_animations    = load_data("Data/BT_Animations.rxdata")
    $data_tilesets      = load_data("Data/BT_Tilesets.rxdata")
    $data_common_events = load_data("Data/BT_CommonEvents.rxdata")
    $data_system        = load_data("Data/BT_System.rxdata")
    # 重置测量游戏时间用的画面计数器
    Graphics.frame_count = 0
    # 生成各种游戏对像
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
    # 设置战斗测试用同伴
    $game_party.setup_battle_test_members
    # 设置队伍 ID、可以逃走标志、战斗背景
    $game_temp.battle_troop_id = $data_system.test_troop_id
    $game_temp.battle_can_escape = true
    $game_map.battleback_name = $data_system.battleback_name
    # 演奏战斗开始 BGM
    $game_system.se_play($data_system.battle_start_se)
    # 演奏战斗 BGM
    $game_system.bgm_play($game_system.battle_bgm)
    # 切换到战斗画面
    $scene = Scene_Battle.new
  end
  #--------------------------------------------------------------------------
  # ● 测试
  #--------------------------------------------------------------------------
  def save_test(p_time)
    abi=$game_variables[11]+$game_variables[12]+$game_variables[13]+$game_variables[14]
    return true if $game_variables[19]>700000000
    return true if $game_variables[19]/($save_time+1)>1000
    return true if $game_variables[20]/($save_time+1)>500
    return true if $game_variables[51]>0 and $game_variables[160]>=128
    return true if $game_variables[21]==7 and $game_variables[31]>0
    return true if (abi-80)/2-1>($game_variables[157]-16)/4
    return false
  end
end
