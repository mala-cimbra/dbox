#!/usr/bin/env ruby

# info sul file
get '/info/:filename/detail' do |filename|
    @db_file = $db.execute("SELECT * FROM files WHERE filename = '#{filename}';")
    debug("db_file", @db_file)
    if File.exist?(@db_file[0][2]) && !@db_file[0].empty?
        @arr_data = Array.new
        TagLib::FileRef.open(@db_file[0][2]) do |audio|
            tag = audio.tag
            prop = audio.audio_properties
            string_durata = "#{prop.length / 60}:#{prop.length % 60}"
            @arr_data << tag.artist << tag.title << tag.album << string_durata << prop.bitrate
        end
        erb :info
    else
        redirect to ('/downloads') # vai ai downloads
    end
end
