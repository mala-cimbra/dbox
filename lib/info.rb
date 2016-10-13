#!/usr/bin/env ruby

# info sul file
get '/info/:filename/detail' do |filename|
    # QUERY
    # prendi tutta la riga dove il file ha nome file "filename"
    @db_file = $db.execute("SELECT * FROM files WHERE filename = '#{filename}';")
    
    # debug, ma lo togliamo
    # debug("db_file", @db_file)
    # debug("empty?", @db_file.empty?)
    
    # se NON è vuoto e SE il file esiste (comunque se non è vuoto il file deve esistere)
    # indice 2 dell'array (0 è la riga visto che è una)
    # il 2 sta sul path
    if !@db_file.empty? && File.exist?(@db_file[0][2])
        
        # la posizione 10 è il mimetype/filetype come colonna
        mimetype = @db_file[0][10]
        
        # tirami fuori i metadati in JSON
        metadata = JSON.parse(@db_file[0][11])
        
        # calcolo della dimensione del file.
        # nel db è salvato un INT per il numero di byte
        if @db_file[0][12] > 1000 && @db_file[0][12] < 999999
            # kilobyte
            @size = [@db_file[0][12].to_f / 1024, " K"]
            @size[0] = @size[0].round(2)
        elsif @db_file[0][12] > 1000000 && @db_file[0][12] < 999999999
            # megabyte
            @size = [@db_file[0][12].to_f / 1024 / 1024, " M"]
            @size[0] = @size[0].round(2)
        elsif @db_file[0][12] > 1000000000
            # gigabyte
            @size = [db_file[0][12].to_f / 1024 / 1024 / 1024, " G"]
            @size[0] = @size[0].round(2)
        else
            # byte
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
