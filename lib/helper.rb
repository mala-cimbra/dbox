#!/usr/bin/env ruby

def analyze(path, mimetype)

    case mimetype
    when /(image)/i # info_foto
        info_foto(path)
    when /(audio)/i # info_audio
        info_audio(path, mimetype)
    when /(text|document)/i
        JSON.generate({type: "text"})
    when /(video)/i # info_video
        JSON.generate({type: "video"})
    else
        JSON.generate({type: "data"})
    end
end