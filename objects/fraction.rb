class Fraction < GameObject
  attr_accessor :color, :name

  def to_json(_= {})
    {
        color: self.color,
        name: self.name
    }.to_json
  end
end