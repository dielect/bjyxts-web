require 'js'
Dir.chdir('/game')
$RG_JS = JS.global[:RG]
begin
  scripts = JS.global[:RGScripts]
  n = scripts[:length].to_i
  n.times do |i|
    s = scripts[i]
    name = s[0].to_s
    code = s[1].to_s
    TOPLEVEL_BINDING.eval(code, name, 1)
  end
  $RG_JS.call(:onExit)
rescue SystemExit
  $RG_JS.call(:onExit)
rescue Exception => e
  bt = (e.backtrace || [])[0, 16].join("\n")
  $RG_JS.call(:onError, "#{e.class}: #{e.message}\n#{bt}")
end
nil
