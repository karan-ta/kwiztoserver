require 'sinatra'
require 'pg'
get '/' do
	json_string = "["
  begin
    # conection = PG.connect :dbname => 'kwizto', :user => 'karan', :password => 'password1'
        conection = PG.connect :dbname => <%= ENV['DATABASE_NAME']%>, :user => <%=ENV['DATABASE_USER']%>, :password => <%=ENV['DATABASE_PASSWORD']%>
    t_messages = conection.exec 'SELECT * FROM cards'
    t_messages.each do |s_message|
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
    	json_string += s_message['serialnum']
    	json_string += ','
    	json_string += "\""
    	json_string += "viewtype"
    	json_string += "\""
    	json_string += ":"
    	json_string += "\""
    	json_string += s_message['viewtype']
    	json_string += "\""
    	json_string += "},"
    	puts "------------------------"
    	puts s_message['text']
    	puts "------------------------"
    end
    json_string += "]"
  rescue PG::Error => e
    val_error = e.message 
  ensure
    conection.close if conection
  end
  json_string.gsub! '},]', '}]'
  json_string
  end