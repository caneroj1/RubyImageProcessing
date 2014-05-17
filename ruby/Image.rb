require 'chunky_png'
require 'haml'

require_relative 'Image_Window.rb'

## This file contains all of the functions associated with a RIP Image 
# The objects made from this class are the basic units of work for RIP
# there are various functions associated with this class and they fall into two categories
# image processing functions: includes things like grayscale, sobel filter, etc. these are the real meat of this class
# utility functions: things like savePicture, displayPicture, constrain to colors, etc. they make the job of each image processing 
# function easier

class Image 
  
  protected
  attr_writer :pictureName, :picturePath, :width, :height
  attr_accessor :picture

  public
  attr_reader :width, :height, :picturePath, :pictureName
  
  ## initialize function
  # this function creates an organizes the data associated with an image. it parses the path provided and puts the appropriate parts in
  # the corresponding instance variables. it also extracts data from the image in the form of dimension attributes and pixel information.
  # the pixel information is used to populate an instance variable array of colors. this is a 3 dimensional array. it is indexed by
  # [col][row] and contains an array of [r,g,b] values. this matrix makes applying filters significantly faster as it eliminates the need
  # to query the image each time pixel information is needed
  def initialize(path)
    @picturePath = File.split(path)[0]
    @pictureName = File.split(path)[1]
    
    @picture = ChunkyPNG::Image.from_file(path)
    @width, @height = @picture.dimension.width, @picture.dimension.height
      
    pixelArr = @picture.pixels
    @colors = Array.new(@width) { Array.new(@height) }
      
    rowI = colI = 0
    pixelArr.each do |pixel|
      @colors[colI][rowI] = [ChunkyPNG::Color.r(pixel), ChunkyPNG::Color.g(pixel), ChunkyPNG::Color.b(pixel)]
      colI += 1
      if colI % width == 0 
        colI = 0
        rowI += 1
      end
    end
  end
  
  ## duplicate
  def dup
    Image.new(File.join(@picturePath, @pictureName))
  end
  
  ## access pixels
  def[](a, b)
    @picture[a, b]
  end
  
  ## set pixels
  def[]=(a, b, value)
    @picture[a, b] = value
  end
  
  ## display picture
  # uses the Image_Window class to display the image
  def display(params = {})
    if params[:pathForImage].nil?
      disp = ImageWindow.new(self)
      disp.show
    else
      pict = Image.new(params[:pathForImage])
      disp = ImageWindow.new(pict)
      disp.show
    end
  end
  
  ## save picture
  # this function accepts a name parameter and an optional path
  # saves the image in the default path if none is provided (default is the directory of the currently loaded picture)
  # otherwise saves the image in the provided path
  # both variants make use of the passed-in name parameter
  def save(params = {})
    params[:name] ||= @pictureName
    params[:save] ||= @picturePath
    @picture.save(File.join(params[:save], params[:name]))
  end
  
  ## save and display
  # obviously combines the two steps
  def save_and_display(params = {})
    save(name: params[:name], save: params[:save])
    
    path =
    if params[:save].nil? && params[:name].nil?
      nil
    elsif params[:save].nil? && !params[:name].nil?
      File.join(@picturePath, params[:name])
    elsif !params[:save].nil? && params[:name].nil?
      File.join(params[:save], @pictureName)
    elsif !params[:save].nil? && !params[:name].nil?
      File.join(params[:save], params[:name])
    end
    
    display(pathForImage: path)
  end
  
  ## convert to grayscale
  # this function converts the current image into its grayscale representation
  # name and path are optional. if no name, it defaults to substituting in Grayed.png in place of the current .png
  # if there is no path, it defaults to the directory the current picture is located
  def grayscale(params = {})
    params[:name] ||= @pictureName.gsub('.png', 'Grayed.png')
    params[:save] ||= @picturePath

    grImg = dup
    grImg.picture = grImg.picture.grayscale
    grImg.pictureName, grImg.picturePath = params[:name], params[:save]
    grImg
  end
  
  ## apply sobel filter
  # this function has three optional parameters.
  # name: if omitted, defaults to substituting in SobelFilter.png in place of the current .png
  # pathForImage: if omitted, it defaults to the current image
  # pathForSave: if omitted, saves in the current directory
  # the sobel filter algorithm utilizes two matrices. the first matrix applies the filter along the X-axis and looks for
  # horizontal and diagonal lines
  # the second matrix looks along the Y-axis for vertical lines.
  # the results of each matrix are then put into the distance equation which then becomes that pixel's color
  def sobel_filter(params = {})
    params[:name] ||= @pictureName.gsub('.png', 'SobelFilter.png')
    params[:save] ||= @picturePath
    
    sobelFilterX = [
      [1, 2, 1], 
      [0, 0, 0], 
      [-1, -2, -1]
    ]
    sobelFilterY = [
      [-1, 0, 1], 
      [-2, 0, 2], 
      [-1, 0, 1]
    ]
    
    height, width = @height-2, @width-2
    sobelPic = dup

    (1..height).each do |j|
      (1..width).each do |i|
        pixel1 = calculate_pixel_value_with_filter3(sobelFilterX, @picture, i, j, true)
        pixel2 = calculate_pixel_value_with_filter3(sobelFilterY, @picture, i, j, true)
        res = Math.sqrt(pixel1[0] * pixel1[0] + pixel2[0] * pixel2[0])
        sobelPic[i, j] = ChunkyPNG::Color.rgb(res.to_i, res.to_i, res.to_i)
      end
    end
    
    sobelPic.picturePath, sobelPic.pictureName = params[:save], params[:name]
    sobelPic
  end
  
  ## apply blur filter
  # this function has three optional parameters.
  # name: if omitted, defaults to substituting in Blurred.png in place of the current .png
  # pathForImage: if omitted, it defaults to the current image
  # pathForSave: if omitted, saves in the current directory
  # this function applies a blur filter to the current image. the matrix is not as strong as the Gaussian Blur filter, but it is 
  # significantly faster. if one does not want an image as blurred as with the gaussian algorithm, this might be desirable.
  def blur(params = {})
    params[:name] ||= @pictureName.gsub('.png', 'Blurred.png')
    params[:save] ||= @picturePath
    
    blurFilter = [
      [1/16.0, 2/16.0, 1/16.0], 
      [2/16.0, 4/16.0, 2/16.0], 
      [1/16.0, 2/16.0, 1/16.0]
    ]
    
    height, width = @height-2, @width-2
    blur = dup
    
    (1..height).each do |j|
      (1..width).each do |i|
        pixel = calculate_pixel_value_with_filter3(blurFilter, @picture, i, j, false)
        blur[i, j] = ChunkyPNG::Color.rgb(pixel[0].to_i, pixel[1].to_i, pixel[2].to_i)
      end
    end
    
    blur.pictureName, blur.picturePath = params[:name], params[:save]
    blur
  end
  
  ## apply gaussian blur filter
  # this function has three optional parameters.
  # name: if omitted, defaults to substituting in Gauss.png in place of the current .png
  # pathForImage: if omitted, it defaults to the current image
  # pathForSave: if omitted, saves in the current directory
  # this function makes use of a 5x5 matrix of values obtained from the Gaussian distribution in order to blur the image.
  # since this is a 5x5 matrix, it is computationally more intense.
  def gaussian_blur(params = {})
    params[:name] ||= @pictureName.gsub('.png', 'Gauss.png')
    params[:save] ||= @picturePath
    
    blurFilter = 
    [
      [0.01248, 0.02642, 0.03392, 0.02642, 0.01248], 
      [0.02642, 0.05592, 0.07180, 0.05592, 0.02642], 
      [0.03392, 0.07180, 0.09220, 0.07180, 0.03392], 
      [0.02642, 0.05592, 0.07180, 0.05592, 0.02642], 
      [0.01248, 0.02642, 0.03392, 0.02642, 0.01248]
    ]

    height, width = @height-3, @width-3
    blur = dup
    
    (2..height).each do |j|
      (2..width).each do |i|
        pixel = calculate_pixel_value_with_filter5(blurFilter, @picture, i, j, false)
        blur[i, j] = ChunkyPNG::Color.rgb(pixel[0].to_i, pixel[1].to_i, pixel[2].to_i)
      end
    end

    blur.pictureName, blur.picturePath = params[:name], params[:save]
    blur
  end

  ## apply 1984 filter
  # this function has three optional parameters.
  # name: if omitted, defaults to substituting in 1984.png in place of the current .png
  # pathForImage: if omitted, it defaults to the current image
  # pathForSave: if omitted, saves in the current directory
  # this function makes use of an interesting matrix of trig functions in order to apply a unique filter to the image
  def surveillance_camera(h = {})
    params[:name] ||= @pictureName.gsub('.png', '1984.png')
    params[:save] ||= @picturePath

    pi = Math::PI
    height, width = @height-3, @width-3
    
    camera = dup
    
    (2..height).each do |j|
      (2..width).each do |i|
        pixel = calculate_pixel_value_with_filter3([
          [-1*Math.cos(i*pi), -1*Math.cos(i*pi), -1*Math.cos(i*pi)], 
          [-1*Math.sin(j*pi), -1*Math.sin(j*pi), -1*Math.sin(j*pi)], 
          [-1*Math.tan((i/j)*pi), -1*Math.tan((i/j)*pi), -1*Math.tan((i/j)*pi)]
          ], @picture, i, j, false)
        camera[i, j] = ChunkyPNG::Color.rgb(pixel[0].to_i, pixel[1].to_i, pixel[2].to_i)
      end
    end
    
    camera.pictureName, sharpen.picturePath = params[:name], params[:save]
    camera
  end
  
  ## apply sharpen filter
  # this function has three optional parameters.
  # name: if omitted, defaults to substituting in Sharpened.png in place of the current .png
  # pathForImage: if omitted, it defaults to the current image
  # pathForSave: if omitted, saves in the current directory
  # this function sharpens an image in order to highlight differences between edges
  def sharpen(h = {})
    params[:name] ||= @pictureName.gsub('.png', 'Sharpened.png')
    params[:save] ||= @picturePath
    
    sharpenFilter = [
      [-1, -1, -1], 
      [-1, 9, -1], 
      [-1, -1, -1]
    ]
    
    height, width = @height-2, @width-2
    sharpen = dup
    
    (1..height).each do |j|
      (1..width).each do |i|
        pixel = calculate_pixel_value_with_filter3(sharpenFilter, @picture, i, j, false)
        sharpen[i, j] = ChunkyPNG::Color.rgb(pixel[0], pixel[1], pixel[2])
      end
    end
    
    sharpen.pictureName, sharpen.picturePath = params[:name], params[:save]
    sharpen
  end
  
  ## draw bezier curve
  # this function has three optional parameters.
  # name: if omitted, defaults to substituting in Bezier.png in place of the current .png
  # pathForImage: if omitted, it defaults to the current image
  # pathForSave: if omitted, saves in the current directory
  # this function brings up a display of the currently loaded image
  # the user is allowed to click on points in the image which are then used as the control points for the bezier curve
  def bezier_curve(params = {})
    params[:name] ||= @pictureName.gsub('.png', 'Bezier.png')
    params[:save] ||= @picturePath
    
    display_picture
    
    points = parse_points
    
    if points.nil? 
      puts "Unable to draw: no control points generated."
      return false
    else
      bez = dup
      bez.picture = bez.picture.bezier_curve(points)
      bez.pictureName, bez.picturePath = params[:name], params[:save]
      return bez
    end
  end
  
  ## invert colors
  # this function has three optional parameters.
  # name: if omitted, defaults to substituting in Bezier.png in place of the current .png
  # pathForImage: if omitted, it defaults to the current image
  # pathForSave: if omitted, saves in the current directory
  # this function inverts the colors of the image
  def invert(params = {})
    params[:name] ||= @pictureName.gsub('.png', 'Inverted.png')
    params[:save] ||= @picturePath
    
    inv = dup
    
    (0...inv.width).each do |i|
      (0...inv.height).each do |j|
        red = 255 - ChunkyPNG::Color.r(inv[i,j])
        blue = 255 - ChunkyPNG::Color.g(inv[i,j])
        green = 255 - ChunkyPNG::Color.b(inv[i,j])
        inv[i,j] = ChunkyPNG::Color.rgb(red, blue, green)
      end
    end
    
    inv.pictureName, inv.picturePath = params[:name], params[:save]
    inv
  end
  
  ## emboss
  # this function has three optional parameters.
  # name: if omitted, defaults to substituting in Bezier.png in place of the current .png
  # pathForImage: if omitted, it defaults to the current image
  # pathForSave: if omitted, saves in the current directory
  # this function averages the colors of each pixel in order to convert it grayscale and emboss
  def emboss(params = {})
    params[:name] ||= @pictureName.gsub('.png', 'Embossed.png')
    params[:save] ||= @picturePath
    
    # default to true
    rgb = 
      if params[:rbg].nil?
        true
      end
      
    embossFilter = [
      [-1, -1, 1], 
      [-1, -1, 1], 
      [1, 1, 1]
    ]

    height, width = @height-2, @width-2
    emboss = dup

    (1..height).each do |j|
      (1..width).each do |i|
        pixel = calculate_pixel_value_with_filter3(embossFilter, @picture, i, j, false)
        if rgb then 
          emboss[i, j] = ChunkyPNG::Color.rgb(pixel[0], pixel[1], pixel[2])
        else
          val = (pixel[0] + pixel[1] + pixel[2])/3 
          emboss[i, j] = ChunkyPNG::Color.rgb(val, val, val)
        end
      end
    end
    
    emboss.pictureName, emboss.picturePath = params[:name], params[:save]
    emboss
  end
  
  ## histogram function
  # this calculates the image histogram of the brightness of the image
  # each pixel's brightness is defined as sqrt(.241 R^2 + .691 G^2 + .068 B^2)
  # since the max value for each color is 255, the max possible value the above function could return is 323.8, which will round to 324
  # i think 26 bins is appropriate for this histogram, so each value will be binned appropriately into a hash
  def histogram(params = {})
    params[:name] ||= File.join(@pictureName.gsub(".png", "Histogram.html"))
    bins = Hash.new(0)
    
    (0...@picture.height).each do |j|
      (0...@picture.width).each do |i|
        r = ChunkyPNG::Color.r(@picture[i,j])
        g = ChunkyPNG::Color.g(@picture[i,j])
        b = ChunkyPNG::Color.b(@picture[i,j])
        
        op = 0.241 * r**2 + 0.691 * g**2 + 0.68 * b**2
        val = Math.sqrt(op).round
        val /= 13
        
        bins[val] += 1
      end
    end
    
    bins = Hash[ bins.map { |k,v| [k * 13, v] }.sort ]
    graph(bins, params[:name])
  end
  
  ## mirror function
  # this function will take the image and create a new canvas that is twice as wide and will mirror the image. this will result in
  # both the original image and the mirrored version being present on the canvas. i.e., it is not just a flip operation
  def mirror(params = {})
    params[:name] ||= @pictureName.gsub('.png', 'Mirrored.png')
    params[:save] ||= @picturePath
    
    mir = dup
    
    mirror_width = @width * 2
    mir.picture = ChunkyPNG::Image.new(mirror_width, @height)
    mir.height = @height
    mir.width = mirror_width
    
    mirror_width -= 1
    
    (0...@width).each do |i|
      (0...@height).each do |j|
        mir[i, j]                = @picture[i, j]
        mir[mirror_width - i, j] = @picture[i, j]
      end
    end
    
    mir.pictureName, mir.picturePath = params[:name], params[:save]
    mir 
  end 
  
  ## flip vertically (in place)
  # this function will flip the image vertically. it does this in place and will alter the original image
  def flip_vertically!
    @picture.flip_vertically!
  end
  
  ## flip vertically
  # this will flip the image in terms of the in place function, but will return a copy of the flipped image instead of changing the original
  def flip_vertically(params = {})
    params[:name] ||= @pictureName.gsub('.png', 'FlippedV.png')
    params[:save] ||= @picturePath
    
    flip_v = dup
    flip_v.flip_vertically!
    
    flip_v.pictureName, picturePath = params[:name], params[:save]
    flip_v
  end
  
  ## flip horizontally (in place)
  # this function will flip the image horizontally. it does this in place and will alter the original image
  def flip_horizontally!
    @picture.flip_horizontally!
  end
  
  ## flip horizontally
  # this will flip the image in terms of the in place function, but will return a copy of the flipped image instead of changing the original
  def flip_horizontally(params = {})
    params[:name] ||= @pictureName.gsub('.png', 'FlippedH.png')
    params[:save] ||= @picturePath
    
    flip_h = dup
    flip_h.flip_horizontally!
    
    flip_h.pictureName, picturePath = params[:name], params[:save]
    flip_h
  end
  
  ## rotate left (in place)
  def rotate_left!
    @picture.rotate_left!
  end
  
  ## rotate left
  def rotate_left(params = {})
    params[:name] ||= @pictureName.gsub('.png', 'RotateL.png')
    params[:save] ||= @picturePath
    
    rot_l = dup
    rot_l.rotate_left!
    
    rot_l.width, rot_l.height = rot_l.height, rot_l.width
    
    rot_l.pictureName, picturePath = params[:name], params[:save]
    rot_l
  end
  
  ## rotate right (in place)
  def rotate_right!
    @picture.rotate_right!
  end
  
  ## rotate right
  def rotate_right(params = {})
    params[:name] ||= @pictureName.gsub('.png', 'RotateR.png')
    params[:save] ||= @picturePath
    
    rot_r = dup
    rot_r.rotate_right!
    
    rot_r.width, rot_r.height = rot_r.height, rot_r.width
    
    rot_r.pictureName, picturePath = params[:name], params[:save]
    rot_r
  end
  
  ## CPVF3
  # this function is not a typical matrix multiplication operation
  # it applies the mathematical convolution operation to the image
  # it accepts a parameter of the filter of to be applied, the current image, the current coordinates and a grayscale indicator
  # the grayscale indicator is a bool indicating whether to just calculate a single color value
  # i'm pretty sure we can take out the img parameter
  def calculate_pixel_value_with_filter3(filter, img, currX, currY, grayscale)
    value = [0, 0, 0]
    for i in 0..2
      for j in 0..2
        if grayscale then
          value[0] += filter[i][j] * @colors[(currX-1)+j][(currY-1)+i][0]
        else
          value[0] += filter[i][j] * @colors[(currX-1)+j][(currY-1)+i][0]
          value[1] += filter[i][j] * @colors[(currX-1)+j][(currY-1)+i][1]
          value[2] += filter[i][j] * @colors[(currX-1)+j][(currY-1)+i][2]
        end
      end
    end
    return constrain_to_colors(value)
  end
  
  ## CPVF5
  # this function is not a typical matrix multiplication operation
  # it applies the mathematical convolution operation to the image
  # it accepts a parameter of the filter of to be applied, the current image, the current coordinates and a grayscale indicator
  # the grayscale indicator is a bool indicating whether to just calculate a single color value
  # i'm pretty sure we can take out the img parameter
  def calculate_pixel_value_with_filter5(filter, img, currX, currY, grayscale)
    value = [0, 0, 0]
    for i in 0..4
      for j in 0..4
        if grayscale then
          value[0] += filter[i][j] * @colors[(currX-2)+j][(currY-2)+i][0]
        else
          value[0] += filter[i][j] * @colors[(currX-2)+j][(currY-2)+i][0]
          value[1] += filter[i][j] * @colors[(currX-2)+j][(currY-2)+i][1]
          value[2] += filter[i][j] * @colors[(currX-2)+j][(currY-2)+i][2]
        end
      end
    end
    return constrain_to_colors(value)
  end
  
  ## PRIVATE UTILITY FUNCTIONS
  private
  
  ## constrain function
  # this function accepts an array of [r,g,b] values and constrains them to allowable pixel values
  # if the value is over 255, it is set to 255
  # if the value is less than 0, it is set to 0
  # else, it is unchanged
  def constrain_to_colors(array)
    array[0] > 255 ? array[0] = 255 : array[0] < 0 ? array[0] = 0 : array[0]
    array[1] > 255 ? array[1] = 255 : array[1] < 0 ? array[1] = 0 : array[1]
    array[2] > 255 ? array[2] = 255 : array[2] < 0 ? array[2] = 0 : array[2]
    return array
  end
  
  ## point parser
  # this function reads control point information from the data file
  # it uses the x- and y-coordinates of each control point to instantiate a Point object
  # the point object is pushed to an array called points that is the return value of this function under correct conditions
  def parse_points
    points = Array.new
    begin
      file = File.open("../data/data_points.txt", "r") do |f|
        f.each do |line|
          arr = line.split(",")
          points.push(ChunkyPNG::Point.new(arr[0], arr[1]))
        end
        f.close
        File.delete(f)
      end
    rescue 
      return nil
    end
    return points
  end
  
  ## create histogram
  # this will accept a hash and will embed the data in a brief javascript/html file in order
  # to display the histogram
  def graph(hash, name)
    Haml::Engine.new(File.read("../templates/hist.haml")).def_method(hash, :render, :title)
    begin
      hist = File.open("#{name}", 'w')
      hist.write(hash.render(:title => name))
    rescue IOError => e
      puts e
    end
  end
  
end
