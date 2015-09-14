class GlobalState < GameObject
  require_relative 'cells_map'
  attr_accessor :cells, :fractions, :players

  def initialize
    @cells = CellsMap.new
    @fractions = [
        Fraction.new(name: 'The Red', color: '#ff0000'),
        Fraction.new(name: 'The Blue', color: '#0000ff')
    ]
    @players = [
        Player.new(name: 'The Red', fraction: fractions[0]),
        Player.new(name: 'The Blue', fraction: fractions[1])
    ]
  end

  def cells_json
    @cells.collect { |k,v| v.to_json }
  end

  def to_json
    {
        fractions: @fractions.collect { |n| n.to_json },
        cells: cells_json,
        players: @players.collect { |n| n.to_json }
    }.to_json
  end
end