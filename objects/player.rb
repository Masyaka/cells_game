class Player < GameObject
  attr_accessor :fraction, :last_command_time, :name

  def to_json
    {
        fraction_name: self.fraction.name
    }
  end
end