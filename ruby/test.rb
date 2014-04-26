require_relative 'Image.rb'


# picture = Image::new("../pictures/Lenna.png")
# picture.displayPicture
# puts "Converting to grayscale."
# picture.convertToGrayscale
# puts "Displaying grayscale."
# picture.displayPicture("../pictures/LennaGrayed.png")
# puts "Applying gaussian blur."
# picture.gaussianBlur
# puts "Displaying guassian blur."
# picture.displayPicture("../pictures/LennaGauss.png")
# puts "Applying sharpening filter."
# picture.sharpen
# puts "Displaying sharpened."
# picture.displayPicture("../pictures/LennaSharpened.png")
# puts "Applying sobel filters."
# picture.sobelFilter
# puts "Displaying filtered image."
# picture.displayPicture("../pictures/LennaSobelFilter.png")
# 
# 
# waterfall = Image::new("../pictures/waterfall.png")
# waterfall.convertToGrayscale
# waterfall.gaussianBlur 
# waterfall.sobelFilter
# waterfall.displayPicture("../pictures/waterfallSobelFilter.png")
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
machinery = Image::new("../pictures/machinery.png")
machinery.convertToGrayscale
machinery.sobelFilter
machinery.blur
machinery.sharpen
machinery.gaussianBlur
