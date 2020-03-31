require 'sinatra'
require 'pg'
require 'sequel'
post '/cards' do
	puts params
	end
get '/' do
	json_string = "["
    # conection = PG.connect :dbname => 'kwizto', :user => 'karan', :password => 'password1'
       # DB = Sequel.connect(ENV['DATABASE_URL']) 
       DB = Sequel.connect(ENV['DATABASE_URL'])
# DB = Sequel.connect('postgres://postgres:password1@localhost/kwizto')

    # t_messages = conection.exec 'SELECT * FROM cards'
    # t_messages.each do |s_message|
    puts "------------------------------------loop"
    DB.fetch("SELECT * FROM cards") do |s_message|
    	puts s_message
    	json_string += "{"
    	json_string += "\""
    	json_string += "text"
    	json_string += "\""
    	json_string += ":"
    	json_string += "\""
    	json_string += s_message[:text]
    	json_string += "\""
    	json_string += ','
    	json_string += "\""
    	json_string += "serialnum"
    	json_string += "\""
    	json_string += ":"
    	json_string += s_message[:serialnum].to_s
    	json_string += ','
    	json_string += "\""
    	json_string += "viewtype"
    	json_string += "\""
    	json_string += ":"
    	json_string += "\""
    	json_string += s_message[:viewtype]
    	json_string += "\""
    	json_string += "},"
    	puts "------------------------"
    	puts s_message['text']
    	puts "------------------------"
    end
    json_string += "]"
 
  json_string.gsub! '},]', '}]'
  json_string
  end