$db = SQLite3::Database.new('db/braketz.db')
$db.results_as_hash = true
$pw = BCrypt::Password



# Returns all the info about a user
# @param [Integer] id, user id
def get_user_from_id(id)
    return $db.execute("SELECT * FROM users WHERE id = ?", id)[0]
end

# Returns the user id when given a username
#
# @param [String] username, the username of a user
def get_id_from_username(username)
    id = $db.execute("SELECT id FROM users WHERE username = ?", username)
    return id
end

# Returns the hashed password when given a username
#
# @param [String] username, the username of a user
def get_password_digest(username)
    return $db.execute("SELECT password_digest FROM users WHERE username = ?", username)[0]["password_digest"]
end

# Inserts content into user
# 
# @param [Array] content, the content that shall be inserted
#
def insert_in_db_user(table, column, content)
    $db.execute("
        INSERT INTO #{table} (#{column}) 
        VALUES (?, ?, ?, ?, ?)", content )
end


# Joins together an array into a string
#
# @param [Array] array, an array
#
def array_to_string(array)

    string = ""

    array.each do |a|
        string += a.to_s + ", "
    end

    return string[0...-2]

end


# Validates a registeration attempt
#
# @param [String] username, the wanted username
# @param [String] password, the entered password
# @param [String] confirm, the entered password again
#
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


# Validates a login attempt
#
# @param [String] username, the entered username
# @param [String] password, the entered password
#
def login_validation(username, password)
    if get_id_from_username(username) == []
        return error_message = "user does not exist"
    end
    password_digest = get_password_digest(username)
    p password_digest
    if $pw.new(password_digest) == password
        return true
    else
        return error_message = "password is incorrect"
    end
end

# Hashes a password
#
#
def digest_password(password)
    return $pw.create(password)
end

# Deletes a user from the data base
#
# @param [Integer] id, the id of the user who wishes to be deleted
#
def delete_user(id)
    $db.execute("DELETE FROM users WHERE id=?",id)
    ids = $db.execute("SELECT id FROM tournaments WHERE judge_id=?",id)
    if ids.length != 0
        ids.each do |id|
            $db.execute("DELETE FROM tour_user_relations WHERE tournament_id=?", id.first["id"])
        end
    end
    $db.execute("DELETE FROM tournaments WHERE judge_id=?",id)
    $db.execute("DELETE FROM tour_user_relations WHERE user_id=?",id)
    $db.execute("SELECT id FROM tournaments WHERE judge_id=?",id)
end

# Registers a Tournament
#
def register_tournament(name, players, admin)
    $db.execute("INSERT INTO tournaments (game, format, judge_id) VALUES(?, ?, ?)", name, "swiss", admin)
    id = $db.execute("SELECT id FROM tournaments WHERE game=?",name).first["id"]
    players = players.split(",")
    players_id = []

    players.each do |p|
        players_id << $db.execute("SELECT id FROM users WHERE username=?",p)[0]["id"]
    end
    players_id.each do |p|
        $db.execute("INSERT INTO tour_user_relations (user_id,tournament_id) VALUES(?, ?)", p, id)
    end 
    return(id)
end


# Returns an array of all the tournaments they participate(d) in
#
#
def get_tour_from_user(user_id)
    return $db.execute("SELECT tournament_id FROM tour_user_relations WHERE user_id=?", user_id)
end

# Returns all the users who participate in a specific tournament
def get_users_from_tour(tournament_id)
    return $db.execute("SELECT user_id FROM tour_user_relations WHERE tournament_id=?", tournament_id)
end

# Returns tournament name when given the id
def get_name_from_id(id)
    return $db.execute("SELECT game FROM tournaments WHERE id=?", id)
end

# Returns everything from a tournament when given the id
def get_tour_from_id(id)
    return $db.execute("SELECT * FROM tournaments WHERE id=?", id)
end

# Deletes a tournament
def delete_tournament(id)
    $db.execute("DELETE FROM tournaments WHERE id=?",id)
    $db.execute("DELETE FROM tour_user_relations WHERE tournament_id=?",id)
end

# Returns username from id
def username_from_id(id)
    $db.execute("SELECT username FROM users WHERE id=?", id)
end