require_relative "piece"

class Board
  def initialize(board = nil)
    @board = board
    new_board() if @board == nil
  end

  def new_board
    @board = [
      [Rook.new('B'), Knight.new('B'), Bishop.new('B'), Queen.new('B'), King.new('B'), Bishop.new('B'), Knight.new('B'), Rook.new('B')],
      Array.new(8) { Pawn.new('B')},
      Array.new(8) { nil },
      Array.new(8) { nil },
      Array.new(8) { nil },
      Array.new(8) { nil },
      Array.new(8) { Pawn.new('W')},
      [Rook.new('W'), Knight.new('W'), Bishop.new('W'), Queen.new('W'), King.new('W'), Bishop.new('W'), Knight.new('W'), Rook.new('W')],
    ]
  end

  def print_board
    puts "  ┌⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯┐"
    @board.each_with_index do |row, r|
      str = "#{8 - r} |"
      row.each do |piece|
        # str += piece == nil ? " " : piece.symbol
        if piece != nil
          str += " " + piece.to_s + " |"
        else
          str += ' _ |'
        end
      end
      puts str
    end
    puts "  └⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯┘ "
    puts "    A   B   C   D   E   F   G   H  "
  end

  def is_valid_move? (from, to)

  end

  def game_over?
    remain_kings = @board.flatten().filter do |piece|
      piece.instance_of? King
    end
    return [false, nil] if remain_kings.length != 1   # return false when game continues
    return [true, remain_kings[0].color]              # return true and color of winner
  end
end