require_relative '../piece'
class Rook < Piece
  def possible_moves()
    move_patterns = [
      {rank_moves: (@rank + 1..8).to_a, file_moves: Array.new(8,@file)},              # Upwards vertical
      {rank_moves: (1...@rank).to_a.reverse, file_moves: Array.new(8,@file)},         # Downwards vertical
      {file_moves: ('a'...@file).to_a.reverse, rank_moves: Array.new(8,@rank) },      # Left horizontal
      {file_moves: ((@file.next)..'h').to_a,rank_moves: Array.new(8,@rank) }          # Right horizontal
    ]
    possible_move_patterns(move_patterns).sort
  end

  def white_icon
    '♖'
  end

  def black_icon
    '♜'
  end
end
