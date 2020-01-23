require_relative 'db.rb'
require_relative 'password.rb'
require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

get('/') do

    slim(:index, locals:{})
end