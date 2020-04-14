require 'sinatra'
require 'pg'
require 'sequel'
post '/updateviewcount' do
    uri = URI.parse(ENV['DATABASE_URL'])
    mydbconnection = PG.connect(uri.hostname, uri.port, nil, nil, uri.path[1..-1], uri.user, uri.password)
# increase viewcount by perpageitemsnumber
  mydeviceid = ""
  myviewcount = ""
   # mydbconnection = PG.connect :dbname => 'kwizto', :user => 'karan', :password => 'password1'
   queryresult = mydbconnection.exec 'SELECT device_id,view_count  FROM viewcount where device_id = \''+params['device_id']+'\''
    queryresult.each do |s_message|
    mydeviceid = s_message['device_id']
    myviewcount = s_message['view_count']
    end
    puts "mydeviceid"
    puts mydeviceid
    puts "myviewcount"
    puts myviewcount
    if mydeviceid == ""
        mydbquery = 'insert into viewcount (device_id,view_count) values (\''+params['device_id']+'\',5);'
    else
        if myviewcount.to_i > 3000
            mydbconnection.close if mydbconnection
            return "paynow"
        end    
        mydbquery = 'update viewcount set view_count = view_count + 5 where device_id = \''+params['device_id']+'\';' 
    end
    puts mydbquery
     mydbconnection.exec mydbquery
    mydbconnection.close if mydbconnection
    end
post '/cards' do
    uri = URI.parse(ENV['DATABASE_URL'])
    mydbconnection = PG.connect(uri.hostname, uri.port, nil, nil, uri.path[1..-1], uri.user, uri.password)
	# conection = PG.connect :dbname => 'kwizto', :user => 'karan', :password => 'password1'
	maxserialnum = 0
	# DB = Sequel.connect(ENV['DATABASE_URL'])
	queryresult = mydbconnection.exec 'SELECT max(serialnum) as maxserialnum FROM cards'
    queryresult.each do |s_message|
  	maxserialnum = s_message['maxserialnum']
	end
	puts "maxserialnum query results "+maxserialnum.to_s
	maxserialnum = maxserialnum.to_i + 1
	maxserialnum = maxserialnum.to_s
	if params["audiolink"] == nil
		params["audiolink"] = ''
	end	
    if params["frontImageurl"] == nil
        params["frontImageurl"] = ''
    end
    if params["backImageurl"] == nil
        params["backImageurl"] = ''
    end 
    if params["audiofiledurationseconds"] == nil
        params["audiofiledurationseconds"] = '20'
    end
    puts params
	frontquery = 'insert into cards (text,audiolink,serialnum,viewtype,frontimageurl,backimageurl,audiofiledurationseconds) values (\''+params["fronttext"]+'\',\''+params["audiolink"]+'\','+maxserialnum.to_s+',\'front\',\''+params["frontImageurl"]+'\',\'\','+params["audiofileDurationSeconds"]+');'
	backquery = 'insert into cards (text,audiolink,serialnum,viewtype,frontimageurl,backimageurl,audiofiledurationseconds) values (\''+params["backtext"]+'\',\''+params["audiolink"]+'\','+maxserialnum.to_s+',\'back\',\'\',\''+params["backImageurl"]+'\','+params["audiofileDurationSeconds"]+');'
	# frontquery=DB["insert into cards (text,audiolink,serialnum,viewtype) values (?,?,?,?)", params["fronttext"],params["audiolink"],maxserialnum,'front']
	# backquery=DB["insert into cards (text,audiolink,serialnum,viewtype) values (?,?,?,?)", params["backtext"],params["audiolink"],maxserialnum,'back']
	# frontquery.insert
	# backquery.insert
    puts frontquery
    puts backquery
    mydbconnection.exec frontquery
	mydbconnection.exec backquery
    mydbconnection.close if mydbconnection
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
    #if you change below then change in updateviewcount as well
    perpageitemsnumber = 5
    limit_number = perpageitemsnumber*2
    page_number = params["page_number"]
    page_number = page_number.to_i
    offsetval = limit_number*page_number
    offsetval = offsetval.to_s
    maxserialnum = ""
    uri = URI.parse(ENV['DATABASE_URL'])
    mydbconnection = PG.connect(uri.hostname, uri.port, nil, nil, uri.path[1..-1], uri.user, uri.password)
	 # mydbconnection = PG.connect :dbname => 'kwizto', :user => 'karan', :password => 'password1'
	queryresult = mydbconnection.exec 'SELECT max(serialnum) as maxserialnum FROM cards'
    
    queryresult.each do |s_message|
  	maxserialnum = s_message['maxserialnum']
	end
	json_string = "["
   
       # DB = Sequel.connect(ENV['DATABASE_URL']) 
       # DB = Sequel.connect(ENV['DATABASE_URL'])
# DB = Sequel.connect('postgres://postgres:password1@localhost/kwizto')

    t_messages = mydbconnection.exec 'SELECT * FROM cards order by serialnum,card_id limit '+limit_number.to_s+' offset '+offsetval
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
    	json_string += ','
        json_string += "\""
        json_string += "frontimageurl"
        json_string += "\""
        json_string += ":"
        json_string += "\""
        json_string += s_message['frontimageurl']
        json_string += "\""
        json_string += ','
        json_string += "\""
        json_string += "backimageurl"
        json_string += "\""
        json_string += ":"
        json_string += "\""
        json_string += s_message['backimageurl']
        json_string += "\""
        json_string += ','
    	json_string += "\""
    	json_string += "maxserialnum"
    	json_string += "\""
    	json_string += ":"
    	json_string += maxserialnum
         json_string += ','
        json_string += "\""
        json_string += "audiofileDurationSeconds"
        json_string += "\""
        json_string += ":"
        json_string += s_message['audiofiledurationseconds']
    	json_string += "},"
    	
    end
    json_string += "]"
 
  json_string.gsub! '},]', '}]'
  mydbconnection.close if mydbconnection
  json_string
  end