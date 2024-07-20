require_relative '../piece'
class King < Piece
  def get_possible_moves()
    @possible_moves = []
    move_patterns = [
      [1, 0], [-1, 0], [0, 1], [0, -1], # horizontal and vertical moves
      [1, 1], [1, -1], [-1, 1], [-1, -1] # diagonal moves
    ]
    move_patterns.each do |direction|
      move = "#{(@file.ord + direction[0]).chr}#{@rank + direction[1]}"
      next if evaluate_move(move) == 'impossible_move'
      @possible_moves << move
    end
    sort_moves()
  end
end