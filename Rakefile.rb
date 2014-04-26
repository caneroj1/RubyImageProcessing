nameHash = Hash.new()
processing = ["Grayed.png", "SobelFilter.png", "Blurred.png", "Gauss.png", "Sharpened.png", "Bezier.png", "1984.png"]

directory "data"
directory "info" => "data"
file "info/pictures.txt" => "info"

task :create, [:name] => "info/pictures.txt" do |t, args|
    if !args.name.nil? then
    File.open("info/pictures.txt", "a") do |f|
      puts "info/pictures.txt ----> wrote #{args.name}"
      f.write("#{args.name}\n")
      if !args.extras.nil? then
        args.extras.each do |e|
          puts "info/pictures.txt ----> wrote #{e}"
          f.write("#{e}\n")
        end
      end
    end
  end
end


task :clean do
  # create array of file names from pictures.txt
  names = Array.new()
  File.open("info/pictures.txt", "r") do |f|
    f.each_line do |l|
      names.push(l[0..-6])
    end
  end
  
  # try to remove files with all possible extensions created through processing
  names.each do |i|
    processing.each do |j|
      begin
        File.delete("pictures/#{i}"+"#{j}")
      rescue => e
        puts "Could not delete: #{e.message}"
      end
    end
  end  
  
  # delete pictures.txt
  puts "Deleting ----> info/pictures.txt"
  File.delete("info/pictures.txt")
end