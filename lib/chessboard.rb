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
    'a' => Rook,
    'b' => Knight,
    'c' => Bishop,
    'd' => Queen,
    'e' => King,
    'f' => Bishop,
    'g' => Knight,
    'h' => Rook
  }
  ICONS = {
    Pawn => {'white' =>'♙','black' =>'♟︎'},
    Knight => {'white' =>'♘','black' =>'♞'},
    Bishop => {'white' =>'♗','black' =>'♝'},
    Rook => {'white' =>'♖','black' =>'♜'},
    Queen => {'white' =>'♕','black' =>'♛'},
    King => {'white' =>'♔','black' =>'♚'}
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
        if rank == 1
          occupying_piece = INITIAL_POSITIONS[file].new(position, 'white',self)
        elsif rank == 2
          occupying_piece = Pawn.new(position, 'white',self)
        elsif rank == 7
          occupying_piece = Pawn.new(position, 'black',self)
        elsif rank == 8
          occupying_piece = INITIAL_POSITIONS[file].new(position, 'black',self)
        end
        @chessboard[position] = Square.new(position, occupying_piece)
      end
    end
  end
  def move(int_pos,des_pos)
    piece = chessboard[int_pos].occupying_piece
    if !(piece == nil)
      piece.get_possible_moves()
      if piece.possible_moves.include?(des_pos)
        piece.move(des_pos)
        chessboard[int_pos].remove_piece()
        chessboard[des_pos].add_piece(piece)
      end
    else
      p 'no piece on square'
    end
  end
  def print_board
    RANKS.reverse.each_with_index do |rank,indx|
      FILES.each do |file|
        if file == 'a'
          print "#{rank}|"
        end
        position = "#{file}#{rank}"
        square = chessboard[position]
        if square.is_occupied?
          print ICONS[square.occupying_piece.class][square.occupying_piece.color]
          print ' '
        else
          print '  '
        end
      end
      puts ''
    end
    puts '  ----------------'
    print ' '
    FILES.each do |file|
      print " #{file}"
    end
    puts ''
  end
end