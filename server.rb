require 'sinatra'
require 'json'
require 'sinatra/cross_origin'
require 'sinatra-websocket'

require_relative 'config.rb'
require_relative 'game_server.rb'
Dir["objects/*.rb"].each {|file| require_relative file }

server = GameServer.new
game = server.game
game_state = server.game_state

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
        message = JSON.parse(msg)

        action_name = message["action_name"]
        unless action_name.nil?
          game_target_method = game.method 'on_' + action_name
          action_data = message["action_data"]

          unless game_target_method.nil?
            game_target_method.call(action_data)
            settings.sockets.each{|s| s.send(game_state.changes.to_json)}
            game_state.clear_changes
          end
        end

        request_name = message["request_name"]
        unless request_name.nil?
          server_target_method = server.method 'on_' + request_name
          request_data = message["request_data"]

          unless server_target_method.nil?
            ws.send server_target_method.call(request_data).to_json
          end
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
	game_state.to_json
end

options '/register' do
  params.to_json
end

post '/register' do
  if @request_payload['email'].nil? || @request_payload['color'].nil?
    return {success: false}.to_json
  else
    player = game_state.create_player(@request_payload['email'], @request_payload['color'])
    session[:player] = player
    settings.sockets.each{|s| s.send(game_state.changes.to_json)}
    game_state.clear_changes
    return {success: true}.to_json
  end
end

get '/player' do
  content_type :json
  session[:player].to_json
end

get '/*' do
  redirect '/'
end
