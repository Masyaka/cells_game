class Player < GameObject
  attr_accessor :fraction, :last_command_time, :name

  def to_json
    {
        color: self.fraction.color,
        fraction_name: self.fraction.name,
        fraction: self.fraction.name
    }
  end

  def color
    fraction.color
  end
end