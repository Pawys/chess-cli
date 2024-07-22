require_relative '../piece'
class Pawn < Piece
  def get_possible_moves()
    @possible_moves = []
    if color == 'black'
      one_step_move = "#{@file}#{@rank - 1}"
      two_step_move = "#{@file}#{@rank - 2}"
    else
      one_step_move = "#{@file}#{@rank + 1}"
      two_step_move = "#{@file}#{@rank + 2}"
    end
    capture_moves = ["#{@file.next}#{@rank + 1}", # left capture
                     "#{(@file.ord-1).chr}#{@rank + 1}"] # right capture
    if evaluate_move(one_step_move)  == 'possible_move'
      @possible_moves << one_step_move
      @possible_moves << two_step_move if !@has_moved && evaluate_move(two_step_move) == 'possible_move'
    end
    capture_moves.each_with_index do |move|
      @possible_moves << move if evaluate_move(move) == 'capture'
    end
    sort_moves()
  end
end
