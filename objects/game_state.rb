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
    @changes = Hash.new

    fraction = Fraction.new color: '#ff0000', name: 'The Red'
    fractions << fraction
    cells << Cell.new(fraction: fraction, x: 1, y: 1)
  end

  def create_player (name, color)
    fraction = @fractions.find{|_| _.color == color}
    if fraction.nil?
      fraction = create_fraction(color, color)
    end
    player = Player.new(email: name, name: name, fraction: fraction)
    player_created player
    player
  end

  def create_fraction (name, color)
    fraction = Fraction.new(color: color, name: name)
    fraction_created fraction
    cells << Cell.new(
      fraction: fraction,
      x: rand(cells.min_col + 5 .. cells.max_col + 5),
      y: rand(cells.min_row + 5 .. cells.max_row + 5)
    )
    fraction
  end

  def << (item)
    @cells << item if item.is_a? Cell
    player_created item if item.is_a? Player
    fraction_created item if item.is_a? Fraction
  end

  def to_json
    {
        fractions: @fractions,
        cells: @cells,
        players: @players
    }.to_json
  end

  def player_created player
    if player.is_a? Player
      @players << player
      @changes[:players_created].nil? ? @changes[:players_created] = [player] : @changes[:players_created] << player
    else
      raise "player is not Player!"
    end
  end

  def fraction_created fraction
    if fraction.is_a? Fraction
      fractions << fraction
      @changes[:fractions_created].nil? ? @changes[:fractions_created] = [fraction] : @changes[:fractions_created] << fraction
    else
      raise "fraction is not Fraction!"
    end
  end

  def changes
    @changes[:cells_created] = cells.changes[:created]
    @changes[:cells_removed] = cells.changes[:removed]
    @changes
  end

  def clear_changes
    cells.changes[:created].clear
    cells.changes[:removed].clear
    changes.clear
  end
end