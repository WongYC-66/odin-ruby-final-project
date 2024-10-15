class Player
  attr_reader(:name, :color)
  attr_writer(:score)
  
  def initialize(name, color, score = 0)
    @name = name
    @color = color
    @score = score
  end
end