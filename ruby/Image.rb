require 'chunky_png'
require_relative 'ImageWindow.rb'

class Image 
  attr_reader :width, :height, :picturePath, :pictureName
  
  def initialize(path = nil)
    if !path.nil? then
      @picturePath = File.split(path)[0]
      @pictureName = File.split(path)[1]
    
      @picture = ChunkyPNG::Image.from_file(path)
      @width = @picture.dimension.width
      @height = @picture.dimension.height
    end
  end
  
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
  
  def savePicture(name, path = nil)
    path.nil? ? @picture.save(File.join(@picturePath, name)) : @picture.save(File.join(path, name))
  end
  
  def convertToGrayscale(name = nil, path = nil)
    if name.nil? then
      name = @pictureName.gsub('.png', 'Grayed.png')
    end
    grayImage = @picture.grayscale
    path.nil? ? grayImage.save(File.join(@picturePath, name)) : grayImage.save(File.join(path, name))
  end
  
  def convertToGrayscale!
    @picture.grayscale!
    @picture.save(File.join(@picturePath, @pictureName))
  end
  
  def sobelFilter(name = nil, pathForImage = nil, pathForSave = nil)
    if name.nil? then
      name = @pictureName.gsub('.png', 'SobelFilter.png')
    end
    
    if pathForImage.nil? then
      pathForImage = File.join(@picturePath, @pictureName.gsub('.png', 'Grayed.png'))
    end
    
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
  
  def blur(name = nil, pathForImage = nil, pathForSave = nil)
    if name.nil? then
      name = @pictureName.gsub('.png', 'Blurred.png')
    end
    
    if pathForImage.nil? then
      pathForImage = File.join(@picturePath, @pictureName)
    end
    
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
  
  def gaussianBlur(name = nil, pathForImage = nil, pathForSave = nil)
    if name.nil? then
      name = @pictureName.gsub('.png', 'Gauss.png')
    end
    
    if pathForImage.nil? then
      pathForImage = File.join(@picturePath, @pictureName)
    end
    
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

    t1 = Time.now
    # this section takes approximately 4.2482 seconds. The Lenna image is 220x220 pixels, so:
    # 220^2 = 48400. 4.2482 / 48400 -> each pixel takes approximately 0.0877 milliseconds to be processed.

    for j in 2..(height)
      for i in 2..(width)
        pixel = cpvFilter5Optimize(blurFilter, @picture, i, j, false)
        blur[i, j] = ChunkyPNG::Color.rgb(pixel[0].to_i, pixel[1].to_i, pixel[2].to_i)
      end
    end

    t2 = Time.now
    "%.9f" % t1.to_f
    "%.9f" % t2.to_f
    puts (t2 - t1).to_s + " seconds."

    pathForSave.nil? ? blur.save(File.join(@picturePath, name)) : blur.save(File.join(pathForSave, name))
  end

  # 1984 filter
  def surveillanceCamera(name = nil, pathForImage = nil, pathForSave = nil)
    if name.nil? then
      name = @pictureName.gsub('.png', '1984.png')
    end
    
    if pathForImage.nil? then
      pathForImage = File.join(@picturePath, @pictureName)
    end

    pi = 3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679

    height = @height-3
    width = @width-3
    blur = ChunkyPNG::Image.from_file(pathForImage)
    for j in 2..(height)
      for i in 2..(width)
        pixel = calculatePixelValueWithFilter3([[-1*Math.cos(i*pi), -1*Math.cos(i*pi), -1*Math.cos(i*pi)], [-1*Math.sin(j*pi), -1*Math.sin(j*pi), -1*Math.sin(j*pi)], [-1*Math.tan((i/j)*pi), -1*Math.tan((i/j)*pi), -1*Math.tan((i/j)*pi)]], @picture, i, j, false)
        # pixel = calculatePixelValueWithFilter3([[-1, -1, -1], [-1, 8, -1], [Math.tan(j/pi), Math.tan(j/pi), Math.tan(j/pi)]], @picture, i, j, false) # curtains filter
        blur[i, j] = ChunkyPNG::Color.rgb(pixel[0].to_i, pixel[1].to_i, pixel[2].to_i)
      end
    end
    pathForSave.nil? ? blur.save(File.join(@picturePath, name)) : blur.save(File.join(pathForSave, name))
  end
  
  def sharpen(name = nil, pathForImage = nil, pathForSave = nil)
    if name.nil? then
      name = @pictureName.gsub('.png', 'Sharpened.png')
    end
    
    if pathForImage.nil? then
      pathForImage = File.join(@picturePath, @pictureName)
    end
    
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
  
  def bezierCurve(name = nil, pathForImage = nil, pathForSave = nil)
    if name.nil? then
      name = @pictureName.gsub('.png', 'Bezier.png')
    end
    
    displayPicture(pathForImage)
    points = parsePoints
    bez = @picture.bezier_curve(points)
    pathForSave.nil? ? bez.save(File.join(@picturePath, name)) : bez.save(File.join(pathForSave, name))
  end
  
  def calculatePixelValueWithFilter3(filter, img, currX, currY, grayscale)
    value = [0, 0, 0]
    for i in 0..2
      for j in 0..2
        if grayscale then
          value[0] += filter[i][j] * ChunkyPNG::Color.r(img[(currX-1)+j, (currY-1)+i])
        else
          value[0] += filter[i][j] * ChunkyPNG::Color.r(img[(currX-1)+j, (currY-1)+i])
          value[1] += filter[i][j] * ChunkyPNG::Color.g(img[(currX-1)+j, (currY-1)+i])
          value[2] += filter[i][j] * ChunkyPNG::Color.b(img[(currX-1)+j, (currY-1)+i])
        end
      end
    end
    return constrainToColors(value)
  end
  
  # this function takes between 0 and 0.001001 seconds
  def calculatePixelValueWithFilter5(filter, img, currX, currY, grayscale)
    value = [0, 0, 0]
    for i in 0..4
      for j in 0..4
        if grayscale then
          value[0] += filter[i][j] * ChunkyPNG::Color.r(img[(currX-2)+j, (currY-2)+i])
        else
          value[0] += filter[i][j] * ChunkyPNG::Color.r(img[(currX-2)+j, (currY-2)+i])
          value[1] += filter[i][j] * ChunkyPNG::Color.g(img[(currX-2)+j, (currY-2)+i])
          value[2] += filter[i][j] * ChunkyPNG::Color.b(img[(currX-2)+j, (currY-2)+i])
        end
      end
    end
    return constrainToColors(value)
  end

  # attempt at optimization of calculatePixelValueWithFilter5
  # for the time being, let's assume images are never greyscale
  def cpvFilter5Optimize(filter, img, currX, currY, grayscale)
    value = [0, 0, 0]
    for i in 0..4
      for j in 0..4
        value[0] += filter[i][j] * ChunkyPNG::Color.r(img[(currX-2)+j, (currY-2)+i])
        value[1] += filter[i][j] * ChunkyPNG::Color.g(img[(currX-2)+j, (currY-2)+i])
        value[2] += filter[i][j] * ChunkyPNG::Color.b(img[(currX-2)+j, (currY-2)+i])
      end
    end
    return constrainToColors(value)
  end
  
  private
  def constrainToColors(array)
    array[0] > 255 ? array[0] = 255 : array[0] < 0 ? array[0] = 0 : array[0]
    array[1] > 255 ? array[1] = 255 : array[1] < 0 ? array[1] = 0 : array[1]
    array[2] > 255 ? array[2] = 255 : array[2] < 0 ? array[2] = 0 : array[2]
    return array
  end
  
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
    rescue IOError => e
      puts "There were no points collected."
    end
    return points
  end
  
end