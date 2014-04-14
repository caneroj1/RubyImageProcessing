require 'chunky_png'

class Image 
  attr_reader :width, :height, :picturePath, :pictureName
  
  def initialize(path)
    @picturePath = File.split(path)[0]
    @pictureName = File.split(path)[1]
    
    @picture = ChunkyPNG::Image.from_file(path)
    @width = @picture.dimension.width
    @height = @picture.dimension.height
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
  end
  
  def sobelX(name = nil, pathForImage = nil, pathForSave = nil)
    if name.nil? then
      name = @pictureName.gsub('.png', 'SobelX.png')
    end
    
    if pathForImage.nil? then
      pathForImage = File.join(@picturePath, @pictureName.gsub('.png', 'Grayed.png'))
    end
    
    sobelFilter = [[1, 2, 1], [0, 0, 0], [-1, -2, -1]]
    height = @height
    width = @width
    heightIndex = 1
    copyImage = ChunkyPNG::Image.from_file(pathForImage)
    sobelX = ChunkyPNG::Image.from_file(pathForImage)
    
    begin
      widthIndex = 1
      begin
        pixel = calculatePixelValueWithFilter(sobelFilter, copyImage, widthIndex, heightIndex, true)
        sobelX[widthIndex, heightIndex] = ChunkyPNG::Color.rgb(pixel[0].abs, pixel[0].abs, pixel[0].abs)
        widthIndex += 1
      end while widthIndex < (width - 1)
      heightIndex += 1
    end while heightIndex < (height - 1)
    pathForSave.nil? ? sobelX.save(File.join(@picturePath, name)) : sobelX.save(File.join(pathForSave, name))
  end
  
  def sobelY(name = nil, pathForImage = nil, pathForSave = nil)
    if name.nil? then
      name = @pictureName.gsub('.png', 'SobelY.png')
    end
      
    if pathForImage.nil? then
      pathForImage = File.join(@picturePath, @pictureName.gsub('.png', 'Grayed.png'))
    end
    
    sobelFilter = [[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]]
    height = @height
    width = @width
    heightIndex = 1
    copyImage = ChunkyPNG::Image.from_file(pathForImage)
    sobelY = ChunkyPNG::Image.from_file(pathForImage)
    
    begin
      widthIndex = 1
      begin
        pixel = calculatePixelValueWithFilter(sobelFilter, copyImage, widthIndex, heightIndex, true)
        sobelY[widthIndex, heightIndex] = ChunkyPNG::Color.rgb(pixel[0].abs, pixel[0].abs, pixel[0].abs)
        widthIndex += 1
      end while widthIndex < (width - 1)
      heightIndex += 1
    end while heightIndex < (height - 1)
    pathForSave.nil? ? sobelY.save(File.join(@picturePath, name)) : sobelY.save(File.join(pathForSave, name))
  end
  
  def blur(name = nil, pathForSave = nil)
    if name.nil? then
      name = @pictureName.gsub('.png', 'Blurred.png')
    end
    
    blurFilter = [[1, 2, 1], [2, 4, 2], [1, 2, 1]]
    height = @height
    width = @width
    heightIndex = 1
    blur = ChunkyPNG::Image.from_file(File.join(@picturePath, @pictureName))

    begin
      widthIndex = 1
      begin
        pixel = calculatePixelValueWithFilter(blurFilter, @picture, widthIndex, heightIndex, false)
        blur[widthIndex, heightIndex] = ChunkyPNG::Color.rgb(pixel[0]/16, pixel[1]/16, pixel[2]/16)
        widthIndex += 1
      end while widthIndex < (width - 1)
      heightIndex += 1
    end while heightIndex < (height - 1)
    pathForSave.nil? ? blur.save(File.join(@picturePath, name)) : blur.save(File.join(pathForSave, name))
  end
  
  def calculatePixelValueWithFilter(filter, img, currX, currY, grayscale)
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
    return value
  end
end