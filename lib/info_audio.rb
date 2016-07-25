#!/usr/bin/env ruby

# gestito da taglib-ruby

def info_audio(path)

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

    JSON.generate(audio_data) # genera JSON
end