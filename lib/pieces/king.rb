require_relative '../piece'
class King < Piece
  attr_accessor :in_check
  def initialize(position,color,board)
    @in_check = false
    super(position,color,board)
  end
  def possible_moves()
    [normal_moves,castle_moves].flatten.compact.sort
  end
  def normal_moves()
    normal_moves = []
    move_patterns = [
      [1, 0], [-1, 0], [0, 1], [0, -1], # horizontal and vertical moves
      [1, 1], [1, -1], [-1, 1], [-1, -1] # diagonal moves
    ]
    move_patterns.each do |direction|
      move = "#{(@file.ord + direction[0]).chr}#{@rank + direction[1]}"
      next if evaluate_move(move) == 'impossible_move'
      normal_moves << move
    end
    normal_moves
  end
  def castle_moves()
    return if @has_moved
    castle_moves = []
    #check O-O
    [3,-4].each do |pos|
      rook = @board.chessboard["#{(@file.ord + pos).chr}#{@rank}"]
      pieces = []
      if rook.class == Rook && !rook.has_moved
        if pos.positive?
          (pos-1).times do |i|
            pieces << @board.chessboard["#{(@file.ord + 1 + i).chr}#{@rank}"]
          end
          if pieces.all? {|p| p.nil?}
            castle_moves << 'O-O'
          end
        else
          (pos.abs-1).times do |i|
            pieces << @board.chessboard["#{(@file.ord - 1 - i).chr}#{@rank}"]
          end
          if pieces.all? {|p| p.nil?}
            castle_moves << 'O-O-O'
          end
        end
      end
    end
    castle_moves
  end
  def in_check?()
    @board.pieces.each do |piece|
      next if piece.color == @color
      if piece.possible_moves.include?(@position)
        return true
      end
    end
    false
  end
  def white_icon
    '♔'
  end

  def black_icon
    '♚'
  end
end