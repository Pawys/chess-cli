require_relative '../piece'
class Pawn < Piece
  attr_accessor :move_direction
  def initialize(position,color,board)
    @move_direction = color == 'white' ? 1 : -1
    super(position,color,board)
  end
  def possible_moves()
    [normal_moves,capture_moves,en_passant_moves].flatten.compact.sort
  end
  def normal_moves()
    one_step_move = "#{@file}#{@rank + @move_direction}"
    two_step_move = "#{@file}#{@rank + (2*@move_direction)}"
    if evaluate_move(one_step_move)  == 'possible_move'
      if !@has_moved && evaluate_move(two_step_move) == 'possible_move'
        return [one_step_move,two_step_move]
      end
      one_step_move
    end
  end
  def capture_moves()
    possible_capture_moves = []
    capture_moves = ["#{@file.next}#{@rank + @move_direction}", # left capture
                     "#{(@file.ord-1).chr}#{@rank + @move_direction}"] # right capture
    capture_moves.each_with_index do |move|
      possible_capture_moves << move if evaluate_move(move) == 'capture'
    end
    possible_capture_moves
  end
  def en_passant_moves()
    possible_en_passant_moves = []
    one_file_left = "#{(self.position[0].ord - 1).chr}#{self.position[1]}"
    one_file_right = "#{self.position[0].next}#{self.position[1]}"
    passant_pawn_pos = @board.last_double_step_pawn&.position
    if passant_pawn_pos == one_file_left || passant_pawn_pos == one_file_right
      possible_en_passant_moves << "#{passant_pawn_pos[0]}#{passant_pawn_pos[1].to_i + @move_direction}"
    end
    possible_en_passant_moves
  end
  
  def white_icon
    '♙'
  end

  def black_icon
    '♟︎'
  end
end
