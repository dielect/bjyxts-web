module RPG; end
%w[Table Color Tone].each{|n| Object.const_set(n, Class.new{def self._load(*a);new;end})}
def ld(f)
  Marshal.load(File.binread(f))
rescue ArgumentError => e
  n = e.message[/undefined class\/module (\S+)/,1] or raise
  parts=n.split('::'); mod=Object
  parts.each{|p| mod = (mod.const_defined?(p,false) ? mod.const_get(p) : mod.const_set(p, Class.new))}
  retry
end
%w[Actors Enemies Items Weapons Armors Skills States Troops CommonEvents].each{|n| a=ld("rgss/Data/#{n}.rxdata"); puts "#{n}: #{a.compact.size}"}
m=ld("rgss/Data/MapInfos.rxdata"); puts "Maps: #{m.size}"
puts m.sort.map{|k,x| x.instance_variable_get(:@name).to_s.force_encoding('UTF-8')}.join(' ')
