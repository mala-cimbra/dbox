#!/usr/bin/env ruby
# interfaccia di amministrazione
##
require 'haml'

set :username,'Bond'
set :token,'shakenN0tstirr3d'
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
    haml :admin
end

post '/login' do
    if params['username'] == settings.username && params['password'] == settings.password
        response.set_cookie(settings.username, settings.token) 
        redirect_to('/')
    else
        "Username or Password incorrect"
    end
end

get '/logout' do
    response.set_cookie(settings.username, false)
    redirect_to('/')
end

get '/public' do
  'Anyone can see this'
end

get '/private' do
  protected!
  'For Your Eyes Only!'
end

__END__
@@layout
!!! 5
%html
  %head
    %meta(charset="utf-8")
    %title Really Simple Authentication
  %body
    %a(href='/admin')Login
    %a(href='/logout')Logout
    %a(href='/public')Public
    %a(href='/private')Private
    = yield
@@admin
%form(action="/login" method="post")
  %label(for="username")Username:
  %input#username(type="text" name="username")
  %label(for="password")Password:
  %input#password(type="password" name="password")
  %input(type="submit" value="Login") or <a href="/">Cancel</a>
@@index
-if admin?
  %h1 Welcome 007!
-else
  %h1 Welcome!