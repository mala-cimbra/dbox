#!/usr/bin/env ruby

def info_audio(filename, path, filetype)
    audio_data = Array.new
    
    TagLib::FileRef.open(path) do |audio|
        tag = audio.tag
        prop = audio.audio_properties
        string_durata = "#{prop.length / 60}:#{prop.length % 60}"
        audio_data << tag.artist << tag.title << tag.album << string_durata << prop.bitrate
    end
    
"""<ul>
    <li><strong>Artista: </strong>#{audio_data[0]}</li>
    <li><strong>Titolo: </strong>#{audio_data[1]}</li>
    <li><strong>Album: </strong>#{audio_data[2]}</li>
    <li><strong>Durata: </strong>#{audio_data[3]}</li>
    <li><strong>Bitrate: </strong>#{audio_data[4]} kbps</li>
</ul>
<h3>Anteprima</h3>
<div align=\"center\"><audio controls>
    <source src=\"/downloads/#{filename}\" type=\"#{filetype}\">
Il tuo browser è vecchio e non supporta il tag audio. Aggiornati!
</audio></div>"""
end