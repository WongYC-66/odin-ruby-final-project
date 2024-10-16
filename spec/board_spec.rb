require_relative "../lib/board.rb"
require_relative "../lib/player.rb"
require_relative "../lib/piece.rb"

describe Board do

  let(:test_board) {
    Board.new(
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
    )
  }
  subject(:player1) {instance_double(Player)}
  subject(:player2) {instance_double(Player)}
  subject(:dummy_piece_W1) {instance_double(Pawn)}
  subject(:dummy_piece_B1) {instance_double(Pawn)}
  subject(:dummy_piece_B2) {instance_double(Pawn)}
  subject(:dummy_piece_B3) {instance_double(Pawn)}

  before do
    allow(player1).to receive(:color).and_return('W')
    allow(player2).to receive(:color).and_return('B')
    allow(dummy_piece_W1).to receive(:color).and_return('W')
    allow(dummy_piece_B1).to receive(:color).and_return('B')
    allow(dummy_piece_B2).to receive(:color).and_return('B')
    allow(dummy_piece_B3).to receive(:color).and_return('B')
    allow(dummy_piece_W1).to receive(:to_s).and_return('&')
    allow(dummy_piece_B1).to receive(:to_s).and_return('#')
    allow(dummy_piece_B2).to receive(:to_s).and_return('#')
    allow(dummy_piece_B3).to receive(:to_s).and_return('#')
  end

  describe "#initialize" do
    # straight forward, no needa test
  end

  describe "#new_board" do
    # straight forward, no needa test atm, maybe test if can import Each Piece class later
  end

  describe "#print_board" do
    # no needa test ruby built in lib.
  end

  describe "#place_piece" do
    subject(:test_board) {
      Board.new(
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
      )
    }
    
    context "when place is valid" do
      it("updates the board and return true") do
        allow(test_board).to receive(:whose_piece?).and_return 'W'
        allow(test_board).to receive(:valid_move?).and_return true
        allow(test_board).to receive(:own_king_checked_after_placed?).and_return false
        
        original_piece = test_board.board[6][0]
        res = test_board.place_piece([6, 0], [4, 0], player1)
        expect(res).to eql(true)
        expect(test_board.board[4][0]).to equal(original_piece)
        expect(test_board.board[6][0]).to eql(nil)
      end
    end

    context "when place is invalid / not own piece / cause king under checked" do
      it("does not update the board and return false") do
        allow(test_board).to receive(:whose_piece?).and_return 'W'
        allow(test_board).to receive(:valid_move?).and_return false
        allow(test_board).to receive(:own_king_checked_after_placed?).and_return false

        original_piece = test_board.board[6][0]
        res = test_board.place_piece([6, 0], [5, 1], player1)
        expect(res).to eql(false)
        expect(test_board.board[6][0]).to equal(original_piece)
        expect(test_board.board[5][1]).to_not eql(original_piece)
      end
    end
  end

  describe "#whose_piece?" do
    context "when loc is Black pawn" do
      it("return 'B'") do
        expect(test_board.whose_piece?(0, 0)).to eql('B')        
      end
    end

    context "when loc is White pawn" do
      it("return 'B'") do
        expect(test_board.whose_piece?(7, 0)).to eql('W')        
      end
    end

    context "when loc is has no pece" do
      it("return nil") do
        expect(test_board.whose_piece?(4, 0)).to eql(nil)        
      end
    end
  end

  describe "#valid_move?" do
    # no needa test, test each fn individually
  end

  describe "#can_take?" do
    subject(:test_board) {
        Board.new(
          [
            Array.new(8) { dummy_piece_B1 },
            Array.new(8) { dummy_piece_B1 },
            Array.new(8) { nil },
            Array.new(8) { nil },
            Array.new(8) { nil },
            Array.new(2) { nil } + [ dummy_piece_B1 ] + Array.new(5) { nil },
            Array.new(8) { dummy_piece_W1 },
            Array.new(8) { dummy_piece_W1 },
          ]
      )
    }
    context "when selected piece can make a move to opposite piece's loc" do
      it("returns true") do
        allow(dummy_piece_W1).to receive(:take_type)
        allow(test_board).to receive(:find_reachable_pos).and_return [[5, 2]]
        expect(test_board.can_take?([7, 1], [5, 2])).to eql(true)
      end
    end

    context "when selected piece cannot make move to opposite piece's loc" do
      it("returns false") do
        allow(dummy_piece_W1).to receive(:take_type)
        allow(test_board).to receive(:find_reachable_pos).and_return []
        expect(test_board.can_take?([7, 1], [0, 2])).to eql(false)
      end
    end

    context "when given input locations has no piece" do
      it("returns false") do
        allow(dummy_piece_W1).to receive(:take_type)
        allow(test_board).to receive(:find_reachable_pos).and_return [[5, 2]]
        expect(test_board.can_take?([4, 1], [5, 2])).to eql(false)
      end
    end

    context "when both pieces are same color" do
      it("returns false") do
        allow(dummy_piece_W1).to receive(:take_type)
        allow(test_board).to receive(:find_reachable_pos).and_return [[7, 1]]
        expect(test_board.can_take?([7, 0], [7, 1])).to eql(false)
      end
    end
  end

  describe "#can_move?" do
    # same as can_take?, no needa test
  end

  describe "#find_reachable_pos" do
    # no needa test, test each fn individually
  end

  describe "#exclude_pos_of_own_piece" do
    context("when pos array has piece of same color") do
      it("returns array filtered out those") do
        pos = [[6, 0], [7, 1]]
        expect(test_board.exclude_pos_of_own_piece(pos, [7, 0])).to eql([])
      end
    end

    context("when pos array has piece of diff color") do
      it("does not remove opposite pos out") do
        pos = [[1, 0], [7, 1]]
        expect(test_board.exclude_pos_of_own_piece(pos, [7, 0])).to eql([[1, 0]])
      end
    end
  end

  describe "#verify_options" do
    context("when gives vector options and loc ") do
      it("only returns locations in bound, e.g. king at top row only left, bottom, right") do
        options = [[0, -1], [0, +1], [+1, 0], [-1, 0]]  # left, right, bottom, top
        from = [0,2]
        expect(test_board.verify_options(options, from)).to eql([[0,1], [0,3], [1,2]])
      end
    end
  end
  
  describe "#valid_loc?" do
    context("when both row and col index are in bound") do
      it("returns true") do
        expect(test_board.valid_loc?(5,5)).to eql(true)
      end
    end
    context("when either row and col index is out of bound") do
      it("returns false") do
        expect(test_board.valid_loc?(5,10)).to eql(false)
      end
    end
  end

  describe "#verify_options_path" do
    context("when gives vector options and loc, and NOT to include first real piece") do
      it("only returns path in bound") do
        options = [[0, -1], [0, +1], [+1, 0], [-1, 0]]  # left, right, bottom, top
        from = [4, 1]
        expected_paths = [
          [4,0], 
          [4,2],[4,3],[4,4],[4,5],[4,6],[4,7],
          [5,1],
          [3,1],[2,1]
        ]
        expect(test_board.verify_options_path(options, from, [], false)).to eql(expected_paths)
      end
    end

    context("when gives vector options and loc, and to include first real piece") do
      it("returns path in bound, and include the first piece blocking the path") do
        options = [[0, -1], [0, +1], [+1, 0], [-1, 0]]  # left, right, bottom, top
        from = [4, 1]
        expected_paths = [
          [4,0], 
          [4,2],[4,3],[4,4],[4,5],[4,6],[4,7],
          [5,1],[6,1],
          [3,1],[2,1], [1,1]
        ]
        expect(test_board.verify_options_path(options, from, [], true)).to eql(expected_paths)
      end
    end
  end

  describe "#game_over?" do
    # will test the individual fn separately
    # only test the magic logics, mocks the unimportant
    let(:copied_board) {}
    before do
      allow(dummy_piece_W1).to receive(:take_type)
      allow(dummy_piece_B1).to receive(:take_type)
    end
    context("when player1 king is check-mated") do
      it("return [true, 'B']") do
        # mock P1 to lose
        allow(test_board).to receive(:get_all_pieces_by_player).and_return([[[0,0], dummy_piece_W1]], [[[0,7], dummy_piece_B1]])
        allow(test_board).to receive(:find_reachable_pos).and_return([[0,0], [1,0], [2,0]])
        allow(test_board).to receive(:clone_board).and_return(copied_board)
        allow(copied_board).to receive(:own_king_checked_after_placed?).and_return(true, true, true)
        expect(test_board.game_over?(player1, player2)).to eql([true, 'B'])
      end
    end

    context("when player2 king is check-mated") do
      it("return [true, 'A']") do
        # mock P2 to lose
        allow(test_board).to receive(:get_all_pieces_by_player).and_return([[[0,0], dummy_piece_W1]], [[[0,7], dummy_piece_B1]])
        allow(test_board).to receive(:find_reachable_pos).and_return([[0,0], [1,0], [2,0]])
        allow(test_board).to receive(:clone_board).and_return(copied_board)
        allow(copied_board).to receive(:own_king_checked_after_placed?).and_return(false, false, false, true, true, true)
        expect(test_board.game_over?(player1, player2)).to eql([true, 'W'])
      end
    end

    context("nobody is checkmate") do
      it("return [false, nil]") do
        # mock P2 to lose
        allow(test_board).to receive(:get_all_pieces_by_player).and_return([[[0,0], dummy_piece_W1]], [[[0,7], dummy_piece_B1]])
        allow(test_board).to receive(:find_reachable_pos).and_return([[0,0], [1,0], [2,0]])
        allow(test_board).to receive(:clone_board).and_return(copied_board)
        allow(copied_board).to receive(:own_king_checked_after_placed?).and_return(false, true, false)
        expect(test_board.game_over?(player1, player2)).to eql([false, nil])
      end
    end
  end

  describe "#check_pawn_move_rules" do
    #no needa test test fn individually
  end

  describe "#check_if_promote" do
    subject(:test_board) {
      Board.new(
        [
          Array.new(2) { nil } + [ dummy_piece_W1 ] + Array.new(5) { nil },
          Array.new(8) { nil },
          Array.new(8) { nil },
          Array.new(8) { nil },
          Array.new(8) { nil },
          Array.new(8) { nil },
          Array.new(8) { dummy_piece_W1 },
          Array.new(8) { dummy_piece_W1 },
        ]
      )
    }
    context("when pawn at last row, and user enter 'queen'") do
      it("promotes that piece to Queen having same color of pawn") do
        allow(test_board).to receive(:print_board)
        allow(test_board).to receive(:puts)
        allow(test_board).to receive(:get_input_for_promote).and_return "queen"

        original_piece = test_board.board[0][2]
        test_board.check_if_promote(test_board.board[0][2], 0, 2)
        expect(test_board.board[0][2]).to_not eq(original_piece)
        expect(test_board.board[0][2].type).to eq("Queen")
        expect(test_board.board[0][2].color).to eq("W")
      end
    end 
  end

  describe "#get_input_for_promote" do
    context("when input is same as specified in regex") do
      it("returns 'knight','queen', 'bishop' or 'rook'") do
        allow(test_board).to receive(:gets).and_return("knight\n", "queen\n")
        expect(test_board.get_input_for_promote).to eql("knight")
        expect(test_board.get_input_for_promote).to eql("queen")
      end
    end
  end

  describe "#give_opposite_pawn_en_passant" do
    subject(:test_board) {
      Board.new(
        [
          Array.new(8) { nil },
          Array.new(8) { nil },
          Array.new(8) { nil },
          Array.new(1) { nil } + [ dummy_piece_W1, dummy_piece_W1] +  Array.new(5) { nil },
          Array.new(1) { nil } + [ dummy_piece_B1, dummy_piece_W1, dummy_piece_B2] +  Array.new(4) { nil },
          Array.new(8) { nil },
          Array.new(8) { nil },
          Array.new(8) { nil },
        ]
      )
    }
    context("when nearby piece is a opposite pawn") do
      it("selects and calls opposite pawn's add_en_passant") do
        allow(dummy_piece_W1).to receive(:add_en_passant)
        allow(dummy_piece_B1).to receive(:add_en_passant)
        allow(dummy_piece_B2).to receive(:add_en_passant)
        allow(dummy_piece_W1).to receive(:type).and_return 'Pawn'
        allow(dummy_piece_B1).to receive(:type).and_return 'Pawn'
        allow(dummy_piece_B2).to receive(:type).and_return 'Knight'

        expect(dummy_piece_B1).to receive(:add_en_passant).once()
        expect(dummy_piece_B2).to receive(:add_en_passant).at_most(0).times

        test_board.give_opposite_pawn_en_passant(dummy_piece_W1, 4, 2)
      end
    end

    context("when nearby piece is has same color") do
      it("does nothing") do
        allow(dummy_piece_W1).to receive(:add_en_passant)
        allow(dummy_piece_W1).to receive(:type).and_return 'Pawn'

        expect(dummy_piece_B2).to receive(:add_en_passant).exactly(0).times

        test_board.give_opposite_pawn_en_passant(dummy_piece_W1, 3, 2)
      end
    end
  end

  describe "#check_kill_the_en_passant_pawn" do
    subject(:test_board) {
      Board.new(
        [
          Array.new(8) { nil },
          Array.new(8) { nil },
          Array.new(2) { nil } + [dummy_piece_W1] +  Array.new(5) { nil },
          Array.new(2) { nil } + [dummy_piece_B1] +  Array.new(5) { nil },
          Array.new(8) { nil },
          Array.new(8) { nil },
          Array.new(8) { nil },
          Array.new(8) { nil },
          Array.new(8) { nil },
        ]
      )
    }
    context("when a Pawn moves diagonally and into behind a opposite pawn with 'en_passant rule'") do
      it("triggers method of remove_from_board") do
        allow(dummy_piece_W1).to receive(:killable_pawn_by_en_passant).and_return(dummy_piece_B1)
        allow(test_board).to receive(:remove_from_board)
        expect(test_board).to receive(:remove_from_board).with(dummy_piece_B1).once()
        test_board.check_kill_the_en_passant_pawn(dummy_piece_W1, 2, 2)
      end
    end
  end

  describe "#remove_from_board" do
    context("when triggers") do
      it("make the board[r][c] to nil") do
        original_piece = test_board.board[0][0]        
        test_board.remove_from_board(original_piece)
        expect(test_board.board[0][0]).to eql(nil)
      end
    end
  end

  describe "#reset_pawn_en_passant_killable" do
    subject(:test_board) {
      Board.new(
        [
          Array.new(8) { nil },
          Array.new(8) { dummy_piece_B1 },
          Array.new(8) { nil },
          Array.new(8) { nil },
          Array.new(8) { dummy_piece_B2 },
          Array.new(8) { nil },
          Array.new(8) { dummy_piece_W1 },
          Array.new(8) { nil },
        ]
      )
    }
    context("when triggers") do
      it("only selects pawn-type pieces to call method") do
        allow(dummy_piece_W1).to receive(:type).and_return ('Pawn')
        allow(dummy_piece_B1).to receive(:type).and_return ('Pawn')
        allow(dummy_piece_B2).to receive(:type).and_return ('Knight')
        allow(dummy_piece_W1).to receive(:delete_en_passant)
        allow(dummy_piece_B1).to receive(:delete_en_passant)
        allow(dummy_piece_B2).to receive(:delete_en_passant)
        expect(dummy_piece_W1).to receive(:delete_en_passant).exactly(8).times
        expect(dummy_piece_B1).to receive(:delete_en_passant).exactly(8).times
        expect(dummy_piece_B2).to receive(:delete_en_passant).exactly(0).times
        test_board.reset_pawn_en_passant_killable()
      end
    end
  end

  describe "#castling" do
    subject(:test_board) {
      Board.new(
        [
          [dummy_piece_B1] + Array.new(3) { nil } + [dummy_piece_B2] + Array.new(2) { nil } + [dummy_piece_B3],
          Array.new(8) { nil },
          Array.new(8) { nil },
          Array.new(8) { nil },
          Array.new(8) { nil },
          Array.new(8) { nil },
          Array.new(8) { nil },
          Array.new(8) { nil },
        ]
      )
    }
    context("when the selected rook is moved") do
      it("return false") do
        allow(test_board).to receive(:whose_piece?).and_return('B')
        allow(dummy_piece_B1).to receive(:type).and_return('Rook')
        allow(dummy_piece_B2).to receive(:type).and_return('King')
        allow(dummy_piece_B1).to receive(:moved).and_return(true)
        allow(dummy_piece_B2).to receive(:moved).and_return(false)
        expect(test_board.castling([[0, 0]], player2)).to eql(false)
      end
    end

    context("when the selected king is moved") do
      it("return false") do
        allow(test_board).to receive(:whose_piece?).and_return('B')
        allow(test_board).to receive(:get_player_king_piece).and_return([0,4,dummy_piece_B2])
        allow(dummy_piece_B2).to receive(:type).and_return('King')
        allow(dummy_piece_B3).to receive(:type).and_return('Rook')
        allow(dummy_piece_B2).to receive(:moved).and_return(true)
        allow(dummy_piece_B3).to receive(:moved).and_return(false)
        expect(test_board.castling([[0, 7]], player2)).to eql(false)
      end
    end

    context("when there is other piece within castling path") do
      it("return false") do
        allow(test_board).to receive(:whose_piece?).and_return('B')
        allow(test_board).to receive(:get_player_king_piece).and_return([0,4,dummy_piece_B2])
        allow(test_board).to receive(:generate_path).and_return([[0,4],[0,5],[0,6],[0,7]])
        allow(dummy_piece_B2).to receive(:type).and_return('King')
        allow(dummy_piece_B3).to receive(:type).and_return('Rook')
        allow(dummy_piece_B2).to receive(:moved).and_return(false)
        allow(dummy_piece_B3).to receive(:moved).and_return(false)
        test_board.board[0][6] = dummy_piece_B3 # extra in the path
        expect(test_board.castling([[0, 7]], player2)).to eql(false)
      end
    end

    context("when the castling path is under attacked, inclusive of king & rook") do
      it("return false") do
        allow(test_board).to receive(:whose_piece?).and_return('B')
        allow(test_board).to receive(:get_player_king_piece).and_return([0,4,dummy_piece_B2])
        allow(test_board).to receive(:generate_path).and_return([[0,4],[0,5],[0,6],[0,7]])
        allow(test_board).to receive(:generate_opposite_attacking_loc).and_return([[0,5]])
        
        allow(dummy_piece_B2).to receive(:type).and_return('King')
        allow(dummy_piece_B3).to receive(:type).and_return('Rook')
        allow(dummy_piece_B2).to receive(:moved).and_return(false)
        allow(dummy_piece_B3).to receive(:moved).and_return(false)
        test_board.board[0][6] = dummy_piece_B3 # extra in the path
        expect(test_board.castling([[0, 7]], player2)).to eql(false)
      end
    end

    context("when condition are fullfilled to castle with left rook") do
      subject(:test_board) {
        Board.new(
          [
            [dummy_piece_B1] + Array.new(3) { nil } + [dummy_piece_B2] + Array.new(3) { nil },
            Array.new(8) { nil },
            Array.new(8) { nil },
            Array.new(8) { nil },
            Array.new(8) { nil },
            Array.new(8) { nil },
            Array.new(8) { nil },
            Array.new(8) { nil },
          ]
        )
      }
      it("modifies the board correctly, and return true") do
        allow(test_board).to receive(:whose_piece?).and_return('B')
        allow(test_board).to receive(:get_player_king_piece).and_return([0,4,dummy_piece_B2])
        allow(test_board).to receive(:generate_path).and_return([[0,0],[0,1],[0,2],[0,3],[0,4]])
        allow(test_board).to receive(:generate_opposite_attacking_loc).and_return([[]])
        
        allow(dummy_piece_B1).to receive(:type).and_return('Rook')
        allow(dummy_piece_B2).to receive(:type).and_return('King')
        allow(dummy_piece_B1).to receive(:moved).and_return(false)
        allow(dummy_piece_B2).to receive(:moved).and_return(false)

        expect(test_board.castling([[0, 0]], player2)).to eql(true)
        row = test_board.board[0]
        expect(row[2].type).to eql("King")
        expect(row[3].type).to eql("Rook")
      end
    end
  end

  context("when condition are fullfilled to castle with right rook") do
    subject(:test_board) {
      Board.new(
        [
          Array.new(4) { nil } + [dummy_piece_B2] + Array.new(2) { nil } + [dummy_piece_B1],
          Array.new(8) { nil },
          Array.new(8) { nil },
          Array.new(8) { nil },
          Array.new(8) { nil },
          Array.new(8) { nil },
          Array.new(8) { nil },
          Array.new(8) { nil },
        ]
      )
    }
    it("modifies the board correctly, and return true") do
      allow(test_board).to receive(:whose_piece?).and_return('B')
      allow(test_board).to receive(:get_player_king_piece).and_return([0,4,dummy_piece_B2])
      allow(test_board).to receive(:generate_path).and_return([[0,4],[0,5],[0,6],[0,7]])
      allow(test_board).to receive(:generate_opposite_attacking_loc).and_return([[]])
      
      allow(dummy_piece_B1).to receive(:type).and_return('Rook')
      allow(dummy_piece_B2).to receive(:type).and_return('King')
      allow(dummy_piece_B1).to receive(:moved).and_return(false)
      allow(dummy_piece_B2).to receive(:moved).and_return(false)

      expect(test_board.castling([[0, 7]], player2)).to eql(true)
      row = test_board.board[0]
      expect(row[5].type).to eql("Rook")
      expect(row[6].type).to eql("King")
    end
  end

  describe "#get_player_king_piece" do
    context("when triggers") do
      it("return row,col,King piece of player's color") do
        r1, c1, p1_king = test_board.get_player_king_piece(player1)
        r2, c2, p2_king = test_board.get_player_king_piece(player2)
        expect(r1).to eql(7) and expect(c1).to eql(4)
        expect(r2).to eql(0) and expect(c2).to eql(4)
        expect(p1_king.type).to eql('King')
        expect(p2_king.type).to eql('King')
      end
    end
  end

  describe "#generate_path" do
    context("when r1 same as r2") do
      it("return paths from c1 to c2, inclusive") do
        expect(test_board.generate_path(0,0,0,4)).to eql([[0,0],[0,1],[0,2],[0,3],[0,4]])
      end
    end

    context("when r1 diff as r2") do
      it("return []") do
        expect(test_board.generate_path(0,0,7,7)).to eql([])
      end
    end
  end

  describe "#generate_opposite_attacking_loc" do
    # no needa test, built-in, test each fn individually
  end

  describe "#get_all_pieces_by_player" do
    context("when called to get player1") do
      it("returns all piece of player1") do
        pieces = test_board.get_all_pieces_by_player(player1, false)
        expect(pieces.length).to eql(16)
        expect(pieces.all? {|_, piece| piece.color == player1.color}).to eql(true)
      end
    end
    context("when called to get opposite of player1") do
      it("returns all piece of player2") do
        pieces = test_board.get_all_pieces_by_player(player1, true)
        expect(pieces.length).to eql(16)
        expect(pieces.all? {|_, piece| piece.color != player1.color}).to eql(true)
      end
    end
  end

  describe "#own_king_checked_after_placed?" do
    # no needa test, but test individual fn
  end

  describe "#clone_board" do
    context("when triggers") do
      it("return a deep copy of board") do
        copy_board = test_board.clone_board
        expect(copy_board.board.flatten.length).to eql(test_board.board.flatten.length)
        expect(copy_board.board).to_not equal(test_board.board)
        copy_board.board.each_with_index do |row, r|
          expect(test_board.board[r]).to eql(row)  
          expect(test_board.board[r]).to_not equal(row)  
        end
      end
    end
  end

  describe "#update_board_piece" do
    context("when triggers") do
      it("modify the board at correct position and with correct piece") do
        test_board.update_board_piece(4, 4, dummy_piece_B1)
        expect(test_board.board[4][4]).to equal(dummy_piece_B1)
      end
    end
  end
  

  # Template
  describe "#player_king_been_checked?" do
    subject(:test_board) {
      Board.new(
        [
          Array.new(4) { nil } + [dummy_piece_B1] + Array.new(3) { nil },
          Array.new(8) { nil },
          Array.new(8) { nil },
          Array.new(8) { nil },
          Array.new(8) { nil },
          Array.new(8) { nil },
          Array.new(8) { nil },
          Array.new(4) { nil } + [dummy_piece_W1] + Array.new(3) { nil },
        ]
      )
    }
    before do
      allow(test_board).to receive(:get_player_king_piece).and_return([0, 4, nil])
    end

    context("when player's king is checked") do
      it("returns true") do
        allow(test_board).to receive(:generate_opposite_attacking_loc).and_return([[0,4],[1,4],[2,4],[3,4],[4,4],[5,4],[6,4]])
        expect(test_board.player_king_been_checked?(player2, test_board)).to eql(true)
      end
    end

    context("when player's king is not being checked") do
      it("returns false") do
        allow(test_board).to receive(:generate_opposite_attacking_loc).and_return([[4,4],[5,4],[6,4]])
        expect(test_board.player_king_been_checked?(player2, test_board)).to eql(false)
      end
    end
  end

end