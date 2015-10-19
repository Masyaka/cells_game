class CellsGame
  require_relative 'game_state'
  include CoordinateUtilities

  attr_accessor :game_state, :cells

  def initialize
    @game_state = GameState.new
    @cells = game_state.cells
  end

  # @param [Hash] data
  def on_move(data)
    from_x = data['from_x'].to_i
    from_y = data['from_y'].to_i
    direction = data['direction'] # left/right/top/bottom
    player = game_state.players.find {|s| s.color == data["player_name"]}

    cells.move from_x, from_y, direction, player unless player.nil?
  end
end