require_relative 'chessboard'
class Chess
  def initialize()
    @player_one
    @player_two
    @current_player
  end
  def choose_color
    colors = { "♟︎" => "black", " ♙" => "white" }.to_a.shuffle
    puts "Choose a hand"
    display_hands("🤚", "🤚")
    
    choice = gets.chomp.to_i
    selected_color = choice == 1 ? colors[0] : colors[1]
    
    puts "You will be playing with the #{selected_color[1]} pieces."
    display_hands(colors[0][0], colors[1][0])
  end
  
  def display_hands(first_hand, second_hand)
    puts ' 1   2'
    puts " #{first_hand}  #{second_hand}"
    puts ''
  end
  
end
chess = Chess.new()
chess.choose_color