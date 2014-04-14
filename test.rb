require_relative 'Image.rb'

picture = Image::new("pictures/Lenna.png")
picture.convertToGrayscale
picture.sobelX
picture.sobelY
picture.blur

picture2 = Image::new("pictures/waterfall.png")
picture2.convertToGrayscale
picture2.sobelX
picture2.sobelY
picture2.blur