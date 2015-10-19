class GameState < GameObject
  require_relative 'game_map'
  require_relative 'fraction'
  require_relative 'player'
  attr_accessor :cells, :fractions, :players

  def initialize
    @cells = GameMap.new self
    @fractions = [
        Fraction.new(name: 'The Red', color: '#ff0000'),
        Fraction.new(name: 'The Blue', color: '#0000ff')
    ]
    @players = [
        Player.new(name: 'The Red', fraction: fractions[0]),
        Player.new(name: 'The Blue', fraction: fractions[1])
    ]
    @cells << Cell.new(
        x: 0,
        y: 0,
        fraction: @players[0].fraction
    )
    @cells << Cell.new(
        x: 10,
        y: 10,
        fraction: @players[1].fraction
    )
  end

  def cells_json
    @cells.collect { |_,v| v.to_json }
  end

  def to_json
    {
        fractions: @fractions.collect { |n| n.to_json },
        cells: cells_json,
        players: @players.collect { |n| n.to_json }
    }.to_json
  end

  def changes
    {
        cells: cells.changes
    }
  end

  def clear_changes
    cells.changes.clear
  end
end