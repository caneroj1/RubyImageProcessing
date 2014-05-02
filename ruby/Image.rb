require 'chunky_png'
require_relative 'ImageWindow.rb'

## This file contains all of the functions associated with a RIP Image 
# The objects made from this class are the basic units of work for RIP
# there are various functions associated with this class and they fall into two categories
# image processing functions: includes things like grayscale, sobel filter, etc. these are the real meat of this class
# utility functions: things like savePicture, displayPicture, constrain to colors, etc. they make the job of each image processing 
# function easier

class Image 
  
  ## declares each of the following symbols as an instance variable and provides Image with accessor functions for each 
  attr_reader :width, :height, :picturePath, :pictureName
  
  ## initialize function
  # currently has an optional path argument but this should be changed in the future
  # this function creates an organizes the data associated with an image. it parses the path provided and puts the appropriate parts in
  # the corresponding instance variables. it also extracts data from the image in the form of dimension attributes and pixel information.
  # the pixel information is used to populate an instance variable array of colors. this is a 3 dimensional array. it is indexed by
  # [col][row] and contains an array of [r,g,b] values. this matrix makes applying filters significantly faster as it eliminates the need
  # to query the image each time pixel information is needed
  
  def initialize(path = nil)
    if !path.nil? then
      @picturePath = File.split(path)[0]
      @pictureName = File.split(path)[1]
    
      @picture = ChunkyPNG::Image.from_file(path)
      @width = @picture.dimension.width
      @height = @picture.dimension.height
      
      pixelArr = @picture.pixels
      @colors = Array.new(@width) { Array.new(@height) }
      rowI = colI = 0
      pixelArr.each do |pixel|
        @colors[colI][rowI] = [ChunkyPNG::Color.r(pixel), ChunkyPNG::Color.g(pixel), ChunkyPNG::Color.b(pixel)]
        colI += 1
        if colI % width == 0 then
          colI = 0
          rowI += 1
        end
      end
    end
  end
  
  ## display picture
  # currently accepts an optional path
  # uses the ImageWindow class to display the image
  
  def displayPicture(pathForImage = nil)
    if !pathForImage.nil? then
      pict = Image.new(pathForImage)
      disp = ImageWindow.new(pict)
      disp.show
    else
      disp = ImageWindow.new(self)
      disp.show
    end
  end
  
  ## save picture
  # this function accepts a name parameter and an optional path
  # saves the image in the default path if none is provided (default is the directory of the currently loaded picture)
  # otherwise saves the image in the provided path
  # both variants make use of the passed-in name parameter
  
  def savePicture(name, path = nil)
    path.nil? ? @picture.save(File.join(@picturePath, name)) : @picture.save(File.join(path, name))
  end
  
  ## convert to grayscale
  # this function converts the current image into its grayscale representation
  # name and path are optional. if no name, it defaults to substituting in Grayed.png in place of the current .png
  # if there is no path, it defaults to the directory the current picture is located
  
  def convertToGrayscale(name = nil, path = nil)
    name ||= @pictureName.gsub('.png', 'Grayed.png')
    grayImage = @picture.grayscale
    path.nil? ? grayImage.save(File.join(@picturePath, name)) : grayImage.save(File.join(path, name))
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
  
  def sobelFilter(name = nil, pathForImage = nil, pathForSave = nil)
    name ||= @pictureName.gsub('.png', 'SobelFilter.png')
    pathForImage ||= File.join(@picturePath, @pictureName.gsub('.png', 'Grayed.png'))
    
    sobelFilterX = [[1, 2, 1], [0, 0, 0], [-1, -2, -1]]
    sobelFilterY = [[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]]
    height = @height-2
    width = @width-2
    copyImage = ChunkyPNG::Image.from_file(pathForImage)
    sobelPic = ChunkyPNG::Image.from_file(pathForImage)
    
    for j in 1..(height)
      for i in 1..(width)
        pixel1 = calculatePixelValueWithFilter3(sobelFilterX, copyImage, i, j, true)
        pixel2 = calculatePixelValueWithFilter3(sobelFilterY, copyImage, i, j, true)
        res = Math.sqrt(pixel1[0]*pixel1[0] + pixel2[0]*pixel2[0])
        sobelPic[i, j] = ChunkyPNG::Color.rgb(res.to_i, res.to_i, res.to_i)
      end
    end
    pathForSave.nil? ? sobelPic.save(File.join(@picturePath, name)) : sobelPic.save(File.join(pathForSave, name))
  end
  
  ## apply blur filter
  # this function has three optional parameters.
  # name: if omitted, defaults to substituting in Blurred.png in place of the current .png
  # pathForImage: if omitted, it defaults to the current image
  # pathForSave: if omitted, saves in the current directory
  # this function applies a blur filter to the current image. the matrix is not as strong as the Gaussian Blur filter, but it is 
  # significantly faster. if one does not want an image as blurred as with the gaussian algorithm, this might be desirable.
  
  def blur(name = nil, pathForImage = nil, pathForSave = nil)
    name ||= @pictureName.gsub('.png', 'Blurred.png')
    pathForImage ||= File.join(@picturePath, @pictureName)
    
    blurFilter = [[1/16.0, 2/16.0, 1/16.0], [2/16.0, 4/16.0, 2/16.0], [1/16.0, 2/16.0, 1/16.0]]
    height = @height-2
    width = @width-2
    blur = ChunkyPNG::Image.from_file(pathForImage)
    for j in 1..(height)
      for i in 1..(width)
        pixel = calculatePixelValueWithFilter3(blurFilter, @picture, i, j, false)
        blur[i, j] = ChunkyPNG::Color.rgb(pixel[0].to_i, pixel[1].to_i, pixel[2].to_i)
      end
    end
    pathForSave.nil? ? blur.save(File.join(@picturePath, name)) : blur.save(File.join(pathForSave, name))
  end
  
  ## apply gaussian blur filter
  # this function has three optional parameters.
  # name: if omitted, defaults to substituting in Gauss.png in place of the current .png
  # pathForImage: if omitted, it defaults to the current image
  # pathForSave: if omitted, saves in the current directory
  # this function makes use of a 5x5 matrix of values obtained from the Gaussian distribution in order to blur the image.
  # since this is a 5x5 matrix, it is computationally more intense.
  
  def gaussianBlur(name = nil, pathForImage = nil, pathForSave = nil)
    name ||= @pictureName.gsub('.png', 'Gauss.png')
    pathForImage ||= File.join(@picturePath, @pictureName)
    
    blurFilter = 
    [
      [0.01248, 0.02642, 0.03392, 0.02642, 0.01248], 
      [0.02642, 0.05592, 0.07180, 0.05592, 0.02642], 
      [0.03392, 0.07180, 0.09220, 0.07180, 0.03392], 
      [0.02642, 0.05592, 0.07180, 0.05592, 0.02642], 
      [0.01248, 0.02642, 0.03392, 0.02642, 0.01248], 
    ]

    height = @height-3
    width = @width-3
    blur = ChunkyPNG::Image.from_file(pathForImage)

    # t1 = Time.now
    # this section takes approximately 4.2482 seconds. The Lenna image is 220x220 pixels, so:
    # 220^2 = 48400. 4.2482 / 48400 -> each pixel takes approximately 0.0877 milliseconds to be processed.

    for j in 2..(height)
      for i in 2..(width)
        pixel = calculatePixelValueWithFilter5(blurFilter, @picture, i, j, false)
        blur[i, j] = ChunkyPNG::Color.rgb(pixel[0].to_i, pixel[1].to_i, pixel[2].to_i)
      end
    end

    # t2 = Time.now
    #    "%.9f" % t1.to_f
    #    "%.9f" % t2.to_f
    # puts (t2 - t1).to_s + " seconds."

    pathForSave.nil? ? blur.save(File.join(@picturePath, name)) : blur.save(File.join(pathForSave, name))
  end

  ## apply 1984 filter
  # this function has three optional parameters.
  # name: if omitted, defaults to substituting in 1984.png in place of the current .png
  # pathForImage: if omitted, it defaults to the current image
  # pathForSave: if omitted, saves in the current directory
  # this function makes use of an interesting matrix of trig functions in order to apply a unique filter to the image
  
  def surveillanceCamera(name = nil, pathForImage = nil, pathForSave = nil)
    name ||= @pictureName.gsub('.png', '1984.png')
    pathForImage ||= File.join(@picturePath, @pictureName)

    pi = Math::PI
    height = @height-3
    width = @width-3
    blur = ChunkyPNG::Image.from_file(pathForImage)
    for j in 2..(height)
      for i in 2..(width)
        pixel = calculatePixelValueWithFilter3([
          [-1*Math.cos(i*pi), -1*Math.cos(i*pi), -1*Math.cos(i*pi)], 
          [-1*Math.sin(j*pi), -1*Math.sin(j*pi), -1*Math.sin(j*pi)], 
          [-1*Math.tan((i/j)*pi), -1*Math.tan((i/j)*pi), -1*Math.tan((i/j)*pi)]
          ], @picture, i, j, false)
        blur[i, j] = ChunkyPNG::Color.rgb(pixel[0].to_i, pixel[1].to_i, pixel[2].to_i)
      end
    end
    pathForSave.nil? ? blur.save(File.join(@picturePath, name)) : blur.save(File.join(pathForSave, name))
  end
  
  ## apply sharpen filter
  # this function has three optional parameters.
  # name: if omitted, defaults to substituting in Sharpened.png in place of the current .png
  # pathForImage: if omitted, it defaults to the current image
  # pathForSave: if omitted, saves in the current directory
  # this function sharpens an image in order to highlight differences between edges
  
  def sharpen(name = nil, pathForImage = nil, pathForSave = nil)
    name ||= @pictureName.gsub('.png', 'Sharpened.png')
    pathForImage ||= File.join(@picturePath, @pictureName)
    
    sharpenFilter = [[-1, -1, -1], [-1, 9, -1], [-1, -1, -1]]
    
    height = @height-2
    width = @width-2
    sharpen = ChunkyPNG::Image.from_file(pathForImage)
    for j in 1..(height)
      for i in 1..(width)
        pixel = calculatePixelValueWithFilter3(sharpenFilter, @picture, i, j, false)
        sharpen[i, j] = ChunkyPNG::Color.rgb(pixel[0], pixel[1], pixel[2])
      end
    end
    pathForSave.nil? ? sharpen.save(File.join(@picturePath, name)) : sharpen.save(File.join(pathForSave, name))
  end
  
  ## draw bezier curve
  # this function has three optional parameters.
  # name: if omitted, defaults to substituting in Bezier.png in place of the current .png
  # pathForImage: if omitted, it defaults to the current image
  # pathForSave: if omitted, saves in the current directory
  # this function brings up a display of the currently loaded image
  # the user is allowed to click on points in the image which are then used as the control points for the bezier curve
  
  def bezierCurve(name = nil, pathForImage = nil, pathForSave = nil)
    name ||= @pictureName.gsub('.png', 'Bezier.png')
    
    displayPicture(pathForImage)
    points = parsePoints
    bez = @picture.bezier_curve(points) unless points.nil?
    pathForSave.nil? ? bez.save(File.join(@picturePath, name)) : bez.save(File.join(pathForSave, name)) unless bez.nil?
    if bez.nil? then
      puts "Unable to draw: no control points generated."
      return false
    else
      return true
    end
  end
  
  ## invert colors
  # this function has three optional parameters.
  # name: if omitted, defaults to substituting in Bezier.png in place of the current .png
  # pathForImage: if omitted, it defaults to the current image
  # pathForSave: if omitted, saves in the current directory
  # this function inverts the colors of the image
  
  def invert(name = nil, pathForImage = nil, pathForSave = nil)
    name ||= @pictureName.gsub('.png', 'Inverted.png')
    pathForImage ||= File.join(@picturePath, @pictureName)
    
    img = ChunkyPNG::Image.from_file(pathForImage)
    for i in (0...img.dimension.width)
      for j in (0...img.dimension.height)
        red = 255 - ChunkyPNG::Color.r(img[i,j])
        blue = 255 - ChunkyPNG::Color.g(img[i,j])
        green = 255 - ChunkyPNG::Color.b(img[i,j])
        img[i,j] = ChunkyPNG::Color.rgb(red, blue, green)
      end
    end
    
    pathForSave.nil? ? img.save(File.join(@picturePath, name)) : img.save(File.join(pathForSave, name))
  end
  
  ## emboss
  # this function has three optional parameters.
  # name: if omitted, defaults to substituting in Bezier.png in place of the current .png
  # pathForImage: if omitted, it defaults to the current image
  # pathForSave: if omitted, saves in the current directory
  # this function averages the colors of each pixel in order to convert it grayscale and emboss
  
  def emboss(name = nil, pathForImage = nil, pathForSave = nil, rgb = nil)
    name ||= @pictureName.gsub('.png', 'Embossed.png')
    pathForImage ||= File.join(@picturePath, @pictureName)
    
    embossFilter = [[-1, -1, 1], [-1, -1, 1], [1, 1, 1]]

    height = @height-2
    width = @width-2
    emboss = ChunkyPNG::Image.from_file(pathForImage)
    for j in 1..(height)
      for i in 1..(width)
        pixel = calculatePixelValueWithFilter3(embossFilter, @picture, i, j, false)
        if rgb then 
          emboss[i, j] = ChunkyPNG::Color.rgb(pixel[0], pixel[1], pixel[2])
        else
          val = (pixel[0] + pixel[1] + pixel[2])/3 
          emboss[i, j] = ChunkyPNG::Color.rgb(val, val, val)
        end
      end
    end
    
    pathForSave.nil? ? emboss.save(File.join(@picturePath, name)) : emboss.save(File.join(pathForSave, name))
  end
  
  ## CPVF3
  # this function is not a typical matrix multiplication operation
  # it applies the mathematical convolution operation to the image
  # it accepts a parameter of the filter of to be applied, the current image, the current coordinates and a grayscale indicator
  # the grayscale indicator is a bool indicating whether to just calculate a single color value
  # i'm pretty sure we can take out the img parameter
  
  def calculatePixelValueWithFilter3(filter, img, currX, currY, grayscale)
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
    return constrainToColors(value)
  end
  
  ## CPVF5
  # this function is not a typical matrix multiplication operation
  # it applies the mathematical convolution operation to the image
  # it accepts a parameter of the filter of to be applied, the current image, the current coordinates and a grayscale indicator
  # the grayscale indicator is a bool indicating whether to just calculate a single color value
  # i'm pretty sure we can take out the img parameter
  
  # this function takes between 0 and 0.001001 seconds
  def calculatePixelValueWithFilter5(filter, img, currX, currY, grayscale)
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
    return constrainToColors(value)
  end
  
  ## PRIVATE UTILITY FUNCTIONS
  private
  
  ## constrain function
  # this function accepts an array of [r,g,b] values and constrains them to allowable pixel values
  # if the value is over 255, it is set to 255
  # if the value is less than 0, it is set to 0
  # else, it is unchanged
  def constrainToColors(array)
    array[0] > 255 ? array[0] = 255 : array[0] < 0 ? array[0] = 0 : array[0]
    array[1] > 255 ? array[1] = 255 : array[1] < 0 ? array[1] = 0 : array[1]
    array[2] > 255 ? array[2] = 255 : array[2] < 0 ? array[2] = 0 : array[2]
    return array
  end
  
  ## point parser
  # this function reads control point information from the data file
  # it uses the x- and y-coordinates of each control point to instantiate a Point object
  # the point object is pushed to an array called points that is the return value of this function under correct conditions
  def parsePoints
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
  
end