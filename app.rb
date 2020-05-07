require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'byebug'
require_relative './model.rb'
enable :sessions


def setup()
    result_hash = {
    status: false,
    time: [],
    user_hash: nil
        }
        return result_hash
end


def time_checker(time)
    t = time.reverse

    if t.length >= 3
        value = t[1] * 2 - (t[2] + t[3])
    else
        value = 0
    end

    if value < 30
        true
    else
        false
    end


end

before do
    if session[:status] == nil
        hash = setup()
        session[:status] = hash[:status]
        session[:time] = hash[:time]
        session[:user_hash] = hash[:user_hash]
        redirect("/")
    end
    if session[:status] != true && session[:id] != []
        session[:status] = true
    end
end

get('/') do
    if session[:id] != nil
        if session[:user_hash]["profile_picture"] == nil
            session[:user_hash]["profile_picture"] = "http://img3.wikia.nocookie.net/__cb20130203110410/cswikia/images/0/0e/Phoenix_closeup.png"
        end 
    end
 
    slim(:index, locals:{user:session[:user_hash]})
end


get('/user/new') do
    slim(:"user/new", locals:{user:session[:user_hash]} )
end

post('/user/create') do
    password = params[:password]
    confirm = params[:confirm_password]
    username = params[:username]
    
    validation_result = register_validation(username, password, confirm)
    
    if validation_result == true
        
        columns=["username", "password_digest", "points", "admin", "profile_picture"]
        columns=array_to_string(columns)
        content=[username, digest_password(password), 0, 0, nil]
        #content=array_to_string(content)
        insert_in_db_user("users", columns, content)
    else
        session[:error] == validation_result
        redirect('/error')
    end
    redirect('/')
end

get('/user/login') do
    
    slim(:"user/login",locals:{user:session[:user_hash]})
end

post('/user/login') do
    password = params[:password]
    username = params[:username]
    session[:time] << Time.now.to_i
    
    if login_validation(username, password) == true && time_checker(session[:time]) == true
        session[:id] = get_id_from_username(username)[0]["id"]
        session[:user_hash] = get_user_from_id(session[:id])
        redirect('/')
    else
        session[:error] = error_message
        redirect('/error')
    end
end


get('/error') do
    slim(:error, locals:{user:session[:user_hash]})
end

get('/tournament/new') do
    slim(:"tournament/new", locals:{user:session[:user_hash]})
end

post('tournament/create') do
    
end

#get('/*') do
#    session[:error] = "404 page not found"
#    redirect('/error')
#end