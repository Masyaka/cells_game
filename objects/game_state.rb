class GameState < GameObject
  require_relative 'game_map'
  require_relative 'fraction'
  require_relative 'player'
  require_relative 'cell'

  attr_accessor :cells, :fractions, :players

  def initialize
    @cells = GameMap.new
    @fractions = []
    @players = []
  end

  def << (item)
    @cells << item if item.is_a? Cell
  end

  def to_json
    {
        fractions: @fractions,
        cells: @cells,
        players: @players
    }.to_json
  end

  def changes
    {
      cells: cells.changes,
      players: []
    }
  end

  def clear_changes
    cells.changes.clear
  end
end