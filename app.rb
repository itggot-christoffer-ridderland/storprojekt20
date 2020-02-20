require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative './model.rb'
enable :sessions


def setup()
    result_hash = {
    status: false,
    time: []
        }
        return result_hash
end

def time_checker(session[:time])
    t = session[:time].reverse
    (t.length >= 3 ? value = t[1] * 2 - (t[2] + t[3)) : value = 0)
    (value < 30 ? true : false)
end

before do
    if session[:status] == nil
        session[:hash] = setup()
        session[:status] = hash[:status]
        session[:time] = hash[:time]
    end
end

get('/') do
    
    slim(:index, locals:{})
end

get('/register') do
    slim(:"user/register", locals:{} )
end

post('/create-account') do
    password = params[:password]
    confirm = params[:confirm_password]
    username = params[:username]
    validation_result = register_validation(username, password, confirm)
    if validation_result == true
        WRITE
    else
        session[:error] == validation_result
        redirect('/error')
    end
    redirect('/')
end

get('/login') do

    slim(login,locals:{})
end

post("/login") do
    password = params[:password]
    username = params[:username]
    
    if login_validation(username, password, $time) == true

    else
    
        redirect('/error')
    end
end

get('/error') do
    slim(:error)
end