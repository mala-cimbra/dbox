#!/usr/bin/env ruby

# mostra la pagina di upload
get '/upload' do
    erb :upload
end

# http post per spedire il file
post '/upload' do
    # semplice check sull'input, se qualcuno spara zero file, se qualcuno uppa un file con
    # lo stesso nome già presente
    if params['file'] == nil || params['file'] == "" || File.exist?("./public/uploads/#{params['file'][:filename]}")
        # redireziona ad upload
        # TODO magari mostrare un messaggio di errore
        redirect to('/upload')
    else
        # qua c'è un po' di magia, la prendo per buona
        tempfile = params['file'][:tempfile] # file temporaneo uploadato, penso vada in /tmp
        filename = params['file'][:filename] # file scritto
        path = "./public/uploads/#{filename}" # percorso di destinazione
        
        # scrivi
        File.open(path, "wb") do |f|
            f.write(tempfile.read)
        end
        
        filetype = File.mime(path).split[0] # mimetype del file
        shadigest = Digest::SHA256.hexdigest(File.read(path)) # calcola sommahash
        delete_password = params['password'] # tirami fuori la password
        
        # aggiungi la cosa al db
        $db.execute("INSERT INTO files VALUES(NULL, '#{filename}', '#{path}', '#{shadigest}', '#{request.ip}', '#{Time.now}', 0, NULL, NULL, '#{delete_password}', '#{filetype}');")
    end
    redirect to('/downloads') # mostrami poi quello che hai buttato su
end