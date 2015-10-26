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

  def create_player (name, color)
    fraction = @fractions.find{|_| _.color == color}
    if fraction.nil?
      fraction = create_fraction(color, color)
    end
    player = Player.new(email: name, name: name, fraction: fraction)
    self.players << player
    player
  end

  def create_fraction (name, color)
    fraction = @fractions.find{|_| _.color == color}
    if fraction.nil?
      fraction = Fraction.new(color: color, name: name)
      self.fractions << fraction
    end
    fraction
  end

  def << (item)
    @cells << item if item.is_a? Cell
    @players << item if item.is_a? Player
    @fractions << item if item.is_a? Fraction
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