class Square
  attr_accessor :position,:occuping_piece
 def initialize(position,occuping_piece = nil) 
   @position = position
   @is_occupied = false
   @occuping_piece = occuping_piece
   @is_occupied = true if @occuping_piece != nil
 end
 def add_piece(piece)
   @occuping_piece = piece
   @is_occupied = true
 end
 def remove_piece()
   @occuping_piece = nil
   @is_occupied = false
 end
 def to_s
   if is_occupied?
     @occuping_piece.color
   else
     @position 
   end
 end
 def inspect
   to_s
 end
 def is_occupied?
   @is_occupied
 end
end
