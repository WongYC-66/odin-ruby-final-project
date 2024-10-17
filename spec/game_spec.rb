require_relative "../lib/board.rb"
require_relative "../lib/game.rb"
require_relative "../lib/player.rb"

describe Game do

  let(:test_game) { Game.new(board:board_instance, turn:true, player1:player1, player2:player2, is_Ai:false) }
  let(:board_instance) {instance_double(Board)}
  let(:player1) {instance_double(Player)}
  let(:player2) {instance_double(Player)}

  before do
    allow(player1).to receive(:color).and_return('W')
    allow(player2).to receive(:color).and_return('B')
    allow(player1).to receive(:name).and_return('Player_1')
    allow(player2).to receive(:name).and_return('Player_2')
  end

  describe("#play") do
    before do
      allow(board_instance).to receive(:print_board)
      allow(board_instance).to receive(:castling)
      allow(board_instance).to receive(:place_piece)
      allow(test_game).to receive(:print_under_check_msg)
      allow(test_game).to receive(:translate)
      allow(test_game).to receive(:puts)
      allow(test_game).to receive(:save_game)
      allow(test_game).to receive(:print_end_game_status)
      allow(test_game).to receive(:get_user_input)
      allow(test_game).to receive(:get_user_input_for_rook)
      allow(test_game).to receive(:get_curr_player)
    end

    context("when game_over ") do
      it("triggers print_end_game and nothing else ") do
        allow(board_instance).to receive(:game_over?).and_return([true, 'W'])
        expect(test_game).to receive(:print_end_game_status).once
        expect(test_game).to receive(:get_user_input).at_most(0).time
        test_game.play()
      end
    end

    context("when input is 'save' ") do
      it("triggers save_game and nothing else ") do
        allow(board_instance).to receive(:game_over?).and_return([false, nil], [true, 'W'])
        allow(test_game).to receive(:get_user_input).and_return('save')

        expect(test_game).to receive(:save_game).once
        expect(test_game).to receive(:translate).at_most(0).time
        test_game.play()
      end
    end

    context("when input is 'q' ") do
      it("ends game and nothing else ") do
        allow(board_instance).to receive(:game_over?).and_return([false, nil], [true, 'W'])
        allow(test_game).to receive(:get_user_input).and_return('q')

        expect(test_game).to receive(:exit).once
        expect(test_game).to receive(:translate).at_most(0).time
        test_game.play()
      end
    end

    context("when input is 'castling' and 'r' ") do
      it("skips the rest") do
        allow(board_instance).to receive(:game_over?).and_return([false, nil], [true, 'W'])
        allow(test_game).to receive(:get_user_input).and_return('castling')
        allow(test_game).to receive(:get_user_input_for_rook).and_return('r')

        expect(test_game).to receive(:translate).at_most(0).time
        expect(board_instance).to receive(:castling).at_most(0).time
        test_game.play()
      end
    end

    context("when input is 'castling' and ['a8'], and is avalid castling") do
      it("executes castling and update turn") do
        allow(board_instance).to receive(:game_over?).and_return([false, nil], [true, 'W'])
        allow(board_instance).to receive(:castling).and_return(true)
        allow(test_game).to receive(:get_user_input).and_return('castling')
        allow(test_game).to receive(:get_user_input_for_rook).and_return(['a8'])

        expect(board_instance).to receive(:castling).once
        test_game.play()
        expect(test_game.instance_variable_get(:@turn)).to eql(false)
      end
    end

    context("when input is 'castling' and ['a8'], and is a invalid castling") do
      it("executes castling but does not update turn") do
        allow(board_instance).to receive(:game_over?).and_return([false, nil], [true, 'W'])
        allow(board_instance).to receive(:castling).and_return(false)
        allow(test_game).to receive(:get_user_input).and_return('castling')
        allow(test_game).to receive(:get_user_input_for_rook).and_return(['a8'])

        expect(board_instance).to receive(:castling).once
        test_game.play()
        expect(test_game.instance_variable_get(:@turn)).to eql(true)
      end
    end

    context("when input is ['a2', 'a3'], and is a valid piece-placing move") do
      it("executes board.place_piece and updates the turn") do
        allow(board_instance).to receive(:game_over?).and_return([false, nil], [true, 'W'])
        allow(board_instance).to receive(:place_piece).and_return(true)
        allow(test_game).to receive(:get_user_input).and_return(['a2','a3'])

        expect(board_instance).to receive(:place_piece).once
        test_game.play()
        expect(test_game.instance_variable_get(:@turn)).to eql(false)
      end
    end

    context("when input is ['a2', 'a3'], and is a invalid piece-placing move") do
      it("executes board.place_piece but does not update the turn") do
        allow(board_instance).to receive(:game_over?).and_return([false, nil], [true, 'W'])
        allow(board_instance).to receive(:place_piece).and_return(false)
        allow(test_game).to receive(:get_user_input).and_return(['a2','a3'])

        expect(board_instance).to receive(:place_piece).once
        test_game.play()
        expect(test_game.instance_variable_get(:@turn)).to eql(true)
      end
    end
  end

  describe("#get_user_input") do
    context("when curr player is player1 with 'W' ") do
      it("prints correct player's name ") do
        allow(test_game).to receive(:get_curr_player).and_return(player1)
        allow(test_game).to receive(:gets).and_return('q')

        expect(test_game).to receive(:puts).with("\e[5;30;47mPlayer_1's turn. You can enter:\e[0m").once()
        expect(test_game).to receive(:puts).exactly(4).times
        test_game.get_user_input()
      end
    end

    context("when curr player is player2 with 'B' ") do
      it("prints correct player's name ") do
        allow(test_game).to receive(:get_curr_player).and_return(player2)
        allow(test_game).to receive(:gets).and_return('q')

        expect(test_game).to receive(:puts).with("\e[5;37;40mPlayer_2's turn. You can enter:\e[0m").once()
        expect(test_game).to receive(:puts).exactly(4).times
        test_game.get_user_input()
      end
    end

    context("when input is save/q/castling ") do
      it("return 'save'/'q'/'castling' ") do
        allow(test_game).to receive(:get_curr_player).and_return(player1)
        allow(test_game).to receive(:gets).and_return('Q', 'sAVe', 'Castling')
        allow(test_game).to receive(:puts)

        expect(test_game.get_user_input()).to eql('q')
        expect(test_game.get_user_input()).to eql('save')
        expect(test_game.get_user_input()).to eql('castling')
      end
    end

    context("when input is 'a2' and 'A3 ") do
      it("return ['a2', 'a3'] ") do
        allow(test_game).to receive(:get_curr_player).and_return(player1)
        allow(test_game).to receive(:gets).and_return('a2', 'A3')
        allow(test_game).to receive(:puts)

        expect(test_game.get_user_input()).to eql(['a2', 'a3'])
      end
    end

    context("when input is 'a2', 'r', 'a1', 'A3 ") do
      it("return ['a1', 'a3'] ") do
        allow(test_game).to receive(:get_curr_player).and_return(player1)
        allow(test_game).to receive(:gets).and_return('a2', 'r', 'a1', 'A3')
        allow(test_game).to receive(:puts)

        expect(test_game.get_user_input()).to eql(['a1', 'a3'])
      end
    end

  end


  describe("#get_user_input_for_rook") do
    context("when input is valid as regex ") do
      it("returns loc ['a3'] ") do
        allow(test_game).to receive(:gets).and_return('A3')
        expect(test_game.get_user_input_for_rook).to eql(['a3'])
      end
    end
    context("when input is r to cancel ") do
      it("returns loc ['r'] ") do
        allow(test_game).to receive(:gets).and_return('R')
        expect(test_game.get_user_input_for_rook).to eql(['r'])
      end
    end
  end

  describe("#get_curr_player") do
    context("when triggers") do
      it("returns correct player") do
        expect(test_game.get_curr_player).to equal(player1)
        test_game.instance_variable_set(:@turn, false)
        expect(test_game.get_curr_player).to equal(player2)
      end
    end
  end

  describe("#translate") do
    context("when user_input is ['A2', 'A3']") do
      it("returns [[6,0], [5,0]]") do
        expect(test_game.translate(['A2', 'A3'])).to eql([[6,0],[5,0]])
      end
    end
    context("when user_input is ['A8', 'h1']") do
      it("returns [[0,0], [7,7]]") do
        expect(test_game.translate(['A8', 'h1'])).to eql([[0,0], [7,7]])
      end
    end
  end

  describe("#translate_reverse") do
  context("when user_input is [[6,0], [5,0]]") do
    it("returns ['A2', 'A3']") do
      expect(test_game.translate_reverse([[6,0], [5,0]])).to eql(['A2', 'A3'])
    end
  end
  context("when user_input is [[0,0], [7,7]]") do
    it("returns ['A8', 'H1']") do
      expect(test_game.translate_reverse([[0,0], [7,7]])).to eql(['A8', 'H1'])
    end
  end
end

  describe("#save_game") do
    # no needa test standard lib
  end

  describe("#load_saved") do
  # no needa test standard lib
  end

  describe("#print_end_game_status") do
    context("when player 1 is winning") do
      it("prints winning message with player1's name") do
        allow(board_instance).to receive(:game_over?).and_return [nil, 'W']
        expect(test_game).to receive(:puts).with("\e[0;33;49mGame Ended\e[0m").once()
        expect(test_game).to receive(:puts).with("\e[0;33;49mCheck Mate! Player_1 has won!\e[0m").once()
        test_game.print_end_game_status()
      end
    end

    context("when player 2 is winning") do
      it("prints winning message with player2's name") do
        allow(board_instance).to receive(:game_over?).and_return [nil, 'B']
        expect(test_game).to receive(:puts).with("\e[0;33;49mGame Ended\e[0m").once()
        expect(test_game).to receive(:puts).with("\e[0;33;49mCheck Mate! Player_2 has won!\e[0m").once()
        test_game.print_end_game_status()
      end
    end
  end

  describe("#print_under_check_msg") do
    context("when player 1 being checked") do
      it("prints message for player1 being checked!") do
        allow(board_instance).to receive(:player_king_been_checked?).and_return(true, false)
        
        expect(test_game).to receive(:puts).with("\e[0;31;49m##############################\e[0m").twice()
        expect(test_game).to receive(:puts).with("\e[0;31;49m   Player_1 being checked !\e[0m").once()
        test_game.print_under_check_msg()
      end
    end

    context("when player 2 being checked") do
      it("prints message for player2 being checked!") do
        allow(board_instance).to receive(:player_king_been_checked?).and_return(false, true)
        
        expect(test_game).to receive(:puts).with("\e[0;31;49m##############################\e[0m").twice()
        expect(test_game).to receive(:puts).with("\e[0;31;49m   Player_2 being checked !\e[0m").once()
        test_game.print_under_check_msg()
      end
    end
  end

end
