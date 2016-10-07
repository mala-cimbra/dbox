#!/usr/bin/env ruby

# info sul file
get '/info/:filename/detail' do |filename|
    @db_file = $db.execute("SELECT * FROM files WHERE filename = '#{filename}';")
    
    debug("db_file", @db_file)
    debug("empty?", @db_file.empty?)
    
    if !@db_file.empty? && File.exist?(@db_file[0][2])
        
        mimetype = @db_file[0][10]
        metadata = JSON.parse(@db_file[0][11])
        
        if @db_file[0][12] > 1000 && @db_file[0][12] < 999999
            @size = [@db_file[0][12].to_f / 1024, " K"]
            @size[0] = @size[0].round(2)
        elsif @db_file[0][12] > 1000000 && @db_file[0][12] < 999999999
            @size = [@db_file[0][12].to_f / 1024 / 1024, " M"]
            @size[0] = @size[0].round(2)
        elsif @db_file[0][12] > 1000000000
            @size = [db_file[0][12].to_f / 1024 / 1024 / 1024, " G"]
            @size[0] = @size[0].round(2)
        else
            @size = [@db_file[0][12], " "]
        end
        
        case mimetype
        when /(image)/i
            @data = """<ul>
<li><strong>Dimensioni: </strong>#{metadata["size"]}</li>
<li><strong>Modello Fotocamera: </strong>#{metadata["model"]}</li>
<li><strong>Data di scatto: </strong>#{metadata["createdate"]}</li>
</ul>
<h3>Anteprima</h3>
<div align=\"center\">
<img src=\"/uploads/#{filename}\" alt=\"Anteprima\"/>
</div>"""
        when /(audio)/i
            @data = """<ul>
<li><strong>Artista: </strong>#{metadata["artist"]}</li>
<li><strong>Titolo: </strong>#{metadata["title"]}</li>
<li><strong>Album: </strong>#{metadata["album"]}</li>
<li><strong>Durata: </strong>#{metadata["length"]}</li>
<li><strong>Bitrate: </strong>#{metadata["bitrate"]} kbps</li>
<li><strong>Copertina: </strong><img alt=\"Embedded Image\" src=\"data:image/jpg;base64,#{metadata["base64_cover"]} /></li>
</ul>
<h3>Anteprima</h3>
<div align=\"center\"><audio controls>
<source src=\"/uploads/#{filename}\" type=\"#{mimetype}\">
Il tuo browser è vecchio e non supporta il tag audio. Aggiornati!
</audio></div>"""
        when /(video)/i
            @data = "video"
        else
            @data = "generic"
        end
        
        erb :info
    else
        redirect to ('/downloads') # vai ai downloads
    end
end
