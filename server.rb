require 'sinatra'
require 'json'
require 'sinatra/cross_origin'
require 'sinatra-websocket'

require_relative 'config.rb'
Dir["objects/*.rb"].each {|file| require_relative file }

include CoordinateUtilities

global_state = GlobalState.new
cells = global_state.cells

get '/' do
  if !request.websocket?
    File.read(File.join('public', 'index.html'))
  else
    request.websocket do |ws|
      ws.onopen do
        settings.sockets << ws
      end
      ws.onmessage do |msg|

      end
      ws.onclose do
        warn('websocket closed')
        settings.sockets.delete(ws)
      end
    end
  end
end

get '/cells' do
	content_type :json
	response = global_state.to_json
	response
end

post '/move' do
	from_x = params[:from_x].to_i
	from_y = params[:from_y].to_i
	direction = params[:direction] # left/right/top/bottom
  player = global_state.players.find {|s| s.name == params[:player_name]}

  cells.move from_x, from_y, direction, player

	settings.sockets.each{|s| s.send(cells.changes.to_json)}
  cells.changes.clear
	true
end
