$db = SQLite3::Database.new('db/braketz.db')
$db.results_as_hash = true
$pw = BCrypt::Password



#DATABASE FUNCTIONS
def select_from_db(table, column)

end

def inner_join(table1, table2, column)
end

def insert_in_db_user(table, column, content)
    #byebug
    $db.execute("
        INSERT INTO #{table} (#{column}) 
        VALUES (?, ?, ?, ?, ?)", content )

end

def array_to_string(array)

    string = ""

    array.each do |a|
        string += a.to_s + ", "
    end

    return string[0...-2]

end


#VALIDATION FUNCTIONS
def register_validation(username, password, confirm)
    if $db.execute("SELECT id FROM users WHERE username=?", username) != []
        return error_message = "user already exists"
    elsif password != confirm
        return error_message = "passwords do not match"
    elsif password.length < 6
        return error_message = "password must not be shorter than six characters"
    elsif username.length < 4
        return error_message = "username must not be shorter than four characters"
    elsif password =~ (/\s/) || username =~ (/\s/)
        return error_message = "password and username must not contain blankspace"
    else
        return true
    end
end

def login_validation(username, password)

end

#USER FUNCTIONS

def digest_password(password)
    return $pw.create(password)
end


#TOURNAMENT FUNCTIONS


