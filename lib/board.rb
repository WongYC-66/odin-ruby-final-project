require_relative "piece"

class Board
  MIN_ROW, MAX_ROW = 0, 7
  MIN_COL, MAX_COL = 0, 7
  attr_reader(:board)

  def initialize(board = nil)
    @board = board
    @board = new_board() if @board == nil
  end

  def new_board
    # B = Black, W = White
    [
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

  def place_piece(from, to, player)
    return false if whose_piece?(from[0], from[1]) != player.color
    return false if !valid_move?(from, to)
    return false if own_king_checked_after_placed?(from, to, player)
    # Replace and remove old
    r1, c1 = from
    r2, c2 = to
    @board[r2][c2] = @board[r1][c1]
    @board[r1][c1] = nil
    check_pawn_move_rules(from, to)
    @board[r2][c2].updated_moved()
    return true
  end

  def whose_piece?(r, c) # return "B" or "W"
    piece = @board[r][c]
    return piece ? @board[r][c].color : nil
  end

  def valid_move?(from, to)
    return can_take?(from, to) || can_move?(from, to)
    # return can_move?(from, to)
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
    takeable_pos = find_reachable_pos(from, source_piece.take_type, include_first_piece: true)
    p takeable_pos
    return takeable_pos.include?(to)
  end

  def can_move?(from, to)
    r1, c1 = from
    r2, c2 = to
    source_piece = @board[r1][c1]
    target_piece = @board[r2][c2]
    return false if source_piece == nil
    return false if target_piece  # to_pos has a piece, can't move
    # from,to both not empty
    moveable_pos = find_reachable_pos(from, source_piece.move_type, include_first_piece: false)
    p moveable_pos
    return moveable_pos.include?(to)
  end

  def find_reachable_pos(from, type_arr, include_first_piece)
    reachable_pos = []
    # p type_arr # to be commented
    type_arr.each do |type|
      reachable_pos += find_one_step_vertical_up_pos(from) if type == 'one-step-vertical-up'
      reachable_pos += find_two_step_vertical_up_pos(from) if type == 'two-step-vertical-up'
      reachable_pos += find_one_step_vertical_down_pos(from) if type == 'one-step-vertical-down'
      reachable_pos += find_two_step_vertical_down_pos(from) if type == 'two-step-vertical-down'
      reachable_pos += find_one_step_diagonal_up_pos(from) if type == 'one-step-diagonal-up'
      reachable_pos += find_one_step_diagonal_down_pos(from) if type == 'one-step-diagonal-down'
      reachable_pos += find_one_step_cross_pos(from) if type == 'one-step-cross'
      reachable_pos += find_one_step_diagonal_pos(from) if type == 'one-step-diagonal'
      reachable_pos += find_knight_pos(from) if type == 'knight'
      reachable_pos += find_vertical_pos(from, include_first_piece) if type == 'Vertical'
      reachable_pos += find_horizontal_pos(from, include_first_piece) if type == 'Horizontal'
      reachable_pos += find_diagonal_pos(from, include_first_piece) if type == 'Diagonal'
    end
    reachable_pos = exclude_pos_of_own_piece(reachable_pos, from)
    return reachable_pos
  end

  def exclude_pos_of_own_piece(pos, from)
    r, c = from
    player_color = @board[r][c].color
    pos.filter do |loc|
      p_r, p_c = loc
      piece = @board[p_r][p_c]
      if !piece
        true    # keep empty pos
      elsif piece.color == player_color
        false   # discard pos with player'own piece
      else
        true    
      end
    end
  end

  def verify_options(options, from)
    options.filter_map do |opt|
      dr, dc = opt
      new_r = from[0] + dr
      new_c = from[1] + dc
      if valid_loc?(new_r, new_c)
        [new_r, new_c] 
      else
        nil
      end
    end 
  end

  def valid_loc?(r,c)
    return r.between?(MIN_ROW, MAX_ROW) && c.between?(MIN_COL, MAX_COL) 
  end

  def find_one_step_vertical_up_pos(from)
    options = [[-1, 0]]  #up, #pawn
    verify_options(options, from)
  end

  def find_two_step_vertical_up_pos(from)
    options = [[-2, 0]]  #up, #pawn
    verify_options(options, from)
  end

  def find_one_step_vertical_down_pos(from)
    options = [[+1, 0]]  #down, #pawn
    verify_options(options, from)
  end

  def find_two_step_vertical_down_pos(from)
    options = [[+2, 0]]  #down, #pawn
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

  def game_over?(player1, player2)
    # remain_kings = @board.flatten().filter do |piece|
    #   piece.instance_of? King
    # end
    # return [false, nil] if remain_kings.length != 1   # return false when more than 2 kings
    # return [true, remain_kings[0].color]              # return true and color of remaining winning king
    opposite_map = {
      'W' => 'B',
      'B' => 'W',
    }
    [player1, player2].each do |player|
      opposite_color = opposite_map[player.color]
      player_pieces = get_all_pieces_by_player(player)
      moves_res = [] # true = checked, false = safe

      player_pieces.each do |from_loc, piece|
        move_or_takeable_pos = find_reachable_pos(from_loc, piece.take_type, include_first_piece: true)
        move_or_takeable_pos += find_reachable_pos(from_loc, piece.take_type, include_first_piece: false) # pawn
        move_or_takeable_pos = Set.new(move_or_takeable_pos).to_a
        piece_move_res = []
        move_or_takeable_pos.each do |to_loc|
          copy_board = clone_board()
          place_res = copy_board.own_king_checked_after_placed?(from_loc, to_loc, player) # return false if invalid/king under checked
          piece_move_res.push(place_res)
        end
        moves_res += piece_move_res
      end
      return [true, opposite_color] if moves_res.all? # .all? check if all el in array are truthy
    end
    return [false, nil]
  end

  def check_pawn_move_rules(from, to)
    r1, _ = from
    r2, c2 = to
    piece = @board[r2][c2] 
    
    if piece.type == 'Pawn'
      #1. if pawn ever moved, always disabled double-step
      piece.disable_double_step  

      # 2. if is diagonally and en_passant applies
      check_kill_the_en_passant_pawn(piece, r2, c2)
    end
      
    # 3. if no en_passant killing, then reset all en_passant rules bcoz miss it 
    reset_pawn_en_passant_killable()

    if piece.type == "Pawn"
      # 4. if double_stepped, then gives opposite pawn at 'left' and 'right' the ability to en-passant
      give_opposite_pawn_en_passant(piece, r2, c2) if (r2 - r1).abs == 2 # double-step

      # 5. check if pawn can promote
      check_if_promote(piece, r2, c2)
    end
  end

  def check_if_promote(piece, r, c)
    if r == MIN_ROW || r == MAX_ROW
      print_board()
      puts "Wow, your pawn reached the last row, a promotion!"
      color = piece.color
      input = get_input_for_promote()
      new_piece = nil
      case input 
        # 'queen, rook, knight, or bishop'
        when 'queen'
          new_piece = Queen.new(color)
        when 'rook'
          new_piece = Rook.new(color)
        when 'knight'
          new_piece = Knight.new(color)
        when 'bishop'
          new_piece = Bishop.new(color)
      end
      @board[r][c] = new_piece
    end
  end

  def get_input_for_promote
    input = nil
    promote_regex = /(knight)|(queen)|(bishop)|(rook)/
    until promote_regex.match?(input)
      puts "Which you want pawn promote to ? queen/bishop/knight/rook"
      input = gets.chomp!.downcase
    end
    return input
  end

  def give_opposite_pawn_en_passant(piece, r, c)
    opposite_pawns = []
    opposite_pawns.push(@board[r][c + 1]) if c < MAX_COL
    opposite_pawns.push(@board[r][c - 1]) if c > MIN_COL
    opposite_pawns.each do |oppo_piece|
      next if !oppo_piece
      next if oppo_piece.type != 'Pawn' 
      next if oppo_piece.color == piece.color 
      oppo_piece.add_en_passant(piece)
    end
  end

  def check_kill_the_en_passant_pawn(piece, r, c)
    return if !piece.killable_pawn_by_en_passant
    top_piece = @board[r - 1][c] if r > MIN_ROW
    bottom_piece = @board[r + 1][c] if r < MAX_ROW
    remove_from_board(top_piece) if piece.killable_pawn_by_en_passant == top_piece
    remove_from_board(bottom_piece) if piece.killable_pawn_by_en_passant == bottom_piece
  end

  def remove_from_board(piece_to_remove)
    @board.each_with_index do |row, r|
      row.each_with_index do |piece, c|
        @board[r][c] = nil if piece == piece_to_remove
      end
    end
  end

  def reset_pawn_en_passant_killable()
    @board.each_with_index do |row, r|
      row.each_with_index do |piece, c|
        next if !piece
        next if piece.type != 'Pawn'
        piece.delete_en_passant()
      end
    end
  end

  def castling(loc, player)
    r, c = loc[0]
    return false if whose_piece?(r, c) != player.color

    rook_piece = @board[r][c]
    return false if rook_piece.moved

    r_king, c_king, king_piece = get_player_king_piece(player)
    return false if king_piece.moved

    castling_path = generate_path(r, c, r_king, c_king)
    pieces_between_path = castling_path.filter_map { |loc| loc ? @board[loc[0]][loc[1]] : false}
    return false if pieces_between_path.length != 2

    opposite_attacking_loc = generate_opposite_attacking_loc(player)
    intersect_loc = Set.new(opposite_attacking_loc) & Set.new(castling_path)
    is_castling_path_under_attack = intersect_loc.size > 0

    # puts "# castling path"
    # p Set.new(castling_path)

    # puts "# opposite attacking loc"
    # p Set.new(opposite_attacking_loc)

    # puts "# intersect_loc :" 
    # p Set.new(intersect_loc)

    if(is_castling_path_under_attack)
      return false
    else
      # move king and move rook
      if c < c_king
        # rook at left of king originally
        @board[r][c_king - 1] = rook_piece
        @board[r][c_king - 2] = king_piece
      else
        # rook at right of king originally
        @board[r][c_king + 1] = rook_piece
        @board[r][c_king + 2] = king_piece
      end
      @board[r][c] = nil
      @board[r][c_king] = nil
      return true
    end
  end

  def get_player_king_piece(player)
    @board.each_with_index do |row, r|
      row.each_with_index do |piece, c|
        next if !piece
        return [r, c, piece] if piece.type == 'King' && piece.color == player.color
      end
    end
  end

  def generate_path(r1, c1, r2, c2)
    return [] if r1 != r2
    res = []
    small_c, large_c = [c1, c2].minmax()
    for c in small_c..large_c
      res.push([r1, c])
    end
    res
  end

  def generate_opposite_attacking_loc(player)
    # find all pieces not owned by player
    opposite_pieces = get_all_pieces_by_player(player, opposite: true)
    danger_loc = []   

    opposite_pieces.map do |loc, piece|
      danger_loc += find_reachable_pos(loc, piece.take_type, include_first_piece: true)
    end

    return danger_loc
  end

  def get_all_pieces_by_player(player, opposite = false)
    pieces = [] #[ [[r,c], piece], ...]
    opposite_map = {
      'B' => 'W',
      'W' => 'B'
    }
    wanted_color = opposite ? opposite_map[player.color] : player.color

    @board.each_with_index do |row, r|
      row.each_with_index do |piece, c|
        next if !piece
        pieces.push([[r, c], piece]) if whose_piece?(r, c) == wanted_color
      end
    end
    return pieces
  end

  def own_king_checked_after_placed?(from, to, player)
    # simulate board if after move, self-king under checked?
    copy_board = clone_board()
    # Replace and remove old
    r1, c1 = from
    r2, c2 = to
    source_piece = copy_board.board[r1][c1]
    copy_board.update_board_piece(r2, c2, source_piece)
    copy_board.update_board_piece(r1, c1, nil)

    return player_king_been_checked?(player, copy_board)
  end

  def clone_board
    board_data = []
    @board.each do |row|
      new_row = []
      row.each { |piece| new_row << piece}
      board_data << new_row
    end
    return Board.new(board_data)
  end

  def update_board_piece(r, c, piece)
    @board[r][c] = piece
  end

  def player_king_been_checked?(player, board)
    # own king
    r_king, c_king, _ = board.get_player_king_piece(player)
    king_loc = [[r_king, c_king]]

    # find if intersect with king locations
    opposite_attacking_loc = board.generate_opposite_attacking_loc(player)
    intersect_loc = Set.new(opposite_attacking_loc) & Set.new(king_loc)
    return intersect_loc.size > 0  # 0 = not under attk
  end

  

end