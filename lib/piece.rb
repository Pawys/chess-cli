class Piece
  attr_accessor :position, :possible_moves, :has_moved, :color
  def initialize(position,color,board)
    @position = position
    @file = position[0]
    @rank = position[1].to_i
    @color = color
    @possible_moves = []
    @has_moved = false
    @board = board
  end
  def move(position)
    @position = position
    @file = position[0]
    @rank = position[1].to_i
    @has_moved = true
    get_possible_moves()
  end
  def evaluate_move(move)
    return 'impossible_move' if !(1..8).to_a.include?(move[-1].to_i) || !('a'..'h').to_a.include?(move[-2])
    square = @board.chessboard[move]
    return 'possible_move' unless square.is_occupied?
    return 'capture' if square.occupying_piece.color != @color
    'impossible_move'
  end
  def add_moves(move_patterns)
    move_patterns.each do |move_pattern|
      move_pattern[:rank_moves].each_with_index do |r,index|
        move = "#{move_pattern[:file_moves][index]}#{r}"
        move_type = evaluate_move(move)
        break if move_type == 'impossible_move'
        @possible_moves << move 
        break if move_type == "capture"
      end
    end
    sort_moves()
  end
  def sort_moves()
    @possible_moves = @possible_moves.sort
  end
end
