require 'rubygems'
require 'sinatra'



get '/' do
  content_type :json
    { :key1 => 'values1', :key2 => 'values2' }.to_json
end