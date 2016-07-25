#!/usr/bin/env ruby
#
# dbox

require 'json'
require 'base64'
require 'digest'

require 'pp' # messaggi di debug

#-------------------
# divisione in moduli
#-------------------
require './lib/download'

require './lib/info'
require './lib/info_audio'
require './lib/info_video'
require './lib/info_foto'

require './lib/delete'
require './lib/upload'
require './lib/helper'

require './lib/debug'

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
