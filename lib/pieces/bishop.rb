class Bishop < Piece
  def get_possible_moves()
    @possible_moves = []
    move_patterns = [
      {file_moves: ('a'...@file).to_a.reverse, rank_moves: (@rank + 1..8)},           # Diagonal up-left
      {file_moves: (@file.next..'h').to_a, rank_moves: (1...@rank).to_a.reverse},     # Diagonal down-right
      {file_moves: (@file.next..'h').to_a, rank_moves: (@rank + 1..8)},               # Diagonal up-right
      {file_moves: ('a'...@file).to_a.reverse, rank_moves: (1...@rank).to_a.reverse}, # Diagonal down-left
    ]
    add_moves(move_patterns)
  end
end
