require_relative "lib/game"

puts "##### Welcome to New Game #####"
puts "Player 1's side is at bottom"
puts "Player 2's side is at top"
new_game = Game.new()
new_game.play()
