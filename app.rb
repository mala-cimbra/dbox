#!/usr/bin/env ruby
#
# dbox

require 'sinatra'
require 'tilt/erubis'
require 'sqlite3'
require 'json'
require 'base64'
require 'digest'

set :server, %w[thin webrick]
set :bind, '0.0.0.0'
set :port, 8080

#------------------------------
db = SQLite3::Database.open("database.db")

#------------------------------
# Ricordati di toglierlo quando
# va in produzione
#------------------------------

use Rack::Auth::Basic, "Login" do |username, password|
    username == "admin" and password == "mettipassword"
end

#------------------------------

get '/' do
    erb :index
end

post '/message' do

end

get '/downloads' do
    @list = db.execute("SELECT filename FROM files;").flatten
=begin
    @list = Dir.glob("./public/uploads/*.*").map do |file|
        file.split('/').last
    end
=end
    erb :downloads
end

get '/downloads/:filename' do |filename|
    if File.exist?("./public/uploads/#{filename}")
        send_file("./public/uploads/#{filename}", :filename => filename, :disposition => :attachment, :type => 'application/octet-stream')
    else
        redirect to('/downloads')
    end
end

get '/upload' do
    erb :upload
end

post '/upload' do
    if params['file'] == nil || params['file'] == "" || File.exist?("./public/uploads/#{params['file'][:filename]}")
        redirect to('/upload')
    else
        tempfile = params['file'][:tempfile]
        filename = params['file'][:filename]
        path = "./public/uploads/#{filename}"
        File.open(path, "wb") do |f|
            f.write(tempfile.read)
        end
        shadigest = Digest::SHA256.hexdigest(File.read(path))
        delete_password = params['password']
        db.execute("INSERT INTO files VALUES(NULL, '#{filename}', '#{path}', '#{shadigest}', '#{request.ip}', '#{Time.now}', 0, NULL, NULL, '#{delete_password}' )")
    end
    redirect to('/downloads')
end

get '/delete/:filename' do |filename|
    if File.exist?("./public/uploads/#{filename}")
        db_file = db.execute("SELECT * FROM files where filename = '#{filename}'")
        db.execute("DELETE FROM files WHERE Id = #{db_file[0][0]}")
        File.delete("./public/uploads/#{filename}")
        redirect to ('/downloads')
    else
        redirect to ('/downloads')
    end
end

not_found do
    redirect to('/')
end
