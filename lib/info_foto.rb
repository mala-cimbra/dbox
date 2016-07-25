#!/usr/bin/env ruby

# gestito da mini_exiftool

def info_foto(path)
    foto_data = Hash.new
    foto = MiniExiftool.new(path)
    
    foto_data = {size: foto.imagesize, model: foto.model, createdate: foto.createdate}

    JSON.generate(foto_data)
end