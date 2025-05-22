require 'sinatra'
require 'json'
require_relative './lib/key_store'

STORE = KeyStore.new

Thread.new do
  loop do
    sleep 10
    STORE.release_stale_blocked_keys
    STORE.purge_expired_keys
  end
end

before do
  content_type :json
end

# Health check
get '/' do
  { message: 'API is running' }.to_json
end

post '/generate_key' do
  key = STORE.generate_key
  { key: key }.to_json
end

get '/key' do
  key = STORE.get_available_key
  if key
    { key: key }.to_json
  else
    status 404
    { error: 'No available key' }.to_json
  end
end

post '/unblock_key/:key' do
  if STORE.unblock_key(params[:key])
    { message: 'Key unblocked', key: params[:key] }.to_json
  else
    status 400
    { error: 'Key not found or not blocked' }.to_json
  end
end

delete '/key/:key' do
  if STORE.exists?(params[:key])
    STORE.delete_key(params[:key])
    { message: 'Key deleted' }.to_json
  else
    status 404
    { error: 'Key not found' }.to_json
  end
end

post '/keep_alive/:key' do
  if STORE.keep_alive(params[:key])
    { message: 'Keep-alive successful', key: params[:key] }.to_json
  else
    status 404
    { error: 'Key not found' }.to_json
  end
end