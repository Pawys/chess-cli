class Pawn < Piece
  def get_possible_moves()
    @possible_moves = []
    one_step_move = "#{@file}#{@rank + 1}"
    two_step_move = "#{@file}#{@rank + 2}"
    capture_moves = ["#{@file.next}#{@rank + 1}", # left capture
                     "#{(@file.ord-1).chr}#{@rank + 1}"] # right capture
    unless evaluate_move(one_step_move) == 'impossible_move'
      @possible_moves << one_step_move
      @possible_moves << two_step_move if !@has_moved && evaluate_move(two_step) == 'possible_move'
    end
    capture_moves.each_with_index do |move|
      @possible_moves << move if evaluate_move(move) == 'capture'
    end
  end
end
