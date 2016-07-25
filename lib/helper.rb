#!/usr/bin/env ruby

def analyze(path, mimetype)

    case mimetype
    when /(image)/i
        info_foto(path)
    when /(audio)/i
        info_audio(path)
    when /(video)/i
        JSON.generate('{"type":"video"}')
    else
        JSON.generate('{}')
    end
end