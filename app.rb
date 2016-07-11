#!/usr/bin/env ruby
#
# dbox

require 'sinatra'
require 'tilt/erubis'
require 'sqlite3'
require 'json'
require 'base64'
require 'digest'
require 'pp' # messaggi di debug

def debug(descrizione, text)
  puts "--------------DEBUG--------------"
  puts descrizione
  puts "--"
  pp text
  puts "---------------------------------"
end

#-----------------------------
#
# Settaggi per Sinatra
#
#----------------------------

set :server, %w[thin webrick]
set :bind, '0.0.0.0'
set :port, 8080

#------------------------------
#
# Database SQLite al momento
#
# -----------------------------

db = SQLite3::Database.open("database.db")

#------------------------------
# HTTP Login
#
# Ricordati di toglierlo quando
# va in produzione
#------------------------------

use Rack::Auth::Basic, "Login" do |username, password|
    username == "admin" and password == "mettipassword"
end

#------------------------------

# index
get '/' do
    erb :index
end

# funzione dummy POST per postare messaggi - TODO
post '/message' do

end

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
    @list = db.execute("SELECT filename FROM files;").flatten
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
        dl_count = db.execute("SELECT dl_number from files WHERE filename = '#{filename}';")
        debug("conteggio download, query", dl_count)
        new_dl_count = dl_count.flatten[0].to_i + 1 # lo flatta per il discorso sopra e aggiunge 1
        # aggiorna il db, sql a nastro
        db.execute("UPDATE files SET dl_number=#{new_dl_count}, last_dl_ip='#{request.ip}', last_dl_date='#{Time.now}' WHERE filename='#{filename}';")
        # spedisce il file
        send_file("./public/uploads/#{filename}", :filename => filename, :disposition => :attachment, :type => 'application/octet-stream')
    else
        # altrimenti torna indrio ai download
        redirect to('/downloads')
    end
end

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
        shadigest = Digest::SHA256.hexdigest(File.read(path)) # calcola sommahash
        delete_password = params['password'] # tirami fuori la password
        # aggiungi la cosa al db
        db.execute("INSERT INTO files VALUES(NULL, '#{filename}', '#{path}', '#{shadigest}', '#{request.ip}', '#{Time.now}', 0, NULL, NULL, '#{delete_password}');")
    end
    redirect to('/downloads') # mostrami poi quello che hai buttato su
end

# funzione di eliminazione
# TODO da debuggare pesantemente
# devo pensarla bene
get '/delete/:filename/confirm' do |filename|
  file_row = db.execute("SELECT * FROM files WHERE filename='#{filename}';")
  debug("file_row", file_row)
  @filename = filename
  erb :delete
end

post '/delete/:filename/confirm' do |filename|
  db_file = db.execute("SELECT * FROM files WHERE filename = '#{filename}';")
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
      db.execute("DELETE FROM files WHERE Id = #{db_file[0][0]};")
      # elimina il file
      File.delete("./public/uploads/#{filename}")
      redirect to ('/downloads') # vai ai downloads
  else
      redirect to ('/downloads') # vai ai downloads
  end
end

# se non sai dove andare
# (errore 404)
# redireziona all'index
# Non serve fare pagine che mostrano l'errore
# perché deve funzionare da captive portal
# ma si può ampliare nel caso
not_found do
    redirect to('/')
end
