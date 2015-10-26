class Player < GameObject
  attr_accessor :fraction, :last_command_time, :name, :email

  def to_json(_= {})
    {
      color: self.color,
      fraction_name: self.fraction_name,
      fraction: self.fraction_name,
      email: self.email,
      name: self.name
    }.to_json
  end

  def color
    fraction.nil? ? 'neutral' : fraction.color
  end

  def fraction_name
    fraction.nil? ? 'neutral' : fraction.name
  end

  def name
    email
  end
end