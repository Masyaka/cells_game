class GameServer
  attr_reader :game, :game_state

  def initialize
    @game = CellsGame.new
    @game_state = @game.game_state
  end

  def on_request_state (opts = {})
    {
      cells_created: @game_state.cells,
      players_created: @game_state.players,
      fractions_created: @game_state.fractions
    }
  end
end