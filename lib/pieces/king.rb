require_relative '../piece'
class King < Piece
  attr_accessor :in_check
  def initialize(position,color,board)
    @in_check = false
    super(position,color,board)
  end
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
    check_castle()
    sort_moves()
  end
  def evaluate_move(move)
    move_type = super(move)
    @board.pieces.each do |piece|
      next if piece.color == color
      return 'impossible_move' if piece.possible_moves.include?(move)
    end
    move_type
  end
  def check_castle()
    return if @has_moved
    #check O-O
    [3,-4].each do |pos|
      rook = @board.chessboard["#{(@file.ord + pos).chr}#{@rank}"]&.occupying_piece
      squares = []
      if rook.class == Rook && !rook.has_moved
        if pos.positive?
          (pos-1).times do |i|
            squares << @board.chessboard["#{(@file.ord + 1 + i).chr}#{@rank}"]
          end
          if squares.all? {|s| !s.is_occupied?}
            @possible_moves << 'O-O'
          end
        else
          (pos.abs-1).times do |i|
            squares << @board.chessboard["#{(@file.ord - 1 - i).chr}#{@rank}"]
          end
          if squares.all? {|s| !s.is_occupied?}
            @possible_moves << 'O-O-O'
          end
        end
      end
    end
  end
end