require 'chunky_png'

def calculatePixelValueWithFilter(filter, img, currX, currY)
  value = 0
  for i in 0..2
    for j in 0..2
      value += filter[i][j] * ChunkyPNG::Color.r(img[(currX-1)+j, (currY-1)+i])
    end
  end
  return value
end

def sobelX(img, img1)
  sobelFilter = [[1, 2, 1], [0, 0, 0], [-1, -2, -1]]
  height = img.dimension.height
  width = img.dimension.width
  heightIndex = 1
  begin
    widthIndex = 1
    begin
      pixel = calculatePixelValueWithFilter(sobelFilter, img, widthIndex, heightIndex).abs
      img1[widthIndex, heightIndex] = ChunkyPNG::Color.rgb(pixel, pixel, pixel)
      widthIndex += 1
    end while widthIndex < (width - 1)
    heightIndex += 1
  end while heightIndex < (height - 1)
  img1.save('pictures/sobelFilterX.png')
end

def sobelY(img, img1)
  sobelFilter = [[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]]
  height = img.dimension.height
  width = img.dimension.width
  heightIndex = 1
  begin
    widthIndex = 1
    begin
      pixel = calculatePixelValueWithFilter(sobelFilter, img, widthIndex, heightIndex).abs
      img1[widthIndex, heightIndex] = ChunkyPNG::Color.rgb(pixel, pixel, pixel)
      widthIndex += 1
    end while widthIndex < (width - 1)
    heightIndex += 1
  end while heightIndex < (height - 1)
  img1.save('pictures/sobelFilterY.png')
end

processID = fork()
if !processID.nil? then
  puts processID
  puts "Waiting for #{Process.wait}"
else
  puts "nil"
end
if processID.nil? then
  puts "I am the child with ID: !#{Process.pid}"
  image = ChunkyPNG::Image.from_file('pictures/Lenna.png')
  puts "Height #{image.dimension.height}"
  puts "Width #{image.dimension.width}"
  image2 = image.grayscale()
  image3 = image.grayscale()
  image4 = image.grayscale()
  sobelX(image2, image3)
  sobelY(image2, image4)
  image2.save('pictures/Lenna.png')
end