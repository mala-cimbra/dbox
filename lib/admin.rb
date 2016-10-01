#!/usr/bin/env ruby
# interfaccia di amministrazione
##
### gente che amministra
set :username,'Bond'
set :token, SecureRandom.uuid
set :password,'007'

helpers do
    def admin?
        request.cookies[settings.username] == settings.token
    end
    
    def protected!
        halt [ 401, 'Not Authorized' ] unless admin?
    end

end

get '/admin' do
    if admin?
        erb :admin_panel, layout: :admin_layout
    else
        erb :admin_login, layout: :admin_layout
    end
end

post '/login' do
    if params['username'] == settings.username && params['password'] == settings.password
        response.set_cookie(settings.username, settings.token) 
        redirect to('/admin')
    else
        erb :admin_failed, layout: :admin_layout
    end
end

get '/logout' do
    response.set_cookie(settings.username, false)
    redirect to('/admin')
end
