require 'yaml'
require_relative "board"
require_relative "player"

class Game
  def initialize(board = Board.new, turn = true, player1 = Player.new("Player_1", "W"), player2 = Player.new("Player_2", "B"))
    @board = board
    @turn = turn  # true = White(bottom side) starts first
    @player1 = player1 
    @player2 = player2
  end

  def play
    until @board.game_over?[0]
      @board.print_board()
      user_input = get_user_input() # [[1,0], [2,0]] or "save" or "q" or "Q"
      if user_input == "save"
        save_game()
        next
      end
      if user_input == "q"
        exit
      end
      # valid input, 
      from, to = translate(user_input)
      place_res = @board.place_piece(from, to, get_curr_player())

      if place_res
        @turn = !@turn
      else
        puts "Invalid placement..."
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
    chess_loc_regex = /^[a-hA-H][1-8]$/

    puts "#{curr_player.name}'s turn. You can save game by 'save' or quit by 'q'"

    until((from && to) || input == 'save' || input == 'q')
      if from == nil
        puts "Please enter which piece u pick to move ? e.g. A2"
        input = gets().chomp.downcase
        from = input if chess_loc_regex.match?(input)
      else
        puts "from : #{from}"
        puts "Please location to place ? e.g. A3 or 'r' to repick the piece"
        input = gets().chomp.downcase
        from = nil if input == "r"
        to = input if chess_loc_regex.match?(input)
      end
    end

    return input if input == 'save' || input == 'q'
    return [from, to]
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
    _, winner_color = @board.game_over?
    winning_player = winner_color == @player1.color ? @player1 : @player2

    puts "Game Ended"
    puts "Check Mate! #{winning_player.name} has won!"
  end
end