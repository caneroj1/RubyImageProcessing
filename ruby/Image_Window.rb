require 'gosu'

## Image Window class. This class uses the gosu graphics library to display the images associated with RIP

class ImageWindow < Gosu::Window
  attr_reader :width, :height
  
  ## initializes the display window
  # accepts a parameter that is a RIP image
  # extracts dimension data from the image as well as path information
  # that information is used to create a gosu window with the image as its background
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
  
  ## this function monitors keyboard and mouse input
  # if the escape or enter key is pressed, the window closes
  # if a user clicks inside the image, the location of that pixel is stored in the points array
  # when the user exits and there are points in the array, the coordinate data is written to the data_points file to be used by Image.rb
  def key_pressed
    if button_down? Gosu::KbEscape or button_down? Gosu::KbReturn then
      if !@points.empty? 
        points = File.open("../data/data_points.txt", "w") do |f|
          @points.each { |i| f.write("#{i[0]},#{i[1]}\n") }
        end
      end
      close
    end
    if button_down? Gosu::MsLeft
      @points.push([mouse_x, mouse_y])
      sleep(0.2)
    end
  end
  
  def needs_cursor?
    true
  end
  
end