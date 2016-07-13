#!/usr/bin/env ruby

# funzione di eliminazione
# TODO da debuggare pesantemente
# devo pensarla bene
get '/delete/:filename/confirm' do |filename|
    file_row = $db.execute("SELECT * FROM files WHERE filename='#{filename}';")
    debug("file_row", file_row)
    @filename = filename
    erb :delete
end

post '/delete/:filename/confirm' do |filename|
    db_file = $db.execute("SELECT * FROM files WHERE filename = '#{filename}';")
    debug("db_file", db_file)
    delete_password = params["deletepassword"]
    db_delete_password = db_file[0][9]

    #se il file esiste
    if File.exist?("./public/uploads/#{filename}") && !db_file[0].empty? && delete_password == db_delete_password
        # prima togli dal db, così se scazza almeno il frontend funziona
        # cerca la riga con quel nome file
        # TODO aggiungere più campi di ricerca (somma hash?, boh)
        #db_file = db.execute("SELECT * FROM files WHERE filename = '#{filename}';")
        # elimina la riga dal db
        $db.execute("DELETE FROM files WHERE Id = #{db_file[0][0]};")
        # elimina il file
        File.delete("./public/uploads/#{filename}")
    end
    redirect to ('/downloads') # vai ai downloads
end