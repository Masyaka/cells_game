require 'sinatra'
require 'json'
require 'sinatra/cross_origin'
require 'sinatra-websocket'

require_relative 'config.rb'
Dir["objects/*.rb"].each {|file| require_relative file }

game = CellsGame.new
game_state = game.game_state

before do
  if env['REQUEST_METHOD'] == 'POST' && env['CONTENT_TYPE'] == 'application/json'
    request.body.rewind
    @request_payload = JSON.parse request.body.read
  end
end

get '/' do
  if !request.websocket?
    File.read(File.join('public', 'index.html'))
  else
    request.websocket do |ws|
      ws.onopen do
        settings.sockets << ws
      end

      ws.onmessage do |msg|
        event_message = JSON.parse(msg)
        event_name = event_message["eventName"]
        target_method = game.method 'on_' + event_name
        data = event_message["data"]

        unless target_method.nil?
          target_method.call(data)
          settings.sockets.each{|s| s.send(game_state.changes.to_json)}
          game_state.clear_changes
        end
      end

      ws.onclose do
        warn('websocket closed')
        settings.sockets.delete(ws)
      end
    end
  end
end

get '/state' do
	content_type :json
	response = game_state.to_json
	response
end

options '/register' do
  params.to_json
end

post '/register' do
  if @request_payload['email'].nil?
    return {success: false}.to_json
  else
    player = Player.new(email: @request_payload['email'])
    session[:player] = player
    game_state.players << player
    return {success: true}.to_json
  end
end

get '/player' do
  content_type :json
  session[:player]
end

get '/*' do
  redirect '/'
end
