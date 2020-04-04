require 'sinatra'
require 'pg'
require 'sequel'
post '/cards' do
	# conection = PG.connect :dbname => 'kwizto', :user => 'karan', :password => 'password1'
	maxserialnum = 0
	DB = Sequel.connect(ENV['DATABASE_URL'])
	DB.fetch("SELECT max(serialnum) as maxserialnum FROM cards")  do |row|
  	maxserialnum = row[:maxserialnum]
	end
	puts "maxserialnum query result "+maxserialnum.to_s
	maxserialnum = maxserialnum.to_i + 1
	maxserialnum = maxserialnum.to_s
	if params["audiolink"] == nil
		params["audiolink"] = ''
	end	
	# frontquery = 'insert into cards (text,audiolink,serialnum,viewtype) values (\''+params["fronttext"]+'\',\''+params["audiolink"]+'\','+maxserialnum.to_s+',\'front\');'
	# backquery = 'insert into cards (text,audiolink,serialnum,viewtype) values (\''+params["backtext"]+'\',\''+params["audiolink"]+'\','+maxserialnum.to_s+',\'back\');'
	frontquery=DB["insert into cards (text,audiolink,serialnum,viewtype) values (?,?,?,?)", params["fronttext"],params["audiolink"],maxserialnum,'front']
	backquery=DB["insert into cards (text,audiolink,serialnum,viewtype) values (?,?,?,?)", params["backtext"],params["audiolink"],maxserialnum,'back']
	frontquery.insert
	backquery.insert
	# conection.exec frontquery
	# conection.exec backquery
	end

get '/test' do
    uri = URI.parse(ENV['DATABASE_URL'])
    mydbconnection = PG.connect(uri.hostname, uri.port, nil, nil, uri.path[1..-1], uri.user, uri.password)
    t_messages = mydbconnection.exec 'SELECT * FROM cards'
    t_messages.each do |s_message|
        puts s_message.to_s
    end
    mydbconnection.close if mydbconnection
    end

get '/' do
    uri = URI.parse(ENV['DATABASE_URL'])
    mydbconnection = PG.connect(uri.hostname, uri.port, nil, nil, uri.path[1..-1], uri.user, uri.password)
	json_string = "["
    # conection = PG.connect :dbname => 'kwizto', :user => 'karan', :password => 'password1'
       # DB = Sequel.connect(ENV['DATABASE_URL']) 
       # DB = Sequel.connect(ENV['DATABASE_URL'])
# DB = Sequel.connect('postgres://postgres:password1@localhost/kwizto')

    t_messages = mydbconnection.exec 'SELECT * FROM cards'
    t_messages.each do |s_message|
    # puts "------------------------------------loop"
    # DB.fetch("SELECT * FROM cards") do |s_message|
    	# puts s_message
    	json_string += "{"
    	json_string += "\""
    	json_string += "text"
    	json_string += "\""
    	json_string += ":"
    	json_string += "\""
    	json_string += s_message['text']
    	json_string += "\""
    	json_string += ','
    	json_string += "\""
    	json_string += "serialnum"
    	json_string += "\""
    	json_string += ":"
    	json_string += s_message['serialnum'].to_s
    	json_string += ','
    	json_string += "\""
    	json_string += "viewtype"
    	json_string += "\""
    	json_string += ":"
    	json_string += "\""
    	json_string += s_message['viewtype']
    	json_string += "\""
    	json_string += ','
    	json_string += "\""
    	json_string += "audiolink"
    	json_string += "\""
    	json_string += ":"
    	json_string += "\""
    	json_string += s_message['audiolink']
    	json_string += "\""
    	json_string += "},"
    	
    end
    json_string += "]"
 
  json_string.gsub! '},]', '}]'
  mydbconnection.close if mydbconnection
  json_string
  end