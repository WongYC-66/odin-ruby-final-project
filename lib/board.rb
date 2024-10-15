require_relative "piece"

class Board
  MIN_ROW, MAX_ROW = 0, 7
  MIN_COL, MAX_COL = 0, 7

  def initialize(board = nil)
    @board = board
    new_board() if @board == nil
  end

  def new_board
    # B = Black, W = White
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
    #   ┌⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯┐
    # 8 | ♜ | ♞ | ♝ | ♛ | ♚ | ♝ | ♞ | ♜ |
    # 7 | ♟ | ♟ | ♟ | ♟ | ♟ | ♟ | ♟ | ♟ |
    # 6 | _ | _ | _ | _ | _ | _ | _ | _ |
    # 5 | _ | _ | _ | _ | _ | _ | _ | _ |
    # 4 | _ | _ | _ | _ | _ | _ | _ | _ |
    # 3 | _ | _ | _ | _ | _ | _ | _ | _ |
    # 2 | ♙ | ♙ | ♙ | ♙ | ♙ | ♙ | ♙ | ♙ |
    # 1 | ♖ | ♘ | ♗ | ♕ | ♔ | ♗ | ♘ | ♖ |
    #   └⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯┘ 
    #     A   B   C   D   E   F   G   H
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

  def valid_move?(from, to)
    return can_take?(from, to) || can_move?(from, to)
  end

  def can_take?(from, to)
    r1, c1 = from
    r2, c2 = to
    source_piece = @board[r1][c1]
    target_piece = @board[r2][c2]
    return false if source_piece == nil
    return false if target_piece == nil
    return false if source_piece.color == target_piece.color # cant take own piece
    # from,to both not empty
    takeable_pos = find_reachable_pos(from, to, source_piece.take_type, include_first_piece: true)
    return takeable_pos.include? (to)
  end

  def can_move?(from, to)
    r1, c1 = from
    r2, c2 = to
    source_piece = @board[r1][c1]
    target_piece = @board[r2][c2]
    return false if source_piece == nil
    return false if target_piece  # to_pos has a piece, can't move
    # from,to both not empty
    moveable_pos = find_reachable_pos(from, to, source_piece.move_type, include_first_piece: false)
    return moveable_pos.include? (to)
  end

  def find_reachable_pos(from, to, type_arr, include_first_piece)
    reachable_pos = []
    type_arr.each do |type|
      reachable_pos += find_one_step_vertical_up_pos(from) if type == 'one-step-vertical-up'
      reachable_pos += find_one_step_vertical_down_pos(from) if type == 'one-step-vertical-down'
      reachable_pos += find_one_step_diagonal_up_pos(from) if type == 'one-step-diagonal-up'
      reachable_pos += find_one_step_diagonal_down_pos(from) if type == 'one-step-diagonal-down'
      reachable_pos += find_one_step_cross_pos(from) if type == 'one-step-cross'
      reachable_pos += find_one_step_diagonal_pos(from) if type == 'one-step-diagonal'
      reachable_pos += find_knight_pos(from) if type == 'knight'
      reachable_pos += find_vertical_pos(from, include_first_piece) if type == 'Vertical'
      reachable_pos += find_horizontal_pos(from, include_first_piece) if type == 'Horizontal'
      reachable_pos += find_diagonal_pos(from, include_first_piece) if type == 'Diagonal'
    end
    return reachable_pos
  end

  def verify_options(options, from)
    options.filter_map do |opt|
      dr, dc = opt
      new_r = from[0] + dr
      new_c = from[1] + dc
      return [new_r, new_c] if valid_loc?(new_r, new_c)
    end 
  end

  def valid_loc?(r,c)
    return r.between?(MIN_ROW, MAX_ROW) && c.between?(MIN_COL, MAX_COL) 
  end

  def find_one_step_vertical_up_pos(from)
    options = [[-1, 0]]  #up, #pawn
    verify_options(options, from)
  end

  def find_one_step_vertical_down_pos(from)
    options = [[+1, 0]]  #down, #pawn
    verify_options(options, from)
  end

  def find_one_step_diagonal_up_pos(from)
    options = [[-1, -1], [-1, +1]]  #up #pawn
    verify_options(options, from)
  end

  def find_one_step_diagonal_down_pos(from)
    options = [[+1, -1], [+1, +1]]  #down #pawn
    verify_options(options, from)
  end

  def find_one_step_diagonal_pos(from)
    options = [[-1, -1], [+1, -1], [-1, +1], [+1, +1]]  # top_left, bot_left, top_right, bot_right
    verify_options(options, from)
  end

  def find_one_step_cross_pos(from)
    options = [[0, -1], [0, +1], [+1, 0], [-1, 0]]  # left, right, bottom, top
    verify_options(options, from)
  end

  def find_knight_pos(from)
    options = [
      [-1, -2], [-2, -1], [-2, +1], [-1, +2],
      [+1, -2], [+2, -1], [+2, +1], [+1, +2],
    ]  # knight 8 possible
    verify_options(options, from)
  end

  def verify_options_path(options, from, reachable_pos, include_first_piece)
    r, c = from
    options.each do |dir|
      dr, dc = dir
      for mult in 1..MAX_COL
          new_r = r + dr * mult
          new_c = c + dc * mult
          break if !valid_loc?(new_r, new_c)
          piece = @board[new_r][new_c]
          reachable_pos.push([new_r, new_c]) if piece == nil
          if piece
            reachable_pos.push([new_r, new_c]) if include_first_piece
            break
          end
      end      
    end
    return reachable_pos
  end

  def find_vertical_pos(from, include_first_piece)
    reachable_pos = []
    options = [[-1, 0], [+1, 0]] # top path, bottom path
    verify_options_path(options, from, reachable_pos, include_first_piece)
  end

  def find_horizontal_pos(from, include_first_piece)
    reachable_pos = []
    options = [[0, 1], [0, -1]] # right path, left path
    verify_options_path(options, from, reachable_pos, include_first_piece)
  end

  def find_diagonal_pos(from, include_first_piece)
    reachable_pos = []
    options = [[-1, -1], [-1, +1], [+1,-1], [+1,+1]] # diagonals
    verify_options_path(options, from, reachable_pos, include_first_piece)
  end

  def game_over?
    remain_kings = @board.flatten().filter do |piece|
      piece.instance_of? King
    end
    return [false, nil] if remain_kings.length != 1   # return false when more than 2 kings
    return [true, remain_kings[0].color]              # return true and color of remaining winning king
  end
end