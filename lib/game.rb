require 'yaml'
require 'colorize'
require_relative "board"
require_relative "player"

class Game

  CHESS_LOC_REGEX = /^[a-hA-H][1-8]$/

  def initialize(board = Board.new, turn = true, player1 = Player.new("Player_1", "W"), player2 = Player.new("Player_2", "B"))
    @board = board
    @turn = turn  # true = White(bottom side) starts first
    @player1 = player1 
    @player2 = player2
  end

  def play
    until @board.game_over?(@player1, @player2)[0]
      @board.print_board()
      print_under_check_msg()
      user_input = get_user_input() # [[1,0], [2,0]] or "save" or "q" or "Q" or "castling"

      # option 1. save game
      if user_input == "save"
        save_game()
        next
      end
      # option 2. quit game
      if user_input == "q"
        exit
      end

      # option 3. do king-rook castling
      if user_input == "castling"
        rook_input = get_user_input_for_rook()
        next if rook_input == 'r' # reset option
        castling_res = @board.castling(translate(rook_input), get_curr_player)
        if castling_res
          @turn = !@turn
          puts "Success : Castling done."
        else
          puts "Error : castling failed, either u've moved King/Rook, or the path is under attack..."
        end
        next
      end

      # option 4. place piece
      from, to = translate(user_input)
      place_res = @board.place_piece(from, to, get_curr_player())

      if place_res
        @turn = !@turn
      else
        puts "Error : Invalid placement..."
      end
    end
    # ended
    @board.print_board()
    print_end_game_status()
  end

  def get_user_input
    from = nil
    to = nil
    input = nil
    curr_player = get_curr_player()

    puts "#{curr_player.name}'s turn. You can enter:".white.on_black.blink if curr_player.color == 'B'
    puts "#{curr_player.name}'s turn. You can enter:".black.on_white.blink if curr_player.color == 'W'
    puts "   save     - to save game"
    puts "   q        - to quit game"
    puts "   castling - to do casling" 

    until((from && to) || input == 'save' || input == 'q' || input == 'castling')
      if from == nil
        puts "Please enter which piece u pick to move ? e.g. A2".blue
        input = gets().chomp.downcase
        from = input if CHESS_LOC_REGEX.match?(input)
      else
        puts "from : #{from}"
        puts "Please enter location to place ? e.g. A3 or 'r' to repick the piece".blue
        input = gets().chomp.downcase
        from = nil if input == "r"
        to = input if CHESS_LOC_REGEX.match?(input)
      end
    end

    return input if input == 'save' || input == 'q' || input == 'castling'
    return [from, to]
  end

  def get_user_input_for_rook
    input = nil

    until(CHESS_LOC_REGEX.match?(input) || input == 'r')
      puts "Which Rook u wanna castling with ? Enter r to cancel"
      input = gets().chomp.downcase
    end

    return [input]
  end

  def get_curr_player
    @turn == true ? @player1 : @player2
  end

  def translate(user_input)
    # ['A2' 'A3'] => [[6,0], [5,0]]
    user_input.map do |str|
      char, num = str.chars
      row = 8 - num.to_i
      col = char.upcase.ord - 'A'.ord
      [row, col]      
    end
  end

  def save_game
    yaml_string = YAML.dump({
      :board => @board,
      :turn => @turn,
      :player1 => @player1,
      :player2 => @player2,
    })
    File.write('./saved/save.yaml', yaml_string)
    puts "######### Game saved #########"
  end

  def self.load_saved
    p "loading saved game ...."
    data = YAML.load_file(
      "./saved/save.yaml",
      permitted_classes: [Symbol, Piece, Board, Rook, Knight, Bishop, Queen, King, Pawn, Player]
    )
    self.new(data[:board], data[:turn], data[:player1], data[:player2])
  end

  def print_end_game_status
    _, winner_color = @board.game_over?(@player1, @player2)
    winning_player = winner_color == @player1.color ? @player1 : @player2

    puts "Game Ended"
    puts "Check Mate! #{winning_player.name} has won!"
  end

  def print_under_check_msg
    [@player1, @player2].each do |player|
      if @board.player_king_been_checked?(player, @board)
        puts "##############################".red
        puts "   #{player.name} being checked !".red
        puts "##############################".red
      end
    end
  end
end