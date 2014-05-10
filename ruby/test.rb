require_relative 'Image.rb'


picture = Image.new("../pictures/Lenna.png")
# grayed = picture.grayscale(name: "result.png")
# grayed.save_and_display
# 
# gauss = picture.gaussian_blur(name: "gaussed.png")
# gauss.save
# gauss.display
# 
# emboss = picture.emboss
# emboss.save_and_display
# 
# invertedE = emboss.invert
# invertedE.save_and_display
# 
# regInv = picture.invert
# regInv.save_and_display
# picture.histogram