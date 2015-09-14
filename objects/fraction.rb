class Fraction < GameObject
  attr_accessor :color, :name

  def to_json
    {
        color: self.color,
        name: self.name
    }
  end
end