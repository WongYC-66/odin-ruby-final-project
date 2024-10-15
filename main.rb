require 'yaml'
require_relative "lib/game"

puts "##### Welcome to New Game #####"
puts "Player 1's side is at bottom"
puts "Player 2's side is at top"
puts "Enter"
puts "-- Y --  for new game"
puts "-- N --  for saved game"

user_input = gets.chomp.upcase
until user_input == 'Y' || user_input == 'N'
  puts "Invalid"
  user_input = gets.chomp.upcase
end

if user_input == 'Y'
  new_game = Game.new
  new_game.play
else
  if File.exist?("./saved/save.yaml")
    saved_game = Game.load_saved()
    saved_game.play
  else
    puts "No saved game, create new game instead."
    new_game = Game.new
    new_game.play
  end

end
