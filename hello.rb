require 'sinatra'
require 'pg'
require 'sequel'
post '/cards' do
	# conection = PG.connect :dbname => 'kwizto', :user => 'karan', :password => 'password1'
	DB = Sequel.connect(ENV['DATABASE_URL'])
	DB.fetch("SELECT max(serialnum) FROM cards as maxserialnum")  do |row|
  	maxserialnum = row[:maxserialnum]
	end
	maxserialnum = maxserialnum.to_i + 1
	maxserialnum = maxserialnum.to_s
	if params["audiolink"] == nil
		params["audiolink"] = ''
	end	
	# frontquery = 'insert into cards (text,audiolink,serialnum,viewtype) values (\''+params["fronttext"]+'\',\''+params["audiolink"]+'\','+maxserialnum.to_s+',\'front\');'
	# backquery = 'insert into cards (text,audiolink,serialnum,viewtype) values (\''+params["backtext"]+'\',\''+params["audiolink"]+'\','+maxserialnum.to_s+',\'back\');'
	frontquery=DB["insert into cards (text,audiolink,serialnum,viewtype) values (?,?,?,?)", params["fronttext"],params["audiolink"],maxserialnum,'front']
	backquery=DB["insert into cards (text,audiolink,serialnum,viewtype) values (?,?,?,?)", params["fronttext"],params["audiolink"],maxserialnum,'back']
	frontquery.insert
	backquery.insert
	# conection.exec frontquery
	# conection.exec backquery
	end

get '/' do
	json_string = "["
    # conection = PG.connect :dbname => 'kwizto', :user => 'karan', :password => 'password1'
       # DB = Sequel.connect(ENV['DATABASE_URL']) 
       DB = Sequel.connect(ENV['DATABASE_URL'])
# DB = Sequel.connect('postgres://postgres:password1@localhost/kwizto')

    # t_messages = conection.exec 'SELECT * FROM cards'
    # t_messages.each do |s_message|
    # puts "------------------------------------loop"
    DB.fetch("SELECT * FROM cards") do |s_message|
    	# puts s_message
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
    	
    end
    json_string += "]"
 
  json_string.gsub! '},]', '}]'
  json_string
  end