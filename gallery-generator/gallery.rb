require 'fileutils'
require 'shellwords'
require 'uri'
require 'cgi'

folder_path = "."
thumbs_folder = "thumbs"
photo_types = ["jpg", "jpeg", "png", "gif", "heic"]
folder_name = File.basename(Dir.getwd)

Dir.mkdir(thumbs_folder) unless Dir.exist?(thumbs_folder)

sorted_photos = Dir.entries(folder_path).select do |entry|
  photo_types.include? File.extname(entry).downcase[1..]
end.sort

sorted_photos.map! do |photo|
  sanitized_photo = CGI.escape(photo).gsub('+', '_').gsub('%', '_').gsub(' ', '_')
  if sanitized_photo != photo
    puts "Renaming #{photo} to #{sanitized_photo}"
    File.rename(photo, sanitized_photo)
  end
  sanitized_photo
end.sort!

File.open("index.html", "w") do |f|
  f.write("<html>\n")
  f.write("<head>\n")
  f.write("<title>#{folder_name} Foto Index</title>\n")
  f.write('<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/css/bootstrap.min.css" rel="stylesheet">')
  f.write('<style>.row { margin-bottom: 20px; align-items: center; } body { background-color: #1a1a1a; } .img-fluid:hover { box-shadow: 0 0 5px rgba(255,255,255,0.3); } .col { min-height: 300px; }</style>')
  f.write("</head>\n")
  f.write("<body>\n")
  f.write("<div class='container'>\n")
  f.write("<h1 class='text-center my-5 text-white'>#{folder_name}</h1>\n")

  f.write("<div class='row mb-4'>\n")

  sorted_photos.each do |photo|
    thumb_path = File.join(thumbs_folder, "#{File.basename(photo, File.extname(photo))}.jpeg")
    escaped_photo = Shellwords.escape(photo)
    escaped_thumb_path = Shellwords.escape(thumb_path)

    unless File.exist?(thumb_path)
      puts "Creating thumbnail for #{photo}..."
      escaped_jpeg_thumb_path = Shellwords.escape("#{thumbs_folder}/#{File.basename(photo, File.extname(photo))}.jpeg")
      system("convert #{escaped_photo} -resize 1200x1200 #{escaped_jpeg_thumb_path}")
    end

    f.write("<div class='col-lg-3 col-md-6 col-sm-12 d-flex align-items-center justify-content-center mb-4'>\n")
    f.write("<a href=\"#{photo}\"><img src=\"#{thumb_path}\" class='rounded img-fluid' alt=\"#{photo}\"></a>\n")
    f.write("</div>\n")
  end

  f.write("</div>\n")
  f.write("</div>\n")
  f.write("</body>\n")
  f.write("</html>\n")
end

puts "index.html was created successfully."
