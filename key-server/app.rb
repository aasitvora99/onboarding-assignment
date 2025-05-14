require 'sinatra'
require 'json'

set :bind, '0.0.0.0'
set :port, 4567

get '/' do
    content_type :json
    { message: 'Key Server is running' }.to_json
end