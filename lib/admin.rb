#!/usr/bin/env ruby
# interfaccia di amministrazione
##
### gente che amministra

# tiriamo fuori l'unico admin
utente = $db.execute("SELECT username, sha_password FROM amministratori LIMIT 1;");

set :username, utente[0][0]
set :token, "perilmomentousiamountokenstaticocheccazzo" #SecureRandom.uuid
set :password, utente[0][1]

helpers do
    def admin?
        request.cookies[settings.username] == settings.token
    end
    
    def protected!
        halt [ 401, 'FUORI DAI COGLIONI!' ] unless admin?
    end

end

get '/login' do # interfaccia di login
    if admin?
        redirect to('/admin')
    else
        erb :admin_login, layout: :admin_layout
    end
end

post '/login' do #form di login
    if params['username'] == settings.username && Digest::SHA256.hexdigest(params['password']) == settings.password
        response.set_cookie(settings.username, settings.token)
        redirect to('/admin')
    else
        erb :admin_failed, layout: :admin_layout
    end
end

get '/logout' do # logout
    response.set_cookie(settings.username, false)
    redirect to('/login')
end

get '/admin' do
    protected!
    erb :admin_panel, layout: :admin_layout
end

get '/admin/filelist' do
    protected!
    #tiriamo fuori tutti i file
    @files = $db.execute("SELECT * FROM files;");
    erb :admin_filelist, layout: :admin_layout
end

post '/admin/rescan' do
    rescan = Dir.glob("./public/uploads/*")
    # /!\ ATTENZIONE /!\
    # magari prima metti una modalità manutenzione
    # TODO: ci penserò
    
    # Query: pulisci la tabella files
    $db.execute("DELETE FROM files;")
    
    # E li rimettiamo con pw "test", perché sennò passa lo stronzo di turno che cancella tutto
    rescan.each do |rescan_file|
        # magari 'sta roba la sposto su qualche funzione
        filename = rescan_file.split("/").last
        path = rescan_file # per copiare e incollare la roba di sotto
        shadigest = Digest::SHA256.hexdigest(File.read(path))
        ippi = "localhost" # localhost perché rescanno
        delete_password = "rescannio" # magari la prossima volta farò qualcosa di random
        mimetype = File.mime(path).split[0] # mime
        metadata = analyze(path, mimetype)
        filesize = File.size(path)
    
        # metti nel db
        $db.execute("INSERT INTO files VALUES(NULL, '#{filename}', '#{path}', '#{shadigest}', '#{ippi}', '#{Time.now}', 0, NULL, NULL, '#{delete_password}', '#{mimetype}', '#{metadata}', #{filesize});")
    end
    
    redirect to('/admin/filelist')
end























