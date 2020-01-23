require 'sinatra'
require 'slim'
require_relative 'db.rb'
require_relative 'password.rb'

enable :sessions

def setup()
    session[:status] = false
    
end

def login()
    session[:staus] = true
end