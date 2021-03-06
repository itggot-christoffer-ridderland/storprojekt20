require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'byebug'
require_relative './model.rb'
enable :sessions

# Function that sets up essential hash
#
def setup()
    result_hash = {
    status: false,
    time: [],
    user_hash: nil
        }
        return result_hash
end

# Function that validates if a log-in attempt is valid
# @param [Array] time, array of the time stamps log-in attempts were commited
#
def time_checker(time)
    t = time.reverse

    if t.length >= 3
        value = t[0] * 2 - (t[1] + t[2])
    else
        value = 0
    end

    if value < 1
        true
    else
        false
    end


end

# before block to make sure logged out users stay logged out
#
#
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

# Display Landing page
#
#
get('/') do
    if session[:id] != nil
        if session[:user_hash]["profile_picture"] == nil
            session[:user_hash]["profile_picture"] = "http://img3.wikia.nocookie.net/__cb20130203110410/cswikia/images/0/0e/Phoenix_closeup.png"
        end 
    end
 
    slim(:index, locals:{user:session[:user_hash]})
end


#Makes a user log out
#
#
get('/logout') do
    session[:id] = nil
    hash = setup()
    session[:status] = hash[:status]
    session[:time] = hash[:time]
    session[:user_hash] = hash[:user_hash]
    redirect("/")
end

# Form for registering a user
#
#
#
get('/user/new') do
    slim(:"user/new", locals:{user:session[:user_hash]} )
end

# Registers a user
# @param [String] password, the chosen password
# @param [String] confirm, to make sure there are no typos in the password
# @param [String] username, the chosen username
# @param [Boolean] validation_result, True if the registration could be completed else False
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
        p "HELLOO"
        session[:error] = register_validation(username, password, confirm)
        redirect('/error')
    end
    redirect('/')
end


# Takes a user to the login site
#
#
get('/user/login') do
    
    slim(:"user/login",locals:{user:session[:user_hash]})
end


# Logs a user in
# @param [String] password, the entered password
# @param [String] username, the entered username
# @param [Array] Session[:time], array of the time stamps log-in attempts were commited
post('/user/login') do
    password = params[:password]
    username = params[:username]
    session[:time] << Time.now.to_i
    
    if login_validation(username, password) == true && time_checker(session[:time]) == true
        #session[:error] = "Login not allowed, try again in 60 seconds"
        session[:id] = get_id_from_username(username)[0]["id"]
        session[:user_hash] = get_user_from_id(session[:id])
        redirect('/')
    elsif time_checker(session[:time]) == false
        session[:error] = "Too many login attempts. Try again later"
        redirect('/error')
    else
        session[:error] = login_validation(username, password)
        redirect('/error')
    end
end

# Showes you profile
#
# @param [Integer] session[:id], the id of the user
# @param [Array] tournaments, all the tournaments the user is participating in
#
#
get('/user/show') do
    tournaments = get_tour_from_user(session[:id])
    ids = []
    tournaments.each do |t|
        ids << t["tournament_id"]
    end
    ids = ids.uniq
    names = []
    ids.each do |id|

    
        names << get_name_from_id(id)[0]["game"]
    end
    slim(:"user/show",locals:{user:session[:user_hash],ids:ids,names:names} )
end

# Takes a user to the page where you delete your account
#
#
get('/user/destroy') do
    slim(:"user/destroy",locals:{user:session[:user_hash]})
end

# Deletes account and logs out
#
# @param [Integer] session[:id], id of the user who wishes to be deleted
#
post('/user/destroy') do
    delete_user(session[:id])
    session[:id] = nil
    hash = setup()
    session[:status] = hash[:status]
    session[:time] = hash[:time]
    session[:user_hash] = hash[:user_hash]
    redirect("/")
end

# Shows a Tournament
#
# @param [integer] :id, the id of the tournament
#
# @param [Array] tournament, all the info about the tournament
#
# @users [Array] users, The users who participate in the tournament
#
get('/tournament/show/:id') do
    id = params[:id].to_i
    session[:tour_id] = id
    tournament = get_tour_from_id(id)
    users_id = []
    get_users_from_tour(id).each do |user|
        users_id << user["user_id"]
    end
    users=[]
    users_id.each do |user_id|
        p username_from_id(user_id)
        users << username_from_id(user_id)[0]["username"]
    end
    slim(:"tournament/show",locals:{user:session[:user_hash],id:session[:id], tournament:tournament, users:users})
end

# Deletes a tournament
#
# @param [Integer] id, tournament's id
#
post('/tournament/destroy') do
    id = session[:tour_id]
    delete_tournament(id)
    redirect("/")
end

# Deletes a Tournament
#
#
#
get('/tournament/destroy') do
    slim(:"/tournament/destroy", locals:{user:session[:user_hash]})
end

# Takes you to the error page and desplays an error message
#
#
get('/error') do
    p session[:error]
    slim(:error, locals:{user:session[:user_hash]})
end

# Form for creating a new tournament
#
#
get('/tournament/new') do
    slim(:"tournament/new", locals:{user:session[:user_hash]})
end

# Creates a new tournament
#
# @param [String] users, the users
# @param [String] name, the tournament's name
#
post('/tournament/create') do
    users = params[:users]
    name = params[:name]

    register_tournament(name, users, session[:user_hash]["id"] )
    
    #redirect('/tournament/show/#{id}')
    redirect('/user/show')
end

#get('/tournament/show/:id') do
#    id = params[:id].to_i
#    tournament_hash = get_tour_from_id(id)
#    p tournament_hash
#    slim(:"tournament/show", locals:{user:session[:user_hash],tournament:tournament_hash})
#end
