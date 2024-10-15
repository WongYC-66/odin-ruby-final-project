class Piece
  attr_reader(:color, :type, :move_type, :take_type)
  def initialize(color)
    @color = color  # W or B
  end

  def to_s()
    @symbol
  end
end

class Rook < Piece
  def initialize(color)
    super
    @symbol = color == 'W' ? "♖" : "♜"
    @type = "Rook"
    @move_type = ["Vertical", "Horizontal"]
    @take_type = ["Vertical", "Horizontal"]
  end
end

class Knight < Piece
  def initialize(color)
    super
    @symbol = color == 'W' ? "♘" : "♞"
    @type = "Knight"
    @move_type = ["knight"]
    @take_type = ["knight"]
  end
end

class Bishop < Piece
  def initialize(color)
    super
    @symbol = color == 'W' ? "♗" : "♝"
    @type = "Bishop"
    @move_type = ["Diagonal"]
    @take_type = ["Diagonal"]
  end
end

class Queen < Piece
  def initialize(color)
    super
    @symbol = color == 'W' ? "♕" : "♛"
    @type = "Queen"
    @move_type = ["Vertical", "Horizontal", "Diagonal"]
    @take_type = ["Vertical", "Horizontal", "Diagonal"]
  end
end

class King < Piece
  def initialize(color)
    super
    @symbol = color == 'W' ? "♔" : "♚"
    @type = "King"
    @move_type = ["one-step-cross", "one-step-diagonal"]
    @take_type = ["one-step-cross", "one-step-diagonal"]
  end
end

class Pawn < Piece
  def initialize(color)
    super
    @symbol = color == 'W' ? "♙" : "♟"
    @type = "Pawn"
    @move_type = color == 'W' ? ["one-step-vertical-up"] : ["one-step-vertical-down"] 
    @take_type = color == 'W' ? ["one-step-diagonal-up"] : ["one-step-diagonal-down"] 
  end
end


