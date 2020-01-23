require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
enable :sessions

def setup()
    session[:status] == false
end

get('/') do
    if session[:status] == nil
        setup()
    end
    slim(:index, locals:{})
end