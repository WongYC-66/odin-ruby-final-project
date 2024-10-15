require_relative "lib/board"

new_board = Board.new
new_board.print_board
# p new_board.game_over?
p new_board.place_piece([6,0], [5,0])
new_board.print_board
p new_board.whose_piece?(6, 0)

