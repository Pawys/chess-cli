class Square
  attr_accessor :position,:occupying_piece
 def initialize(position,occupying_piece = nil) 
   @position = position
   @is_occupied = false
   @occupying_piece = occupying_piece
   @is_occupied = true if @occupying_piece != nil
 end
 def add_piece(piece)
   @occupying_piece = piece
   @is_occupied = true
 end
 def remove_piece()
   @occupying_piece = nil
   @is_occupied = false
 end
 def to_s
   if is_occupied?
     @occupying_piece.color
   else
     @position 
   end
 end
 def is_occupied?
   @is_occupied
 end
end
