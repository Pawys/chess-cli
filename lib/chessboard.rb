require_relative 'square'
require_relative 'pieces/pawn'
require_relative 'pieces/rook'
require_relative 'pieces/knight'
require_relative 'pieces/bishop'
require_relative 'pieces/queen'
require_relative 'pieces/king'
class Chessboard
  BOARD_SIZE = 8
  FILES = ('a'..'h').to_a
  RANKS = (1..8).to_a
  INITIAL_POSITIONS = {
    'a' => ['rook', 'rook'],
    'b' => ['knight', 'knight'],
    'c' => ['bishop', 'bishop'],
    'd' => ['queen', 'queen'],
    'e' => ['king', 'king'],
    'f' => ['bishop', 'bishop'],
    'g' => ['knight', 'knight'],
    'h' => ['rook', 'rook']
  }
  attr_accessor :chessboard
  def initialize()
    @chessboard = Hash.new()
    create_board()
  end
  def create_board()
    FILES.each do |file|
      RANKS.each do |rank|
        position = "#{file}#{rank}"
        occupying_piece = nil
        if rank == 2
          occupying_piece = Pawn.new(position, 'white',self)
        elsif rank == 7
          occupying_piece = Pawn.new(position, 'black',self)
        elsif rank == 1
          occupying_piece = Pawn.new(position, 'white',self)
        elsif rank == 8
          occupying_piece = Pawn.new(position, 'black',self)
        end
        @chessboard[position] = Square.new(position, occupying_piece)
      end
    end
  end
  def print_board
    RANKS.reverse.each do |rank|
      FILES.each do |file|
        position = "#{file}#{rank}"
        print "#{@chessboard[position].to_s} "
      end
    puts ''
    end
  end
end
