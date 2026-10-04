#==============================================================================
# ■ Scene_PreNetBattle
#------------------------------------------------------------------------------
# 　准备联机对战的类。
#==============================================================================

class Scene_PreNetBattle
  def initialize(type)
    @is_server=type
    $game_temp.msg_for_socket
    @wait_count=1200
    $game_temp.battle_calling = false
    $game_temp.menu_calling = false
    $game_temp.menu_beep = false
    @connected=false
    @server_ready=false
  end
  def main
    @screen = Spriteset_Map.new
    @help_window = Window_Help.new
    @help_window.y=416
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
    @screen.dispose
    @help_window.dispose
  end
  def close_connect
    unless @client_sock.nil?
      Win32API.new('ws2_32','closesocket','p','v').call(@client_sock)
      @client_sock=nil
    end
    unless @server_sock.nil?
      Win32API.new('ws2_32','closesocket','p','v').call(@server_sock)
      @server_sock=nil
    end
  end
  def update
    if @is_server
      update_server_connect
    else
      update_client_connect
    end
  end
  def update_client_connect
    if @client_sock.nil?
      enter_ip
      unless check_ip(@serverip)
        print "IP格式不正确，请重新输入！"
        return
      end
      @client_sock=Win32API.new('Lib/NetworkSupport','create_client','v','L').call
      @wait_count=1200
      @help_window.draw_words("正在连接到："+@serverip)
    elsif @connected
      unless @server_ready
        Win32API.new('Lib/NetworkSupport','cli_merry_send','ppp','v').call(@client_sock,@actor_data,@serverip)
        msg=Win32API.new('Lib/NetworkSupport','cli_merry_recv','pp','p').call(@client_sock,@serverip)
        if msg=="recieved"
          @server_ready=true
          return
        end
      else
        msg=Win32API.new('Lib/NetworkSupport','cli_merry_recv','pp','p').call(@client_sock,@serverip)
        if msg["actor_data"]=="actor_data"
          $game_temp.msg_for_net_battler=msg
          Win32API.new('Lib/NetworkSupport','cli_merry_send','ppp','v').call(@client_sock,"recieved",@serverip)
          Win32API.new('Lib/NetworkSupport','cli_merry_send','ppp','v').call(@client_sock,"recieved",@serverip)
          Win32API.new('Lib/NetworkSupport','cli_merry_send','ppp','v').call(@client_sock,"recieved",@serverip)
          Win32API.new('Lib/NetworkSupport','cli_merry_send','ppp','v').call(@client_sock,"recieved",@serverip)
          Win32API.new('Lib/NetworkSupport','cli_merry_send','ppp','v').call(@client_sock,"recieved",@serverip)
          $game_temp.msg_for_socket=@serverip
          $game_party.gain_gold(-2000)
          $scene=Scene_NetBattle.new(false,@client_sock)
          return
        end
      end
    else
      if @wait_count==-1
        close_connect
        p "超时，请检查网络！"
        $scene=Scene_Map.new
        return
      end
      if Input.trigger?(Input::B)
        close_connect
        p "已中断连接！"
        $scene=Scene_Map.new
        return
      end
      @wait_count-=1
      if 1==Win32API.new('Lib/NetworkSupport','client_connect','pp','i').call(@client_sock,@serverip)
        @connected=true
        @help_window.set_text("已连接！")
        encode_actor_data
        $game_temp.msg_for_net_battler=""
      end
    end
  end
  def update_server_connect
    if @server_sock.nil?
      @server_sock=Win32API.new('Lib/NetworkSupport','create_server','v','L').call
      self_ip=Win32API.new('Lib/NetworkSupport','get_host_ip_string','v','p').call
      if Win32API.new('Lib/NetworkSupport','check_InternalIP','v','i').call==1
        type="  类型：外网"
      else
        type="  类型：内网"
      end
      @help_window.set_text("本机IP:"+self_ip+type)
      @wait_count=1200
    elsif @connected
      msg=Win32API.new('Lib/NetworkSupport','srv_merry_recv','ppp','p').call(@server_sock,@client_msg.split(':')[0],@client_msg.split(':')[1])
      if @client_ready
        if msg=="recieved"
          $game_party.gain_gold(-2000)
          $scene=Scene_NetBattle.new(true,@server_sock)
          return
        else
          Win32API.new('Lib/NetworkSupport','srv_merry_send','pppp','v').call(@server_sock,@actor_data,@client_msg.split(':')[0],@client_msg.split(':')[1])
        end
      else
        if msg["actor_data"]=="actor_data"
          @client_ready=true
          $game_temp.msg_for_net_battler=msg
          Win32API.new('Lib/NetworkSupport','srv_merry_send','pppp','v').call(@server_sock,"recieved",@client_msg.split(':')[0],@client_msg.split(':')[1])
          Win32API.new('Lib/NetworkSupport','srv_merry_send','pppp','v').call(@server_sock,"recieved",@client_msg.split(':')[0],@client_msg.split(':')[1])
          Win32API.new('Lib/NetworkSupport','srv_merry_send','pppp','v').call(@server_sock,"recieved",@client_msg.split(':')[0],@client_msg.split(':')[1])
          Win32API.new('Lib/NetworkSupport','srv_merry_send','pppp','v').call(@server_sock,"recieved",@client_msg.split(':')[0],@client_msg.split(':')[1])
          Win32API.new('Lib/NetworkSupport','srv_merry_send','pppp','v').call(@server_sock,"recieved",@client_msg.split(':')[0],@client_msg.split(':')[1])
        end
      end
    else
      if @wait_count==-1
        close_connect
        p "超时，请检查网络！"
        $scene=Scene_Map.new
        return
      end
      if Input.trigger?(Input::B)
        close_connect
        p "已中断连接！"
        $scene=Scene_Map.new
        return
      end
      @wait_count-=1
      @client_msg=Win32API.new('Lib/NetworkSupport','server_accept','p','p').call(@server_sock)
      if @client_msg !="0"
        @connected=true
        @client_ready=false
        $game_temp.msg_for_socket=@client_msg
        @help_window.set_text("已连接！")
        $game_temp.msg_for_net_battler=""
        encode_actor_data
      end
    end
  end
  def encode_actor_data
    actor=$game_party.actors[0]
    @actor_data="actor_data"+"|"+actor.name+"|"+$gender+"|"+
      actor.hp.to_s+"|"+actor.sp.to_s+"|"+
      actor.maxhp.to_s+"|"+actor.maxsp.to_s+"|"+$game_variables[23].to_s+"|"+
      $game_variables[11].to_s+"|"+$game_variables[12].to_s+
      "|"+$game_variables[13].to_s+"|"+$game_variables[14].to_s+"|"
    for i in 29..33
      @actor_data+=$game_variables[i].to_s+"|"
    end
    @actor_data+=actor.weapon_id.to_s+"|"+actor.armor3_id.to_s+"|"+
      actor.armor4_id.to_s+"| 40 |"+$game_variables[40].to_s+"| 45 |"+
      $game_variables[45].to_s+"| 46 |"+$game_variables[46].to_s+"| 47 |"+
      $game_variables[47].to_s+"| 48 |"+$game_variables[48].to_s+"|"
    if actor.weapon_id !=0
      sk_id=get_weapon_base_skill
      @actor_data+=sk_id.to_s+"|"+$game_variables[sk_id].to_s+"| 0 | 0 |"
    else
      @actor_data+="0 | 0 | 0 | 0 |"
    end
    for i in [51,$game_variables[29],$game_variables[30],$game_variables[31],
              $game_variables[32]]
      @actor_data+=i.to_s+"|"+$game_variables[i].to_s+"|"
    end
    @actor_data+=$game_variables[94].to_s+"|"+$game_variables[95].to_s+"|"+
                 $game_variables[19].to_s+"|"+$game_variables[21].to_s+"|"+
                 $game_variables[96].to_s+"|"+$game_variables[91].to_s+"|"+
                 $game_variables[92].to_s+"|"
  end
  def enter_ip
    Win32API.new("Lib/ActorNameSupport.dll", "CreateInputBox", [], '').call
    Win32API.new("Lib/ActorNameSupport.dll", "SetEdit", ['I','I','I','I','I','I','I'], '').Call(50,20,200,32,0,128,128)
    Win32API.new("Lib/ActorNameSupport.dll", "SetEditFont", ['P','I','I','I','I'], '').call('宋体',12,255,255,255)
    Win32API.new("Lib/ActorNameSupport.dll", "SetBox", ['I','I','I'], '').Call(300,72,0)
    ip_thread = Thread.new{@serverip=Win32API.new("Lib/ActorNameSupport.dll", "NameInputBox", ['P'], 'P').call("1.0.0.1")}
  end
  def check_ip(str_ip)
    check_char = "0123456789.".scan(/./)
    dot_num = 0
    for char in str_ip.scan(/./)
      dot_num += 1 if char == "."
      if !check_char.include? char
        return false
      end
    end
    if dot_num != 3
      return false
    end
    g_char = str_ip.split(/\./)
    if g_char.size != 4
      return false
    end
    for i in g_char
      if i.to_i < 0 or i.to_i > 255
        return false
      end
    end
    return true
  end
end