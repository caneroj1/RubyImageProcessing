require_relative 'Image.rb'


# picture = Image.new("../pictures/Lenna.png")
# picture.displayPicture
# puts "Inverting colors"
# picture.invert
# puts "Displaying inversion"
# picture.displayPicture("../Pictures/LennaInverted.png")
# puts "Embossing image"
# picture.emboss
# puts "Displaying embossed"
# picture.displayPicture("../Pictures/LennaEmbossed.png")
# puts "Converting to grayscale."
# picture.convertToGrayscale
# puts "Displaying grayscale."
# picture.displayPicture("../pictures/LennaGrayed.png")
# puts "Applying Gaussian blur."
# picture.gaussianBlur
# puts "Displaying Gaussian blur."
# picture.displayPicture("../pictures/LennaGauss.png")
# puts "Applying surveillance filter."
# picture.surveillanceCamera
# puts "Displaying surveillance filter."
# picture.displayPicture("../pictures/Lenna1984.png")
# puts "Applying sharpening filter."
# picture.sharpen
# puts "Displaying sharpened."
# picture.displayPicture("../pictures/LennaSharpened.png")
# puts "Applying sobel filters."
# picture.sobelFilter
# puts "Displaying filtered image."
# picture.displayPicture("../pictures/LennaSobelFilter.png")
# puts "Draw your Bezier curve!"
# res = picture.bezierCurve
# if res then
#   puts "Displaying Bezier curve."
#   picture.displayPicture("../pictures/LennaBezier.png")
# end



# 
# 
# waterfall = Image::new("../pictures/waterfall.png")
# waterfall.convertToGrayscale
# waterfall.gaussianBlur 
# waterfall.sobelFilter
# waterfall.sharpen
# 
# 
# bear = Image::new("../pictures/tricycleBear.png")
# bear.gaussianBlur
# bear.blur
# bear.sharpen
# bear.convertToGrayscale
# bear.sobelFilter
# 
# 
# machinery = Image::new("../pictures/machinery.png")
# machinery.convertToGrayscale
# machinery.sobelFilter
# machinery.blur
# machinery.sharpen
# machinery.gaussianBlur