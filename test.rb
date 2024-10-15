require_relative "lib/board"

new_board = Board.new
new_board.print_board
p new_board.game_over?
p new_board.can_move?([1,0], [2,0])
