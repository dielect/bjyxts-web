# RGSS1 core classes for ruby.wasm. Rendering is delegated to JS (globalThis.RG).
require 'js'

module RGWeb
  JSRG = JS.global[:RG]
  @elements = []          # live drawables (Sprite/Plane/Window/Tilemap/Viewport)
  @seq = 0
  @dispose_queue = []
  class << self
    attr_reader :elements
    def call(name, *args)
      JSRG.call(name, *args)
    end
    def next_seq
      @seq += 1
    end
    def register(o)
      @elements << o
    end
    def unregister(o)
      @elements.delete(o)
    end
    def queue_dispose(id)
      @dispose_queue << id
    end
    def flush_dispose
      return if @dispose_queue.empty?
      call(:bmpDisposeList, @dispose_queue.join(','))
      @dispose_queue.clear
    end
    def display_list
      out = []
      @elements.each do |e|
        r = e.__record
        out << r if r
      end
      '[' + out.join(',') + ']'
    end
    def await_js(name, *args)
      JSRG.call(name, *args).await
    end
    # Report from inside the Ruby loop; JS timers must not re-enter a running VM.
    def diagnostic_tick
      scene = defined?($scene) ? $scene : nil
      map = defined?($game_map) && $game_map ? $game_map.map_id : 0
      @diagnostic_frames = (@diagnostic_frames || 0) + 1
      return if @diagnostic_scene_id == scene.object_id && @diagnostic_map == map && @diagnostic_frames % 40 != 0
      @diagnostic_scene_id = scene.object_id
      @diagnostic_map = map
      player = defined?($game_player) ? $game_player : nil
      call(:diagnosticState, scene ? scene.class.name : '', map,
           player ? player.x : 0, player ? player.y : 0, @elements.size,
           GC.stat(:count), GC.stat(:heap_live_slots))
    rescue StandardError
      nil # Logging must not interrupt gameplay.
    end
    def num(v)
      v.to_i
    end
  end
end

# ---------------------------------------------------------------------------
class Color
  attr_reader :red, :green, :blue, :alpha
  def initialize(r = 0, g = 0, b = 0, a = 255)
    set(r, g, b, a)
  end
  def set(r, g = 0, b = 0, a = 255)
    if r.is_a?(Color)
      c = r
      @red, @green, @blue, @alpha = c.red, c.green, c.blue, c.alpha
    else
      self.red = r; self.green = g; self.blue = b; self.alpha = a
    end
    self
  end
  def red=(v);   @red   = __c(v); end
  def green=(v); @green = __c(v); end
  def blue=(v);  @blue  = __c(v); end
  def alpha=(v); @alpha = __c(v); end
  def __c(v)
    v = v.to_f
    v < 0 ? 0.0 : (v > 255 ? 255.0 : v)
  end
  def ==(o)
    o.is_a?(Color) && @red == o.red && @green == o.green && @blue == o.blue && @alpha == o.alpha
  end
  def to_s
    format('(%f, %f, %f, %f)', @red, @green, @blue, @alpha)
  end
  alias inspect to_s
  def _dump(_d = 0)
    [@red, @green, @blue, @alpha].pack('E4')
  end
  def self._load(s)
    new(*s.unpack('E4'))
  end
  def __css
    "#{@red.to_i},#{@green.to_i},#{@blue.to_i},#{@alpha.to_i}"
  end
end

class Tone
  attr_reader :red, :green, :blue, :gray
  def initialize(r = 0, g = 0, b = 0, gray = 0)
    set(r, g, b, gray)
  end
  def set(r, g = 0, b = 0, gray = 0)
    if r.is_a?(Tone)
      t = r
      @red, @green, @blue, @gray = t.red, t.green, t.blue, t.gray
    else
      self.red = r; self.green = g; self.blue = b; self.gray = gray
    end
    self
  end
  def __c(v)
    v = v.to_f
    v < -255 ? -255.0 : (v > 255 ? 255.0 : v)
  end
  def red=(v);   @red   = __c(v); end
  def green=(v); @green = __c(v); end
  def blue=(v);  @blue  = __c(v); end
  def gray=(v)
    v = v.to_f
    @gray = v < 0 ? 0.0 : (v > 255 ? 255.0 : v)
  end
  def ==(o)
    o.is_a?(Tone) && @red == o.red && @green == o.green && @blue == o.blue && @gray == o.gray
  end
  def to_s
    format('(%f, %f, %f, %f)', @red, @green, @blue, @gray)
  end
  alias inspect to_s
  def _dump(_d = 0)
    [@red, @green, @blue, @gray].pack('E4')
  end
  def self._load(s)
    new(*s.unpack('E4'))
  end
  def __css
    "#{@red.to_i},#{@green.to_i},#{@blue.to_i},#{@gray.to_i}"
  end
end

class Rect
  attr_reader :x, :y, :width, :height
  def initialize(x = 0, y = 0, w = 0, h = 0)
    set(x, y, w, h)
  end
  def set(x, y = 0, w = 0, h = 0)
    if x.is_a?(Rect)
      r = x
      @x, @y, @width, @height = r.x, r.y, r.width, r.height
    else
      @x = x.to_i; @y = y.to_i; @width = w.to_i; @height = h.to_i
    end
    self
  end
  def x=(v); @x = v.to_i; end
  def y=(v); @y = v.to_i; end
  def width=(v); @width = v.to_i; end
  def height=(v); @height = v.to_i; end
  def empty
    @x = @y = @width = @height = 0
    self
  end
  def ==(o)
    o.is_a?(Rect) && @x == o.x && @y == o.y && @width == o.width && @height == o.height
  end
  def to_s
    "(#{@x}, #{@y}, #{@width}, #{@height})"
  end
  alias inspect to_s
  def _dump(_d = 0)
    [@x, @y, @width, @height].pack('l4')
  end
  def self._load(s)
    new(*s.unpack('l4'))
  end
end

class Table
  attr_reader :xsize, :ysize, :zsize, :__ver, :__data
  def initialize(x, y = 0, z = 0)
    @dim = 1 + (y > 0 ? 1 : 0) + (z > 0 ? 1 : 0)
    @xsize = [x, 0].max
    @ysize = [y, 1].max
    @zsize = [z, 1].max
    @__data = Array.new(@xsize * @ysize * @zsize, 0)
    @__ver = 0
  end
  def [](x, y = 0, z = 0)
    return nil if x < 0 || x >= @xsize || y < 0 || y >= @ysize || z < 0 || z >= @zsize
    @__data[x + (y + z * @ysize) * @xsize]
  end
  def []=(*args)
    v = args.pop
    x = args[0]; y = args[1] || 0; z = args[2] || 0
    return v if x < 0 || x >= @xsize || y < 0 || y >= @ysize || z < 0 || z >= @zsize
    v = v.to_i
    v = ((v + 32768) & 0xFFFF) - 32768
    @__data[x + (y + z * @ysize) * @xsize] = v
    @__ver = (@__ver || 0) + 1
    v
  end
  def resize(x, y = 0, z = 0)
    old = @__data; ox = @xsize; oy = @ysize; oz = @zsize
    @dim = 1 + (y > 0 ? 1 : 0) + (z > 0 ? 1 : 0)
    @xsize = [x, 0].max; @ysize = [y, 1].max; @zsize = [z, 1].max
    @__data = Array.new(@xsize * @ysize * @zsize, 0)
    [oz, @zsize].min.times do |k|
      [oy, @ysize].min.times do |j|
        [ox, @xsize].min.times do |i|
          @__data[i + (j + k * @ysize) * @xsize] = old[i + (j + k * oy) * ox]
        end
      end
    end
    @__ver = (@__ver || 0) + 1
    self
  end
  def _dump(_d = 0)
    [@dim, @xsize, @ysize, @zsize, @__data.size].pack('l5') + @__data.pack('s*')
  end
  def self._load(s)
    dim, x, y, z, n = s.unpack('l5')
    t = allocate
    t.__init_load(dim, x, y, z, s[20, n * 2].unpack('s*'))
    t
  end
  def __init_load(dim, x, y, z, data)
    @dim = dim; @xsize = x; @ysize = y; @zsize = z; @__data = data; @__ver = 0
  end
  def __version
    @__ver || 0
  end
end

# ---------------------------------------------------------------------------
class Font
  class << self
    attr_accessor :default_name, :default_size, :default_bold, :default_italic
    attr_writer :default_color
    def default_color
      @default_color ||= Color.new(255, 255, 255, 255)
    end
    def exist?(_name)
      true
    end
  end
  @default_name = ['宋体']
  @default_size = 22
  @default_bold = false
  @default_italic = false
  attr_accessor :name, :size, :bold, :italic
  attr_reader :color
  def initialize(name = Font.default_name, size = Font.default_size)
    @name = name.is_a?(Array) ? name.dup : name
    @size = size
    @bold = Font.default_bold
    @italic = Font.default_italic
    @color = Font.default_color.dup
  end
  def color=(c)
    @color = c.is_a?(Color) ? c : Color.new
  end
  def initialize_copy(o)
    super
    @color = o.color.dup
    @name = o.name.dup if o.name.respond_to?(:dup)
  end
  def __names
    n = @name
    n = n.join("\u0001") if n.is_a?(Array)
    n.to_s
  end
end

# ---------------------------------------------------------------------------
class Bitmap
  attr_reader :__id
  def self.__finalizer(id)
    proc { RGWeb.queue_dispose(id) }
  end
  def initialize(*args)
    if args.size == 1
      path = args[0].to_s
      id = RGWeb.call(:bmpLoad, path).to_i
      raise Errno::ENOENT, path if id < 0
      @__id = id
    else
      w = args[0].to_i; h = args[1].to_i
      raise ArgumentError, 'failed to create bitmap' if w <= 0 || h <= 0
      @__id = RGWeb.call(:bmpNew, w, h).to_i
    end
    __setup
  end
  def __setup
    @width = RGWeb.call(:bmpW, @__id).to_i
    @height = RGWeb.call(:bmpH, @__id).to_i
    @font = Font.new
    @disposed = false
    ObjectSpace.define_finalizer(self, Bitmap.__finalizer(@__id))
  end
  def initialize_copy(o)
    @__id = RGWeb.call(:bmpClone, o.__id).to_i
    @width = o.width; @height = o.height
    @font = o.font.dup
    @disposed = false
    ObjectSpace.define_finalizer(self, Bitmap.__finalizer(@__id))
  end
  def font
    @font
  end
  def font=(f)
    @font = f
  end
  def dispose
    return if @disposed
    @disposed = true
    ObjectSpace.undefine_finalizer(self)
    RGWeb.call(:bmpDispose, @__id)
  end
  def disposed?
    @disposed
  end
  def width
    @width
  end
  def height
    @height
  end
  def rect
    Rect.new(0, 0, @width, @height)
  end
  def blt(x, y, src, rect, opacity = 255)
    return if src.nil? || src.disposed?
    RGWeb.call(:bmpBlt, @__id, x.to_i, y.to_i, src.__id, rect.x, rect.y, rect.width, rect.height, opacity.to_i)
  end
  def stretch_blt(dest, src, srect, opacity = 255)
    return if src.nil? || src.disposed?
    RGWeb.call(:bmpStretch, @__id, dest.x, dest.y, dest.width, dest.height, src.__id, srect.x, srect.y, srect.width, srect.height, opacity.to_i)
  end
  def fill_rect(*a)
    if a[0].is_a?(Rect)
      r = a[0]; c = a[1]
      x, y, w, h = r.x, r.y, r.width, r.height
    else
      x, y, w, h, c = a
    end
    RGWeb.call(:bmpFill, @__id, x.to_i, y.to_i, w.to_i, h.to_i, c.red.to_i, c.green.to_i, c.blue.to_i, c.alpha.to_i)
  end
  def clear
    RGWeb.call(:bmpClear, @__id)
  end
  def get_pixel(x, y)
    s = RGWeb.call(:bmpGetPixel, @__id, x.to_i, y.to_i).to_s
    Color.new(*s.split(',').map(&:to_i))
  end
  def set_pixel(x, y, c)
    RGWeb.call(:bmpSetPixel, @__id, x.to_i, y.to_i, c.red.to_i, c.green.to_i, c.blue.to_i, c.alpha.to_i)
  end
  def hue_change(h)
    return if h.to_i % 360 == 0
    RGWeb.call(:bmpHue, @__id, h.to_i)
  end
  def draw_text(*a)
    if a[0].is_a?(Rect)
      r = a[0]
      x, y, w, h = r.x, r.y, r.width, r.height
      str = a[1]; align = a[2] || 0
    else
      x, y, w, h, str = a[0], a[1], a[2], a[3], a[4]
      align = a[5] || 0
    end
    str = str.to_s
    return if str.empty?
    str = RGWeb.utf8(str)
    f = @font
    c = f.color
    RGWeb.call(:bmpText, @__id, x.to_i, y.to_i, w.to_i, h.to_i, str, align.to_i, f.__names, f.size.to_i,
               f.bold ? true : false, f.italic ? true : false, c.red.to_i, c.green.to_i, c.blue.to_i, c.alpha.to_i)
  end
  def text_size(str)
    str = RGWeb.utf8(str.to_s)
    f = @font
    w = RGWeb.call(:textSize, str, f.__names, f.size.to_i, f.bold ? true : false, f.italic ? true : false).to_i
    Rect.new(0, 0, w, f.size.to_i)
  end
end

# ---------------------------------------------------------------------------
class Viewport
  attr_reader :rect, :color, :tone, :__seq
  attr_accessor :visible, :ox, :oy
  attr_reader :z
  @@ids = 0
  def initialize(*a)
    @rect = a[0].is_a?(Rect) ? a[0].dup : Rect.new(a[0] || 0, a[1] || 0, a[2] || 640, a[3] || 480)
    @@ids += 1
    @__vid = @@ids
    @visible = true
    @z = 0; @ox = 0; @oy = 0
    @color = Color.new(0, 0, 0, 0)
    @tone = Tone.new(0, 0, 0, 0)
    @flash_color = nil; @flash_count = 0; @flash_dur = 0
    @disposed = false
    @__seq = RGWeb.next_seq
    RGWeb.register(self)
  end
  def __vid
    @__vid
  end
  def z=(v); @z = v.to_i; end
  def rect=(r); @rect = r.dup; end
  def color=(c); @color = c; end
  def tone=(t); @tone = t; end
  def dispose
    return if @disposed
    @disposed = true
    RGWeb.unregister(self)
  end
  def disposed?
    @disposed
  end
  def flash(color, duration)
    @flash_color = color; @flash_dur = duration; @flash_count = duration
  end
  def update
    @flash_count -= 1 if @flash_count > 0
  end
  def __record
    c = @color
    if @flash_count > 0 && @flash_color
      a = @flash_color.alpha * @flash_count / @flash_dur
      c = Color.new(@flash_color.red, @flash_color.green, @flash_color.blue, [a, c.alpha].max) if a > c.alpha
    end
    "[0,#{@__vid},#{@rect.x},#{@rect.y},#{@rect.width},#{@rect.height},#{@z},#{@ox.to_i},#{@oy.to_i},#{@visible ? 1 : 0},#{c.__css},#{@tone.__css},#{@__seq}]"
  end
end

module RGWeb
  module ViewportChild
    def __vpid
      v = @viewport
      v && !v.disposed? ? v.__vid : 0
    end
  end
end

# ---------------------------------------------------------------------------
class Sprite
  include RGWeb::ViewportChild
  attr_reader :viewport, :bitmap, :src_rect, :color, :tone, :z
  attr_accessor :visible, :x, :y, :ox, :oy, :zoom_x, :zoom_y, :angle, :mirror, :bush_depth, :blend_type
  attr_reader :opacity
  def initialize(viewport = nil)
    @viewport = viewport
    @bitmap = nil
    @src_rect = Rect.new(0, 0, 0, 0)
    @visible = true
    @x = @y = @z = @ox = @oy = 0
    @zoom_x = @zoom_y = 1.0
    @angle = 0
    @mirror = false
    @bush_depth = 0
    @opacity = 255
    @blend_type = 0
    @color = Color.new(0, 0, 0, 0)
    @tone = Tone.new(0, 0, 0, 0)
    @flash_color = nil; @flash_count = 0; @flash_dur = 0
    @disposed = false
    @__seq = RGWeb.next_seq
    RGWeb.register(self)
  end
  def bitmap=(b)
    @bitmap = b
    @src_rect.set(0, 0, b.width, b.height) if b && !b.disposed?
  end
  def src_rect=(r); @src_rect = r; end
  def color=(c); @color = c; end
  def tone=(t); @tone = t; end
  def z=(v); @z = v.to_i; end
  def opacity=(v)
    v = v.to_i
    @opacity = v < 0 ? 0 : (v > 255 ? 255 : v)
  end
  def viewport=(v); @viewport = v; end
  def width
    @src_rect.width
  end
  def height
    @src_rect.height
  end
  def dispose
    return if @disposed
    @disposed = true
    RGWeb.unregister(self)
  end
  def disposed?
    @disposed
  end
  def flash(color, duration)
    @flash_color = color; @flash_dur = duration; @flash_count = duration
  end
  def update
    @flash_count -= 1 if @flash_count > 0
  end
  def __record
    return nil unless @visible
    b = @bitmap
    return nil if b.nil? || b.disposed?
    return nil if @opacity <= 0
    c = @color
    if @flash_count > 0
      return nil if @flash_color.nil?
      a = @flash_color.alpha * @flash_count / @flash_dur
      c = @flash_color.dup.tap { |cc| cc.alpha = a } if a > c.alpha
    end
    sr = @src_rect
    "[1,#{__vpid},#{b.__id},#{@x.to_i},#{@y.to_i},#{@z},#{@ox.to_i},#{@oy.to_i},#{sr.x},#{sr.y},#{sr.width},#{sr.height},#{@zoom_x.to_f},#{@zoom_y.to_f},#{@angle.to_f},#{@mirror ? 1 : 0},#{@opacity},#{@blend_type.to_i},#{@bush_depth.to_i},#{c.__css},#{@tone.__css},#{@__seq}]"
  end
end

# ---------------------------------------------------------------------------
class Plane
  include RGWeb::ViewportChild
  attr_reader :viewport, :bitmap, :color, :tone, :z, :opacity
  attr_accessor :visible, :ox, :oy, :zoom_x, :zoom_y, :blend_type
  def initialize(viewport = nil)
    @viewport = viewport
    @bitmap = nil
    @visible = true
    @z = @ox = @oy = 0
    @zoom_x = @zoom_y = 1.0
    @opacity = 255
    @blend_type = 0
    @color = Color.new(0, 0, 0, 0)
    @tone = Tone.new(0, 0, 0, 0)
    @disposed = false
    @__seq = RGWeb.next_seq
    RGWeb.register(self)
  end
  def bitmap=(b); @bitmap = b; end
  def color=(c); @color = c; end
  def tone=(t); @tone = t; end
  def z=(v); @z = v.to_i; end
  def opacity=(v)
    v = v.to_i
    @opacity = v < 0 ? 0 : (v > 255 ? 255 : v)
  end
  def dispose
    return if @disposed
    @disposed = true
    RGWeb.unregister(self)
  end
  def disposed?
    @disposed
  end
  def __record
    return nil unless @visible
    b = @bitmap
    return nil if b.nil? || b.disposed? || @opacity <= 0
    "[2,#{__vpid},#{b.__id},#{@z},#{@ox.to_i},#{@oy.to_i},#{@zoom_x.to_f},#{@zoom_y.to_f},#{@opacity},#{@blend_type.to_i},#{@color.__css},#{@tone.__css},#{@__seq}]"
  end
end

# ---------------------------------------------------------------------------
class Window
  include RGWeb::ViewportChild
  attr_reader :viewport, :windowskin, :contents, :cursor_rect, :z
  attr_reader :x, :y, :width, :height, :opacity, :back_opacity, :contents_opacity
  attr_accessor :stretch, :active, :visible, :pause, :ox, :oy
  def initialize(viewport = nil)
    @viewport = viewport
    @windowskin = nil
    @contents = nil
    @stretch = true
    @cursor_rect = Rect.new(0, 0, 0, 0)
    @active = true
    @visible = true
    @pause = false
    @x = @y = @width = @height = @z = @ox = @oy = 0
    @opacity = 255; @back_opacity = 255; @contents_opacity = 255
    @cursor_count = 0
    @pause_count = 0
    @disposed = false
    @__seq = RGWeb.next_seq
    RGWeb.register(self)
  end
  def windowskin=(b); @windowskin = b; end
  def contents=(b); @contents = b; end
  def cursor_rect=(r); @cursor_rect = r; end
  def x=(v); @x = v.to_i; end
  def y=(v); @y = v.to_i; end
  def width=(v); @width = v.to_i; end
  def height=(v); @height = v.to_i; end
  def z=(v); @z = v.to_i; end
  def opacity=(v); @opacity = [[v.to_i, 0].max, 255].min; end
  def back_opacity=(v); @back_opacity = [[v.to_i, 0].max, 255].min; end
  def contents_opacity=(v); @contents_opacity = [[v.to_i, 0].max, 255].min; end
  def pause=(v)
    @pause_count = 0 if v && !@pause
    @pause = v
  end
  def dispose
    return if @disposed
    @disposed = true
    @contents.dispose if false
    RGWeb.unregister(self)
  end
  def disposed?
    @disposed
  end
  def update
    @cursor_count = (@cursor_count + 1) % 32 if @active
    @pause_count += 1 if @pause
  end
  def __record
    return nil unless @visible
    return nil if @width <= 0 || @height <= 0
    sk = @windowskin && !@windowskin.disposed? ? @windowskin.__id : 0
    ct = @contents && !@contents.disposed? ? @contents.__id : 0
    cr = @cursor_rect
    ca = -1
    if cr.width > 0 && cr.height > 0
      if @active
        i = @cursor_count
        ca = i < 16 ? 255 - i * 8 : 127 + (i - 16) * 8
      else
        ca = 255
      end
    end
    pf = -1; pa = 0
    if @pause
      pf = (@pause_count / 8) % 4
      pa = [@pause_count * 32, 255].min
    end
    arrows = 0
    if ct != 0
      cw = @contents.width; chh = @contents.height
      arrows |= 1 if @ox > 0
      arrows |= 2 if cw - @ox > @width - 32
      arrows |= 4 if @oy > 0
      arrows |= 8 if chh - @oy > @height - 32
    end
    "[3,#{__vpid},#{sk},#{ct},#{@x},#{@y},#{@z},#{@width},#{@height},#{@ox.to_i},#{@oy.to_i},#{@opacity},#{@back_opacity},#{@contents_opacity},#{cr.x},#{cr.y},#{cr.width},#{cr.height},#{ca},#{pf},#{pa},#{@stretch ? 1 : 0},#{@active ? 1 : 0},#{arrows},#{@__seq}]"
  end
end

# ---------------------------------------------------------------------------
class Tilemap
  include RGWeb::ViewportChild
  class AutotileArray
    def initialize(tm)
      @tm = tm
      @a = Array.new(7)
    end
    def [](i)
      @a[i]
    end
    def []=(i, b)
      @a[i] = b
      @tm.__dirty!
    end
    def __ids
      @a.map { |b| b && !b.disposed? ? b.__id : 0 }.join(',')
    end
  end
  @@ids = 0
  attr_reader :viewport, :tileset, :autotiles, :map_data, :flash_data, :priorities
  attr_accessor :visible, :ox, :oy
  def initialize(viewport = nil)
    @viewport = viewport
    @@ids += 1
    @__tid = @@ids
    @autotiles = AutotileArray.new(self)
    @tileset = nil; @map_data = nil; @flash_data = nil; @priorities = nil
    @visible = true
    @ox = @oy = 0
    @ani = 0
    @dirty = true
    @sent_ver = nil
    @disposed = false
    @__seq = RGWeb.next_seq
    RGWeb.register(self)
  end
  def __dirty!
    @dirty = true
  end
  def tileset=(b); @tileset = b; @dirty = true; end
  def map_data=(t); @map_data = t; @dirty = true; end
  def priorities=(t); @priorities = t; @dirty = true; end
  def flash_data=(t); @flash_data = t; end
  def dispose
    return if @disposed
    @disposed = true
    RGWeb.unregister(self)
    RGWeb.call(:tmDispose, @__tid)
  end
  def disposed?
    @disposed
  end
  def update
    @ani += 1
  end
  def __record
    return nil unless @visible
    return nil if @map_data.nil?
    ver = [@map_data.__version, @priorities ? @priorities.__version : 0]
    if @dirty || ver != @sent_ver
      md = @map_data
      RGWeb.call(:tmConfig, @__tid, @tileset && !@tileset.disposed? ? @tileset.__id : 0, @autotiles.__ids,
                 md.xsize, md.ysize, md.zsize, md.__data.join(','), @priorities ? @priorities.__data.join(',') : '')
      @dirty = false
      @sent_ver = ver
    end
    "[4,#{__vpid},#{@__tid},#{@ox.to_i},#{@oy.to_i},#{(@ani / 16) % 4},1,#{@__seq}]"
  end
end

# ---------------------------------------------------------------------------
module Graphics
  @frame_rate = 40
  @frame_count = 0
  class << self
    attr_accessor :frame_count
    attr_reader :frame_rate
    def frame_rate=(v)
      @frame_rate = [[v.to_i, 10].max, 120].min
    end
    def update
      RGWeb.flush_dispose
      RGWeb.diagnostic_tick
      r = RGWeb.await_js(:frame, RGWeb.display_list, @frame_rate)
      @frame_count += 1
      RGWeb.after_frame(r)
      nil
    end
    def freeze
      RGWeb.call(:freeze)
      nil
    end
    def transition(duration = 8, _filename = '', _vague = 40)
      duration = duration.to_i
      RGWeb.call(:transitionBegin, duration)
      if duration > 0
        duration.times do
          RGWeb.flush_dispose
          RGWeb.diagnostic_tick
          r = RGWeb.await_js(:frame, RGWeb.display_list, @frame_rate)
          @frame_count += 1
          RGWeb.after_frame(r)
        end
      end
      RGWeb.call(:transitionEnd)
      nil
    end
    def frame_reset
      nil
    end
    def width
      640
    end
    def height
      480
    end
    def snap_to_bitmap
      b = Bitmap.allocate
      b.instance_variable_set(:@__id, RGWeb.call(:snapToBitmap).to_i)
      b.__setup
      b
    end
  end
end

module RGWeb
  def self.after_frame(r)
    return if r.to_i == 0
    # reset requested from web UI
    raise Reset if defined?(Reset) && Reset.is_a?(Class)
  end
end

# ---------------------------------------------------------------------------
module Input
  DOWN = 2; LEFT = 4; RIGHT = 6; UP = 8
  A = 11; B = 12; C = 13; X = 14; Y = 15; Z = 16; L = 17; R = 18
  SHIFT = 21; CTRL = 22; ALT = 23
  F5 = 25; F6 = 26; F7 = 27; F8 = 28; F9 = 29
  @cnt = Array.new(32, 0)
  @dir4 = 0
  class << self
    def update
      s = RGWeb.call(:keys).to_s
      held = s.empty? ? [] : s.split(',').map(&:to_i)
      32.times do |k|
        @cnt[k] = held.include?(k) ? @cnt[k] + 1 : 0
      end
      @dir4 = held.empty? ? 0 : RGWeb.call(:dir4).to_i
      nil
    end
    def press?(k)
      k = k.to_i
      k >= 0 && k < 32 && @cnt[k] > 0
    end
    def trigger?(k)
      k = k.to_i
      k >= 0 && k < 32 && @cnt[k] == 1
    end
    def repeat?(k)
      k = k.to_i
      return false unless k >= 0 && k < 32
      c = @cnt[k]
      c == 1 || (c > 15 && (c - 16) % 4 == 0)
    end
    def dir4
      return @dir4 if @dir4 != 0 && @cnt[@dir4] > 0
      [2, 4, 6, 8].each { |d| return d if @cnt[d] > 0 }
      0
    end
    def dir8
      d = @cnt
      up = d[8] > 0; down = d[2] > 0; left = d[4] > 0; right = d[6] > 0
      if up && left then 7
      elsif up && right then 9
      elsif down && left then 1
      elsif down && right then 3
      else dir4
      end
    end
  end
end

# ---------------------------------------------------------------------------
module Audio
  class << self
    def __n(name)
      RGWeb.utf8(name.to_s)
    end
    def bgm_play(name, volume = 100, pitch = 100)
      RGWeb.call(:bgmPlay, __n(name), volume.to_i, pitch.to_i)
    end
    def bgm_stop; RGWeb.call(:bgmStop); end
    def bgm_fade(ms); RGWeb.call(:bgmFade, ms.to_i); end
    def bgs_play(name, volume = 80, pitch = 100)
      RGWeb.call(:bgsPlay, __n(name), volume.to_i, pitch.to_i)
    end
    def bgs_stop; RGWeb.call(:bgsStop); end
    def bgs_fade(ms); RGWeb.call(:bgsFade, ms.to_i); end
    def me_play(name, volume = 100, pitch = 100)
      RGWeb.call(:mePlay, __n(name), volume.to_i, pitch.to_i)
    end
    def me_stop; RGWeb.call(:meStop); end
    def me_fade(ms); RGWeb.call(:meFade, ms.to_i); end
    def se_play(name, volume = 80, pitch = 100)
      RGWeb.call(:sePlay, __n(name), volume.to_i, pitch.to_i)
    end
    def se_stop; RGWeb.call(:seStop); end
  end
end
