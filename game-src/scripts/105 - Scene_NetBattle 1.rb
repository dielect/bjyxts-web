#==============================================================================
# ■ Scene_NetBattle (分割定义 1)
#------------------------------------------------------------------------------
# 　处理联机战斗画面的类。
#==============================================================================
class Scene_NetBattle
  def initialize(type,self_sock)
    @is_server=type
    @self_sock=self_sock
    if type
      @clientmsg=$game_temp.msg_for_socket
    else
      @serverip=$game_temp.msg_for_socket
    end
    $game_temp.map_bgm = $game_system.playing_bgm
    $game_system.bgm_stop
    Audio.bgm_play("Audio/BGM/战斗1", 100, 100)
  end
  def exchange_data
    enemy_data=$game_temp.msg_for_net_battler
    dt=enemy_data.split('|')
    $data_enemies[143].name=dt[1]
    $data_enemies[143].maxhp=dt[5].to_i
    $data_enemies[143].maxsp=dt[6].to_i
    $data_enemies[143].exp=dt[7].to_i
    $game_troop.setup(143)
    $game_troop.enemies[0].hp=dt[3].to_i
    $game_troop.enemies[0].sp=dt[4].to_i
    $npc_data=[]
    for i in 8..19
      $npc_data.push(dt[i].to_i)
    end
    for i in 10..21
      $npc_data.push([dt[2*i].to_i,dt[2*i+1].to_i])
    end
    for i in 44..50
      $npc_data.push(dt[i].to_i)
    end
  end
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    Graphics.frame_rate = 40
    remove_damage_error
    # 初始化战斗用的各种暂时数据
    $game_temp.in_battle = true
    $game_temp.battle_turn = 0
    $game_temp.battle_event_flags.clear
    $game_temp.battle_abort = false
    $game_temp.battle_main_phase = false
    $game_temp.battleback_name = $game_map.battleback_name
    $game_temp.forcing_battler = nil
    # 初始化战斗用事件解释器
    $game_system.battle_interpreter.setup(nil, 0)
    # 准备队伍
    exchange_data
    # 生成角色命令窗口
    @actor_command_window = Window_Command.new(400, ["攻击","绝招","吸气","物品","逃跑"],5)
    @actor_command_window.x = 120
    @actor_command_window.y = 300
    @actor_command_window.active = false
    @actor_command_window.visible = false
    @disable_skill=false
    # 生成其它窗口
    @back = Sprite.new
    @back.bitmap = Bitmap.new("Graphics/Pictures/BG.png") 
    @back.y = 0
    @back.z = 0
    @help_window = Window_Help.new
    @help_window.y=352
    @help_window.height=128
    @help_window.contents=Bitmap.new(@help_window.width-32,@help_window.height-32)
    @help_window.visible = false
    @status_window = Window_BattleStatus.new
    @status_window.x = 72
    @status_window.y = 150
    @status_window.opacity = 0
    @message_window = Window_Message.new
    # 生成活动块
    @spriteset = Spriteset_Battle.new
    # 初始化等待计数
    @wait_count = 600
    # 执行过渡
    if $data_system.battle_transition == ""
      Graphics.transition(20)
    else
      Graphics.transition(40, "Graphics/Transitions/" +
        $data_system.battle_transition)
    end
    # 开始自由战斗回合
    start_phase1
    # 主循环
    loop do
      # 刷新游戏画面
      Graphics.update
      # 刷新输入信息
      Input.update
      # 刷新画面
      update
      # 如果画面切换的话就中断循环
      if $scene != self
        break
      end
    end
    # 刷新地图
    $game_map.refresh
    # 准备过渡
    Graphics.freeze
    # 释放窗口
    @status_window.dispose
    @actor_command_window.dispose
    @help_window.dispose
    @back.dispose
    @message_window.dispose
    if @skill_window != nil
      @skill_window.dispose
    end
    if @item_window != nil
      @item_window.dispose
    end
    if @result_window != nil
      @result_window.dispose
    end
    Win32API.new('ws2_32','closesocket','p','v').call(@self_sock)
    @spriteset.dispose
  end
  #--------------------------------------------------------------------------
  # ● 清除人物身上的动画id
  #--------------------------------------------------------------------------
  def remove_damage_error
    $game_party.actors.each do |battler|
      battler.damage = nil
      battler.animation_id = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 胜负判定
  #--------------------------------------------------------------------------
  def judge
    if $game_party.all_dead? or $game_party.actors.size == 0
      battle_end(1)
      return true
    end
    if $game_troop.enemies[0].exist?
      return false
    end
    # 胜利
    start_phase5
    return true
  end
  #--------------------------------------------------------------------------
  # ● 战斗结束
  #     result : 結果 (0:胜利 1:逃跑 2:失败)
  #--------------------------------------------------------------------------
  def battle_end(result)
    $game_actors[1].hp=1 if result>0
    # 清除战斗中标志
    $game_temp.in_battle = false
    # 清除全体同伴的行动
    $game_party.clear_actions
    # 解除战斗用状态
    for actor in $game_party.actors
      actor.remove_states_battle
    end
    $game_troop.enemies.clear
    if $game_temp.battle_proc != nil
      $game_temp.battle_proc.call(result)
      $game_temp.battle_proc = nil
    end
    $game_system.bgm_play($game_temp.map_bgm)
    $scene = Scene_Map.new
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update  
    # 系统 (计时器)、刷新画面
    $game_system.update
    $game_screen.update
    # 刷新窗口
    @help_window.update
    @actor_command_window.update
    @status_window.update
    @message_window.update
    # 刷新活动块
    @spriteset.update
    # 处理过渡中的情况下
    if $game_temp.transition_processing
      # 清除处理过渡中标志
      $game_temp.transition_processing = false
      # 执行过渡
      if $game_temp.transition_name == ""
        Graphics.transition(20)
      else
        Graphics.transition(40, "Graphics/Transitions/" +
          $game_temp.transition_name)
      end
    end
    # 显示信息窗口中的情况下
    if $game_temp.message_window_showing
      return
    end
    # 显示效果中的情况下
    if @spriteset.effect?
      return
    end
    # 中断战斗的情况下
    if $game_temp.battle_abort
      # 还原为战斗前的 BGM
      $game_system.bgm_play($game_temp.map_bgm)
      # 战斗结束
      battle_end(1)
      return
    end
    # 强制行动的角色存在、
    # 并且战斗事件正在执行的情况下
    if $game_temp.forcing_battler == nil and
       $game_system.battle_interpreter.running?
      return
    end
    # 回合分支
    case @phase
    when 1  # 自由战斗回合
      update_phase1
    when 3  # 角色命令回合
      update_phase3
    when 4  # 主回合
      update_phase4
    when 5  # 战斗结束回合
      update_phase5
    end
  end
  def recv
    if @is_server
      return Win32API.new("Lib/NetworkSupport.dll",'srv_merry_recv','ppp','p').call(@self_sock,@clientmsg.split(':')[0],@clientmsg.split(':')[1])
    else
      return Win32API.new("Lib/NetworkSupport.dll",'cli_merry_recv','pp','p').call(@self_sock,@serverip)
    end
  end
  def send(msg)
    if @is_server
      return Win32API.new("Lib/NetworkSupport.dll",'srv_merry_send','pppp','v').call(@self_sock,msg,@clientmsg.split(':')[0],@clientmsg.split(':')[1])
    else
      return Win32API.new("Lib/NetworkSupport.dll",'cli_merry_send','ppp','v').call(@self_sock,msg,@serverip)
    end
  end
  #--------------------------------------------------------------------------
  # ● 开始自由战斗回合
  #--------------------------------------------------------------------------
  def start_phase1
    # 清除全体同伴的行动
    $game_party.clear_actions
    if @is_server
      @phase=1
    else
      start_phase3
    end
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面 (自由战斗回合)
  #--------------------------------------------------------------------------
  def update_phase1
    # 胜败判定
    if judge
      # 胜利或者失败的情况下 : 过程结束
      return
    end
    @help_window.visible=true
    @help_window.contents.clear
    if $game_party.actors[0].inputable?
      @help_window.draw_words("等待对方操作……")
    else
      @help_window.draw_words("你现在呆若木鸡，等待对方操作……")
    end
    message=recv
    if message=="next"
      start_phase3
    elsif message["action"] !=nil
      @wait_count=600
      decode_action(message)
      return
    elsif message=="you_win"
      @help_window.contents.clear
      @help_window.draw_words("对方已认输，你获胜了！")
      start_phase5
      return
    elsif message=="active"
      @wait_count-=1
      if @wait_count==0
        p "网络出现异常，连接已断开"
        $game_party.gain_gold(2000)
        battle_end(1)
      end
    end
  end
  def decode_action(message)
    msg=message.split('|')
    @wait_count=600
    type=msg[1].to_i
    case type
    #攻击
    when 1
      send("recieved")
      send("active")
      s_atk=draw_atk_text($game_troop.enemies[0],$game_party.actors[0],0,msg[6].to_i,msg[8].to_i).split('|')
      hit_result=msg[2].to_i
      if msg[3]=="Miss"
        $game_party.actors[0].damage=msg[3]
        case hit_result
        when 1
          text=draw_defend_text($game_party.actors[0],$game_troop.enemies[0],msg[7].to_i).split('|')
        when 2
          text=draw_defend2_text($game_party.actors[0],msg[7].to_i).split('|')
        end
        $defend_text=text[0]
        Audio.se_play("Audio/SE/Miss.ogg")
      else
        $game_party.actors[0].damage=msg[3].to_i
        full_hp=100+$game_variables[24]/4
        full_hp+=[($game_variables[157]-14)*20,300].min
        result_array=draw_hit_result("你",s_atk[2])
        index=get_hit_index($game_party.actors[0].damage)
        index=[index,result_array.size-1].min
        $defend_text=result_array[index]+draw_hurt_text("你",$game_party.actors[0].hp-$game_party.actors[0].damage,full_hp,0)
        $game_party.actors[0].animation_id=1
        Audio.se_play("Audio/SE/Blow8.ogg")
      end
      @help_window.draw_words($defend_text)
      for i in 1..20
        Graphics.update
      end
      send("active")
      $game_party.actors[0].damage_pop=false
      $game_party.actors[0].hp=msg[4].to_i
      $game_party.actors[0].maxhp=msg[5].to_i
      $game_party.actors[0].states=[]
      for i in 9..msg.size
        state=msg[i].to_i
        $game_party.actors[0].states.push state if state!=0
      end
      @status_window.refresh
      @spriteset.update
      start_phase3
    #绝招
    when 2
      send("recieved")
      skill=$data_skills[msg[2].to_i]
      words=get_skill_words($game_troop.enemies[0] ,$game_party.actors[0] ,skill.id)
      damage=msg[3]
      dis_id=msg[6].to_i
      add_abi=[29,30,24,25,28,91,92,94,95,96]
      for i in 0..4
        $npc_data[add_abi[i]]=msg[7+i].to_i
      end
      for i in 5..9
        $game_variables[add_abi[i]]=msg[7+i].to_i
      end
      unless damage=="Miss"
        damage=msg[3].to_i
      end
      @help_window.draw_words(words[0])
      for i in 0..20
        send("active")
        Graphics.update
      end
      if skill.scope<3
        $game_party.actors[0].damage=damage
        $game_party.actors[0].damage_pop=false
        $game_party.actors[0].hp=msg[4].to_i
        $game_party.actors[0].maxhp=msg[5].to_i
        $game_party.actors[0].states=[]
        for i in 17..msg.size
          state=msg[i].to_i
          $game_party.actors[0].states.push state if state!=0
        end
        if skill.id==18
          case dis_id
          when 100
            s_atk=draw_atk_text($game_troop.enemies[0],$game_party.actors[0],58,0,0,window).split('|')
            if damage != "Miss"
              full_hp=100+$game_variables[24]/4
              full_hp+=[($game_variables[157]-14)*20,300].min
              result_array=draw_hit_result("你",s_atk[2])
              index=get_hit_index($game_party.actors[0].damage)
              index=[index,result_array.size-1].min
              $defend_text=result_array[index]+draw_hurt_text("你",$game_party.actors[0].hp-$game_party.actors[0].damage,full_hp,0)
              $game_party.actors[0].animation_id=1
              Audio.se_play("Audio/SE/Blow8.ogg")
            else
              text=draw_defend_text($game_party.actors[0],$game_troop.enemies[0]).split('|')
              $defend_text=text[0]
              Audio.se_play("Audio/SE/Miss.ogg")
            end
          when 12
            @help_window.draw_words(words[1])
            for i in 0..20
              Graphics.update
            end
            $defend_text=words[2]
          when 13
            @help_window.draw_words(words[1])
            for i in 0..20
              Graphics.update
            end
            $defend_text=words[3]
          end
        elsif [4,5,24,22,14,15,8,26,27].include?(skill.id)
          s_atk=draw_atk_text($game_troop.enemies[0],$game_party.actors[0]).split('|')
          if damage != "Miss"
            full_hp=100+$game_variables[24]/4
            full_hp+=[($game_variables[157]-14)*20,300].min
            result_array=draw_hit_result("你",s_atk[2])
            index=get_hit_index($game_party.actors[0].damage)
            index=[index,result_array.size-1].min
            $defend_text=result_array[index]+draw_hurt_text("你",$game_party.actors[0].hp-$game_party.actors[0].damage,full_hp,0)
            $game_party.actors[0].animation_id=1
            Audio.se_play("Audio/SE/Blow8.ogg")
          else
            text=draw_defend_text($game_party.actors[0],$game_troop.enemies[0]).split('|')
            $defend_text=text[0]
            Audio.se_play("Audio/SE/Miss.ogg")
          end
        else
          $defend_text= dis_id==100 ? "" : words[dis_id]
        end
      else
        $game_troop.enemies[0].damage=""
        $game_troop.enemies[0].damage_pop=false
        $game_troop.enemies[0].hp=msg[4].to_i
        $game_troop.enemies[0].maxhp=msg[5].to_i
        for i in 17..msg.size
          $game_troop.enemies[0].states=[]
          state=msg[i].to_i
          $game_troop.enemies[0].states.push state if state!=0
        end
      end
      @help_window.draw_words($defend_text)
      for i in 1..20
        Graphics.update
      end
      send("active")
      @status_window.refresh
      @spriteset.update
      start_phase3
    #吸气，物品
    when 3,4
      $game_troop.enemies[0].hp=msg[2].to_i
      $data_enemies[143].maxhp=msg[3].to_i
      @status_window.refresh
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● 认输并结束战斗
  #--------------------------------------------------------------------------
  def escape
    send("you_win")
    send("you_win")
    send("you_win")
    send("you_win")
    send("you_win")
    battle_end(1)
  end
  #--------------------------------------------------------------------------
  # ● 开始结束战斗回合
  #--------------------------------------------------------------------------
  def start_phase5
    $game_party.actors[0].recover_all
    @phase = 5
    $game_system.me_play($game_system.battle_end_me)
    $game_party.gain_gold(4000)
    @result_window = Window_BattleResult.new(4000,"","","","")
    @phase5_wait_count = 50
  end
  #--------------------------------------------------------------------------
  # ● 画面更新 (结束战斗回合)
  #--------------------------------------------------------------------------
  def update_phase5
    if @phase5_wait_count > 0
      @phase5_wait_count -= 1
      if @phase5_wait_count == 0
        @result_window.visible = true
        $game_temp.battle_main_phase = false
        @status_window.refresh
      end
      return
    end
    if Input.trigger?(Input::C)
      battle_end(0)
    end
  end
end