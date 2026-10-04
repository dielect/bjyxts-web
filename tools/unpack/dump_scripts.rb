require 'zlib'
out = ARGV[1]; Dir.mkdir(out) rescue nil
s = Marshal.load(File.binread(ARGV[0]))
s.each_with_index do |(id, name, code), i|
  src = Zlib::Inflate.inflate(code).force_encoding('UTF-8')
  nm = name.to_s.force_encoding('UTF-8').gsub(/[\/\\:*?"<>|]/, '_')
  File.binwrite(File.join(out, format('%03d - %s.rb', i, nm.empty? ? 'unnamed' : nm)), src)
end
puts s.size
