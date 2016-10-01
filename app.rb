#!/usr/bin/env ruby
#
# dbox

require 'json'
require 'base64'
require 'digest'
require 'securerandom'

require 'pp' # messaggi di debug

#---------------------
# IMPOSTAZIONI SINATRA
#---------------------



#--------------------
# divisione in moduli
#--------------------
# caricaggio dinamico
#--------------------
# carica dinamicamente le librerie all'interno della cartella ./lib
# lista i file e poi li richiama col require
# libs è un array, visto che li tira fuori con lib/libreria.rb
#ci aggiungo un ./ (poi magari alla fine non cambia un cazzo)
libs = Dir.glob(File.join("lib", "*.rb")).map {|file| "./#{file}"}
libs.each do |lib|
    require lib
end

#------------------------------
#
# Database SQLite al momento
#
# -----------------------------

$db = SQLite3::Database.open("database.db")

#------------------------------
# HTTP Login
#
# Ricordati di toglierlo quando
# va in produzione
#------------------------------
=begin
use Rack::Auth::Basic, "Login" do |username, password|
    username == "admin" and password == "mettipassword"
end
=end
#------------------------------

# index
get '/' do
    erb :index
end

# funzione dummy POST per postare messaggi - TODO
post '/message' do
    redirect to('/')
end

# se non sai dove andare (errore 404)
# redireziona all'index
# Non serve fare pagine che mostrano l'errore
# perché deve funzionare da captive portal
# ma si può ampliare nel caso
not_found do
    redirect to('/')
end
