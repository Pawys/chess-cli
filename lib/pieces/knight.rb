require_relative '../piece'
class Knight < Piece
  def get_possible_moves()
    @possible_moves = []
    [-1, 1].each do |i|
      [-2, 2].each do |j|
        move = "#{(@file.ord + i).chr}#{@rank + j}"
        @possible_moves.push(move) if evaluate_move(move) != 'impossible_move'
        move = "#{(@file.ord + j).chr}#{@rank + i}"
        @possible_moves.push(move) if evaluate_move(move) != 'impossible_move'
      end
    end
    sort_moves()
  end

  def white_icon
    '♘'
  end

  def black_icon
    '♞'
  end
end
