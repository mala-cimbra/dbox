#!/usr/bin/env ruby

# Pagina download
get '/downloads' do
    # prende la lista dei file da database e lo porta in un array
    # visto che funziona a righe avrebbe dei array annidati,
    # qui il flatten per incicciottare [[row][row][row][row][row]]
    # tutto in un unico array [row, row, row, row]
    # inutile ciclare per un dato solo, se si avranno bisogno di più dati nella riga
    # ci si penserà
    #
    # poi si spedisce @list alla pagina downloads.erb
    # adesso c'è anche il tipo
    # [[filename, filetype], [filename, filetype], [filename, filetype], [filename, filetype] ...] 
    @list = $db.execute("SELECT filename, filetype FROM files;")
    @list.map do |file|
        type = file[1].split("/")
        case type[0]
        when "image"
            file[1] = "<i class=\"fa fa-file-image-o\" aria-hidden=\"true\"></i>"
        when "audio"
            file[1] = "<i class=\"fa fa-file-audio-o\" aria-hidden=\"true\"></i>"
        when "video"
            file[1] = "<i class=\"fa fa-file-video-o\" aria-hidden=\"true\"></i>"
        else
            file[1] = "<i class=\"fa fa-file-o\" aria-hidden=\"true\"></i>"
        end
    end
    erb :downloads
end

get '/downloads/:filename' do |filename|
    # se il nome del file esiste
    # TODO: fargli fare un controllo anche sul db
    # se per caso esiste il file, ma non sul db, boh,
    # magari gli faccio scrivere qualche file di log
    # è comunque una cosa che non dovrebbe succedere,
    # ma la sfiga è sempre tanta
    if File.exist?("./public/uploads/#{filename}")
        # tira fuori il numero di dl del file per aumentare il contatore
        dl_count = $db.execute("SELECT dl_number from files WHERE filename = '#{filename}';")
        debug("conteggio download, query", dl_count)
        new_dl_count = dl_count.flatten[0].to_i + 1 # lo flatta per il discorso sopra e aggiunge 1
        # aggiorna il db, sql a nastro
        $db.execute("UPDATE files SET dl_number=#{new_dl_count}, last_dl_ip='#{request.ip}', last_dl_date='#{Time.now}' WHERE filename='#{filename}';")
        # spedisce il file
        send_file("./public/uploads/#{filename}", :filename => filename, :disposition => :attachment, :type => 'application/octet-stream')
    else
        # altrimenti torna indrio ai download
        redirect to('/downloads')
    end
end