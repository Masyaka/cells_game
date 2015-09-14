require_relative 'game_object'
require_relative 'coordinate_utilities'

class Cell < GameObject
  include CoordinateUtilities
  attr_accessor :x, :y, :fraction

  def self.neutral_color
    '#000000'
  end

  def eql?(other)
    @x == other.x && @y == other.y
  end

  def hash
    cid(x, y)
  end

  def color
    @fraction.color
  end

  def to_json(options = {})
    {
        x: @x,
        y: @y,
        fraction_name: @fraction.name,
        color: @fraction.color
    }
  end
end