require_relative 'Image.rb'

picture = Image::new("pictures/Lenna.png")
picture.convertToGrayscale
picture.sobelX
picture.sobelY
picture.blur