require 'gosu'

class ImageWindow < Gosu::Window
  attr_reader :width, :height
  
  def initialize(picture)
    @width = picture.width
    @height = picture.height
    @points = Array.new
    
    super(@width, @height, false)
    
    self.caption = picture.pictureName
    @background_image = Gosu::Image.new(self, File.join(picture.picturePath, picture.pictureName), true)
  end
  
  def update
    key_pressed
  end
  
  def draw
    @background_image.draw(0,0,0)
  end
  
  def key_pressed
    if button_down? Gosu::KbEscape or button_down? Gosu::KbReturn then
      if !@points.empty? then
        points = File.open("../data/data_points.txt", "w") do |f|
          @points.each do |i|
            f.write("#{i[0]},#{i[1]}\n")
          end
        end
      end
      close
    end
    if button_down? Gosu::MsLeft then
      @points.push([mouse_x, mouse_y])
      sleep(0.2)
    end
  end
  
  def needs_cursor?
    true
  end
  
end