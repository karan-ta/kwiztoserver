require 'sinatra'
require 'pg'
require 'sequel'
# mydbconnection = PG.connect :dbname => 'kwizto', :user => 'karan', :password => 'password1'
# device pagenumber is to know current page
# viewcount is used for payment
post '/updateviewcount' do
    uri = URI.parse(ENV['DATABASE_URL'])
    mydbconnection = PG.connect(uri.hostname, uri.port, nil, nil, uri.path[1..-1], uri.user, uri.password)
    mydeviceid = ""
    myviewcount = ""
    mypage_number = ""
    queryresult = mydbconnection.exec 'SELECT device_id,page_number  FROM device_pagenumber where device_id = \''+params['device_id']+'\';'
    queryresult.each do |s_message|
    mypage_number = s_message['page_number']
    end
    puts "page number print"
    puts mypage_number
    if mypage_number == ""
    mydevicepagenumquery = 'insert into device_pagenumber (device_id,page_number) values (\''+params['device_id']+'\',1);'
    mydbconnection.exec mydevicepagenumquery
    else
    mydevicepagenumquery = 'update device_pagenumber set page_number = '+params["page_number"]+' where device_id = \''+params['device_id']+'\';' 
    mydbconnection.exec mydevicepagenumquery
    end
    queryresult = mydbconnection.exec 'SELECT device_id,view_count  FROM viewcount where device_id = \''+params['device_id']+'\''
    queryresult.each do |s_message|
    mydeviceid = s_message['device_id']
    myviewcount = s_message['view_count']
    end
    if mydeviceid == ""
        mydbquery = 'insert into viewcount (device_id,view_count) values (\''+params['device_id']+'\',5);'
        mydbconnection.exec mydbquery
    else
         if myviewcount.to_i > 500
            return "paynow"
         end   
        # increase viewcount by perpageitemsnumber
        mydbquery = 'update viewcount set view_count = view_count + 5 where device_id = \''+params['device_id']+'\';' 
        mydbconnection.exec mydbquery
    end
    mydbconnection.close if mydbconnection
    end
post '/createdeck' do
    uri = URI.parse(ENV['DATABASE_URL'])
    mydbconnection = PG.connect(uri.hostname, uri.port, nil, nil, uri.path[1..-1], uri.user, uri.password)
    puts params['deck_name']
    mycreatedeckquery = 'insert into deck (deck_name) values (\''+params['deck_name']+'\');'
    mydbconnection.exec mycreatedeckquery
end
get '/decks' do
 json_string = "["
 uri = URI.parse(ENV['DATABASE_URL'])
 mydbconnection = PG.connect(uri.hostname, uri.port, nil, nil, uri.path[1..-1], uri.user, uri.password)
 t_messages = mydbconnection.exec 'SELECT * FROM deck;'
    t_messages.each do |s_message|
    # puts "------------------------------------loop"
    # DB.fetch("SELECT * FROM cards") do |s_message|
        # puts s_message
        json_string += "{"
         json_string += "\""
        json_string += "deck_id"
        json_string += "\""
        json_string += ":"
         json_string += s_message['deck_id']
        json_string += ",\""
        json_string += "deck_name"
        json_string += "\""
        json_string += ":"
        json_string += "\""
        json_string += s_message['deck_name']
        json_string += "\""
        json_string += "},"
    end
     json_string += "]"
     json_string.gsub! '},]', '}]'
     mydbconnection.close if mydbconnection
     json_string
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
	frontquery = 'insert into cards (text,audiolink,serialnum,viewtype,frontimageurl,backimageurl,audiofiledurationseconds,deck_id) values (\''+params["fronttext"]+'\',\''+params["audiolink"]+'\','+maxserialnum.to_s+',\'front\',\''+params["frontImageurl"]+'\',\'\','+params["audiofiledurationseconds"]+',\''+params["deck_id"]+'\');'
	backquery = 'insert into cards (text,audiolink,serialnum,viewtype,frontimageurl,backimageurl,audiofiledurationseconds,deck_id) values (\''+params["backtext"]+'\',\''+params["audiolink"]+'\','+maxserialnum.to_s+',\'back\',\'\',\''+params["backImageurl"]+'\','+params["audiofiledurationseconds"]+',\''+params["deck_id"]+'\');'
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

get '/testimage' do
redirect('captchaimages/mygstcropped.png')
end

get '/testjar' do
system("java -jar Testjar.jar KODE_PLAY Kodeplay@08")
#sinatra will search in public folder by default.
redirect('captchaimages/mygstcropped.png')
end    

get '/' do
    #if you change below then change in updateviewcount as well
    perpageitemsnumber = 5
    limit_number = perpageitemsnumber*2
    page_number = params["page_number"]
    page_number = page_number.to_i
    
    mydevicepagenum = ""
    maxserialnum = ""
    totalpages=""
    uri = URI.parse(ENV['DATABASE_URL'])
    mydbconnection = PG.connect(uri.hostname, uri.port, nil, nil, uri.path[1..-1], uri.user, uri.password)
	 # mydbconnection = PG.connect :dbname => 'kwizto', :user => 'karan', :password => 'password1'
	#user is loading a new session so page number is 0
    totalpagesqueryresult = mydbconnection.exec 'SELECT count(*) as count from cards'
    totalpagesqueryresult.each do |s_message|
    totalpages = s_message['count']
    totalpages = totalpages.to_i
    totalpages = totalpages/2
    totalpages = (totalpages.to_f/perpageitemsnumber).ceil

    end
  
    if params["getmode"] == "load"
     mydevicepagenumresult = mydbconnection.exec 'SELECT page_number from device_pagenumber where device_id = \''+params['device_id']+'\';'
     mydevicepagenumresult.each do |s_message|
    if s_message['page_number'] == ""
        print "no entry in device_pagenumber for "+params['device_id']
    else
        page_number = s_message['page_number']
        page_number = page_number.to_i
       end
            end
            # do ends
    end
   
      if (page_number + 1) > totalpages
        page_number = (page_number+1)%(totalpages+1)
    end
    offsetval = limit_number*page_number
     puts "LOG:"
    puts totalpages 
    puts page_number
    puts "LOG ENDS:"
    queryresult = mydbconnection.exec 'SELECT max(serialnum) as maxserialnum FROM cards'
    queryresult.each do |s_message|
  	maxserialnum = s_message['maxserialnum']
	end
    offsetval = offsetval.to_s
    json_string = "["
       # DB = Sequel.connect(ENV['DATABASE_URL']) 
       # DB = Sequel.connect(ENV['DATABASE_URL'])
# DB = Sequel.connect('postgres://postgres:password1@localhost/kwizto')
    t_messages = mydbconnection.exec 'SELECT * FROM cards where deck_id = '+params["deck_id"]+' order by serialnum,card_id limit '+limit_number.to_s+' offset '+offsetval
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
        json_string += "page_number"
        json_string += "\""
        json_string += ":"
        json_string += page_number.to_s
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
  print json_string
  mydbconnection.close if mydbconnection
  json_string
  end