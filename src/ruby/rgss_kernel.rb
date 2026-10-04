# Ruby 1.8 / RGSS1 kernel compatibility for ruby.wasm (Ruby 3.4)
require "zlib"
module RGWeb
  class << self
    def utf8(s)
      return s.to_s unless s.is_a?(String)
      return s if s.encoding == Encoding::UTF_8 && s.valid_encoding?
      t = s.dup.force_encoding('UTF-8')
      t.valid_encoding? ? t : t.scrub('?')
    end
    # 1.8 Marshal data has no encoding info: mark every String as UTF-8.
    def fix_enc(o, seen = {})
      case o
      when String
        o.force_encoding('UTF-8') unless o.frozen? || o.encoding == Encoding::UTF_8
        o
      when Array
        return o if seen[o.object_id]
        seen[o.object_id] = true
        o.each_with_index do |e, i|
          if e.is_a?(String) && e.frozen? && e.encoding != Encoding::UTF_8
            o[i] = e.dup.force_encoding('UTF-8')
          else
            fix_enc(e, seen)
          end
        end
        o
      when Hash
        return o if seen[o.object_id]
        seen[o.object_id] = true
        if o.keys.any? { |k| k.is_a?(String) && k.encoding != Encoding::UTF_8 }
          pairs = o.to_a
          o.clear
          pairs.each { |k, v| o[k.is_a?(String) ? k.dup.force_encoding('UTF-8') : k] = fix_enc(v, seen) }
        else
          o.each_value { |v| fix_enc(v, seen) }
        end
        o
      when Numeric, NilClass, TrueClass, FalseClass, Symbol, Table, Color, Tone, Rect, Bitmap, Class, Module
        o
      else
        return o if seen[o.object_id]
        seen[o.object_id] = true
        o.instance_variables.each do |iv|
          v = o.instance_variable_get(iv)
          if v.is_a?(String) && v.frozen? && v.encoding != Encoding::UTF_8
            o.instance_variable_set(iv, v.dup.force_encoding('UTF-8'))
          else
            fix_enc(v, seen)
          end
        end
        o
      end
    end
    # byte-based slicing (Ruby 1.8 String#slice semantics) that never splits a UTF-8 char
    def bslice(s, start, len)
      s = utf8(s)
      out = +''
      pos = 0
      s.each_char do |ch|
        b = ch.bytesize
        if pos >= start && pos + b <= start + len
          out << ch
        end
        pos += b
        break if pos >= start + len
      end
      out
    end
    def msgbox(text)
      await_js(:msgbox, utf8(text.to_s))
      nil
    end
  end
end

module Kernel
  def load_data(fn)
    fn = RGWeb.utf8(fn.to_s)
    data = File.open(fn, 'rb') { |f| f.read }
    RGWeb.fix_enc(Marshal.load(data))
  end
  def save_data(obj, fn)
    File.open(RGWeb.utf8(fn.to_s), 'wb') { |f| Marshal.dump(obj, f) }
    nil
  end
  # RGSS: p / print show a message box
  def p(*args)
    return nil if args.empty?
    RGWeb.msgbox(args.map { |a| a.is_a?(String) ? RGWeb.utf8(a) : a.inspect }.join("\n"))
    args.size == 1 ? args[0] : args
  end
  def print(*args)
    RGWeb.msgbox(args.map { |a| RGWeb.utf8(a.to_s) }.join)
    nil
  end
  alias_method :__rg_rand, :rand
  # Ruby 1.8: rand(x) uses x.to_i.abs, rand(0)/rand(nil) -> float
  def rand(max = 0)
    n = max.is_a?(Range) ? nil : max.to_i.abs
    return __rg_rand(max) if n.nil?
    n == 0 ? __rg_rand : __rg_rand(n)
  end
  module_function :rand, :load_data, :save_data
  public :rand, :load_data, :save_data, :p, :print
end

class Array
  # Ruby 1.8: Array#to_s == join
  def to_s
    join
  end
end

class Hash
  def index(v)
    key(v)
  end unless method_defined?(:index)
end

class Object
  # Ruby 1.8 Object#type
  def type
    self.class
  end unless method_defined?(:type)
end

class Integer
  def to_sym_18
    self
  end
end

class Win32API
  def initialize(dll, func, *_args)
    @dll = dll.to_s
    @func = func.to_s
  end
  def call(*_args)
    0
  end
  alias Call call
end

# ---------------------------------------------------------------------------
# Persist written files (save games) to browser storage
class File
  class << self
    alias_method :__rg_open, :open
    def open(name, mode = 'r', *rest, &blk)
      name = RGWeb.utf8(name.to_s)
      f = __rg_open(name, mode, *rest)
      f.__rg_mark_write(name) if mode.is_a?(String) && mode =~ /[wa+]/
      return f unless blk
      begin
        blk.call(f)
      ensure
        f.close unless f.closed?
      end
    end
    alias_method :__rg_delete, :delete
    def delete(*names)
      r = __rg_delete(*names)
      names.each { |n| RGWeb.call(:unpersist, RGWeb.utf8(n.to_s)) }
      r
    end
    alias unlink delete
  end
  def __rg_mark_write(n)
    @__rg_wpath = n
  end
  alias_method :__rg_close, :close
  def close
    r = __rg_close
    if @__rg_wpath && @__rg_wpath !~ /errors\.txt\z/
      RGWeb.call(:persist, @__rg_wpath)
    end
    r
  end
end

$DEBUG = false
$BTEST = false
