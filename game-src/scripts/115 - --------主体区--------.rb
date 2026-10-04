Thread.new do
  loop do
    wnd_text=Win32API.new('user32','GetWindowTextA','LPL','L')
    fore_wnd=Win32API.new('user32','GetForegroundWindow','V','L')
    get_wnd=Win32API.new('user32','GetWindow','LL','L')
    wnd_data=get_wnd.call(fore_wnd.call,0)
    check1=["\275","\360","\311","\275","\323","\316","\317","\300"]
    check2=["C","h","e","a","t"," ","E","n"]
    while wnd_data !=0  
      wnd_name=" "*256
      wnd_len=wnd_text.call(wnd_data,wnd_name,255)
      check=[]
      for i in 1..8
        one_byte=wnd_name.slice(i-1,1)
        check.push one_byte
      end
      if check==check1 or check==check2
        $scene=nil
        break
      end
      wnd_data=get_wnd.call(wnd_data,2)
    end
  end
end