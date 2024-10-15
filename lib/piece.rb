class Piece
  attr_reader(:color, :type, :move_type, :take_type, :moved)
  def initialize(color)
    @color = color  # W or B
    @moved = false
  end

  def to_s
    @symbol
  end

  def updated_moved
    @moved = true
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
  attr_reader(:killable_pawn_by_en_passant)
  def initialize(color)
    super
    @symbol = color == 'W' ? "♙" : "♟"
    @type = "Pawn"
    @move_type = color == 'W' ? ["one-step-vertical-up", "two-step-vertical-up"] : ["one-step-vertical-down", "two-step-vertical-down"] 
    @take_type = color == 'W' ? ["one-step-diagonal-up"] : ["one-step-diagonal-down"] 
    @killable_pawn_by_en_passant = nil
  end

  def disable_double_step
    @move_type.delete("two-step-vertical-up")
    @move_type.delete("two-step-vertical-down")
  end

  def add_en_passant(killable_pawn)
    @killable_pawn_by_en_passant = killable_pawn
    @move_type.push("one-step-diagonal-up") if @color == "W"
    @move_type.push("one-step-diagonal-down") if @color != "W"
  end

  def delete_en_passant()
    @killable_pawn_by_en_passant = nil
    @move_type.delete("one-step-diagonal-up")
    @move_type.delete("one-step-diagonal-down")
  end
end


