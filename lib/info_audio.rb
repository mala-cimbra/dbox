#!/usr/bin/env ruby

# gestito da taglib-ruby

def info_audio(path, mimetype)

    audio_data = Hash.new # hash contenente di dati da convertire in json
    
    TagLib::FileRef.open(path) do |audio|
        tag = audio.tag
        prop = audio.audio_properties
        minuti = prop.length / 60
        secondi = sprintf("%0.2d", prop.length % 60)
        string_durata = "#{minuti}:#{secondi}"
        
        # popola l'hash con i dati
        audio_data = {artist: tag.artist, title: tag.title, album: tag.album, length: string_durata, bitrate: prop.bitrate}
    end
    
    # in caso di file mp3, ogg, flac, m4a
    case mimetype
    when 'audio/mpeg;'
        cover = {base64_cover:open_mpeg()}
    when 'audio/ogg;'
        
    when 'audio/x-flac;'
    else
        
    end
    audio_data.merge!(cover)
    JSON.generate(audio_data) # genera JSON
end

def open_mpeg(path) # cover presente nel file
    TagLib::MPEG::File.open(path) do |file|
        tag = file.id3v2_tag
        lista_img_cd = tag.frame_list('APIC').first
        front = lista_img_cd.picture
    end
    Base64.encode64(front)
end

def open_ogg() # cover nel file ogg
    
end

def open_flac() # cover nel file flac
    
end