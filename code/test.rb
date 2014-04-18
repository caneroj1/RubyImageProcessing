require_relative 'Image.rb'


picture = Image::new("../pictures/Lenna.png")
picture.convertToGrayscale
picture.gaussianBlur
picture.sharpen
picture.sobelFilter


waterfall = Image::new("../pictures/waterfall.png")
waterfall.convertToGrayscale
waterfall.gaussianBlur 
waterfall.sobelFilter
waterfall.sharpen


bear = Image::new("../pictures/tricycleBear.png")
bear.gaussianBlur
bear.blur
bear.sharpen
bear.convertToGrayscale
bear.sobelFilter


machinery = Image::new("../pictures/machinery.png")
machinery.convertToGrayscale
machinery.sobelFilter
machinery.blur
machinery.sharpen
machinery.gaussianBlur