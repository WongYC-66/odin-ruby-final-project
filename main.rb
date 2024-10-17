require 'yaml'
require 'colorize'
require_relative "lib/game"

puts "##### Welcome to New Game #####".yellow
puts "Player 1's side is at bottom".black.on_white.blink
puts "Player 2's side is at top".white.on_black.blink 
puts "Enter"
puts "-- Y --   for new game"
puts "-- AI --  for new game to vs AI(basic)"
puts "-- N --   for saved game"

user_input = gets.chomp.upcase
until user_input == 'Y' || user_input == 'N' || user_input == 'AI'
  puts "Invalid"
  user_input = gets.chomp.upcase
end

if user_input == 'Y'
  new_game = Game.new
  new_game.play
elsif user_input == 'AI'
  new_game = Game.new(is_Ai: true)
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
