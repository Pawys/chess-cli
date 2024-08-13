require_relative '../piece'
class Pawn < Piece
  attr_accessor :move_direction
  def initialize(position,color,board)
    @move_direction = color == 'white' ? 1 : -1
    super(position,color,board)
  end
  def get_possible_moves()
    @possible_moves = []
    add_normal_moves()
    add_capture_moves()
    en_passant()
    sort_moves()
  end
  def add_normal_moves()
    one_step_move = "#{@file}#{@rank + @move_direction}"
    two_step_move = "#{@file}#{@rank + (2*@move_direction)}"
    if evaluate_move(one_step_move)  == 'possible_move'
      @possible_moves << one_step_move
      if !@has_moved && evaluate_move(two_step_move) == 'possible_move'
        @possible_moves << two_step_move 
      end
    end
  end
  def add_capture_moves()
    capture_moves = ["#{@file.next}#{@rank + @move_direction}", # left capture
                     "#{(@file.ord-1).chr}#{@rank + @move_direction}"] # right capture
    capture_moves.each_with_index do |move|
      @possible_moves << move if evaluate_move(move) == 'capture'
    end
  end
  def en_passant()
    one_file_left = "#{(self.position[0].ord - 1).chr}#{self.position[1]}"
    one_file_right = "#{self.position[0].next}#{self.position[1]}"
    passant_pawn_pos = @board.last_double_step_pawn&.position
    if passant_pawn_pos == one_file_left || passant_pawn_pos == one_file_right
      @possible_moves << "#{passant_pawn_pos[0]}#{passant_pawn_pos[1].to_i + @move_direction}"
    end
  end
end
