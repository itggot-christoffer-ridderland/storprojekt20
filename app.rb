require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
enable :sessions

$db = SQLite3::Database.new('db/braketz.db')
$db.results_as_hash = true
def setup()
    result_hash={
    status: false,
    time: []
        }
end



def register_validation(username, password, confirm)
    if $db.execute("SELECT id FROM users WHERE username=?", username) != []
        session[:error] = "user already exists"
        return false
    elsif password != confirm
        session[:error] = "passwords do not match"
        return false
    elsif password.length < 6
        session[:error] = "password must not be shorter than six characters"
        return false
    elsif username.length < 4
        session[:error] = "username must not be shorter than four characters"
        return false
    elsif password =~ (/\s/) || username =~ (/\s/)
        session[:error] = "password must not contain blankspace"
        return false
    else
        return true
    end
end

def login_validation(username, password)

end

before do
    if session[:status] == nil
        hash = setup()
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
    if register_validation(username, password, confirm) == true

        password_digest = BCrypt::Password.create(params[:password])
        $db.execute("INSERT INTO users (username, password_digest, points, admin) VALUES (?, ?, ?, ?)", [username, password_digest, 0, (username == "admin" ? 1 : 0)])
    else
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

        password_digest = BCrypt::Password.create(params[:password])
        $db.execute("INSERT INTO users (username, password_digest, points, admin) VALUES (?, ?, ?, ?)", [username, password_digest, 0, (username == "admin" ? 1 : 0)])
    else
        redirect('/error')
    end
end

get('/error') do
    slim(:error)
end