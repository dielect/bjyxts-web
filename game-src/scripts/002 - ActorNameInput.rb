#--------------------------------------------------------------------------
# ● 显示RgssInputBox.dll中的输入角色名称的对话框
#    作者：notexist
#--------------------------------------------------------------------------
=begin
$NameInputBox = Win32API.new("ActorNameSupport.dll", "NameInputBox", ['P'], 'P')
#创建对话框窗口，在调用NameInputBox之前必须调用这个函数
$CreateInputBox =  Win32API.new("ActorNameSupport.dll", "CreateInputBox", [], '')
#设置窗口，参数分别为宽度，高度，和载入的skin图片是否拉伸
#在后面的LoadSkin调用中会根据图片情况自动设置窗口宽度高度
#所以不必手工调用这个函数
$InputBox_SetBox =  Win32API.new("ActorNameSupport.dll", "SetBox", ['I','I','I'], '')
#载入背景图片，内容为图片的文件名（不包括路径）
#支持BMP和GIF，载入后会自动设置输入的窗口宽度和高度
#$InputBox_LoadSkin =  Win32API.new("ActorNameSupport.dll", "LoadSkin", ['P'], '')
#设置窗口中文本输入框的位置和大小
#参数分别为X偏移(偏移相对于窗口左上角)，Y偏移，宽度，高度
#以及输入框底色的蓝色，绿色，红色分量，颜色分量的范围是0～255
$InputBox_SetEdit =  Win32API.new("ActorNameSupport.dll", "SetEdit", ['I','I','I','I','I','I','I'], '')
#设置文本输入框内输入文字的字体信息
#参数分别为字体名称（例如“宋体”），字体大小（五号字为11）
#字体颜色的蓝色，绿色，红色分量，颜色分量的范围是0～255
$InputBox_SetEditFont =  Win32API.new("ActorNameSupport.dll", "SetEditFont", ['P','I','I','I','I'], '')
#释放对话框窗口，理论上创建之后就应该释放，不过游戏退出时应该能自动释放
#所以不必手工调用这个函数
#$FreeInputBox =  Win32API.new("ActorNameSupport.dll", "FreeInputBox", [], '')

#创建
$CreateInputBox.Call
#载入背景图fox.jpg，这时设定了窗口宽度高度
#$InputBox_LoadSkin.Call('fox.jpg')
#设置文本输入框位置，并且设定底色为红色
$InputBox_SetEdit.Call(50,20,200,32,0,128,128)
#设定输入字体为黑体，字号为12(应该是“小四”)，颜色为白色
$InputBox_SetEditFont.Call('宋体',12,255,255,255)
#重新设置输入窗口宽度和高度
$InputBox_SetBox.Call(300,72,0)
=end
def ActorNameInput(actorID)
  Win32API.new("Lib/ActorNameSupport.dll", "CreateInputBox", [], '').call
  Win32API.new("Lib/ActorNameSupport.dll", "SetEdit", ['I','I','I','I','I','I','I'], '').Call(50,20,200,32,87,176,144)
  Win32API.new("Lib/ActorNameSupport.dll", "SetEditFont", ['P','I','I','I','I'], '').call('宋体',12,0,0,0)
  Win32API.new("Lib/ActorNameSupport.dll", "SetBox", ['I','I','I'], '').Call(300,72,0)
  actor = $game_party.actors[0]
  thename = actor.name
  thename = Win32API.new("ActorNameSupport.dll", "NameInputBox", ['P'], 'P').call(thename)
  if thename != ""
    actor.name = thename
  end
end