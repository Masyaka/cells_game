require 'sinatra'
require 'json'
require 'sinatra/cross_origin'
require 'sinatra-websocket'

require_relative 'config.rb'
Dir["objects/*.rb"].each {|file| require_relative file }

include CoordinateUtilities

global_state = GlobalState.new
cells = global_state.cells

NEUTRAL_COLOR = Cell.neutral_color

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
        warn("websocket closed")
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

	case direction
	when 'left'
		new_x = from_x - 1
		new_y = from_y
	when 'right'
		new_x = from_x + 1
		new_y = from_y
	when 'top'
		new_x = from_x
		new_y = from_y - 1
	when 'bottom'
		new_x = from_x
		new_y = from_y + 1
	else
		new_x = from_y
    new_y = from_x
	end

	player = global_state.players.find {|s| s.name == params[:player_name]}
  new_cell = Cell.new(x:new_x, y:new_y, fraction: player.fraction)

  prev_color = cells[new_cell.hash].nil? ? NEUTRAL_COLOR : cells[new_cell.hash].color

  cells << new_cell

  if prev_color != NEUTRAL_COLOR && prev_color != new_cell.color
    islands = cells.count_islands prev_color
    while islands.count > 1
      min_island = islands.min_by {|i| i[:cells_count]}
      cells.dfs(min_island[:root_y], min_island[:root_x], Hash.new,  prev_color) do |col, row|
        cells.delete cid(col, row)
      end
      islands.delete min_island
    end
  end

	settings.sockets.each{|s| s.send(cells.changes.to_json) }
  cells.changes.clear
	true
end
