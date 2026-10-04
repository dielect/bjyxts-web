class Sprite_Status < Sprite
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     viewport : 显示端口
  #     picture  : 图片 (Game_Picture)
  #--------------------------------------------------------------------------
  def initialize(viewport, picture)
    super(viewport)
    @picture = picture
    update
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    if self.bitmap != nil
      self.bitmap.dispose
    end
    super
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
    # 文件名不为空的情况下
    if @picture != ""
      # 获取图片图形
      self.bitmap = RPG::Cache.picture(@picture)
    end
    # 文件名是空的情况下
    if @picture_name == ""
      # 将活动块设置为不可见
      self.visible = false
      return
    end
    # 将活动块设置为可见
    self.visible = true
    # 设置传送原点
    #self.ox = self.bitmap.width / 2
    #self.oy = self.bitmap.height / 2
  end
end
