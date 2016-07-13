#!/usr/bin/env ruby

require './lib/info_audio'
require './lib/info_video'
require './lib/info_foto'

# info sul file
get '/info/:filename/detail' do |filename|
    @db_file = $db.execute("SELECT * FROM files WHERE filename = '#{filename}';")
    
    debug("db_file", @db_file)
    debug("empty?", @db_file.empty?)
    
    if !@db_file.empty? && File.exist?(@db_file[0][2])
        
        @data = info_audio(@db_file[0][1], @db_file[0][2], @db_file[0][10])
        erb :info
    else
        redirect to ('/downloads') # vai ai downloads
    end
end
