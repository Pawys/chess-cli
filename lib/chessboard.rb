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
  SAN_NOTATION_LETTERS = {
    'R' => Rook,
    'N' => Knight,
    'B' => Bishop,
    'Q' => Queen,
    'K' => King,
    'O' => King
  }
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
  attr_accessor :chessboard, :pieces, :last_double_step_pawn
  def initialize()
    @moves_pgn = '1. e4 e2 2. e2'
    @pieces = []
    @chessboard = Hash.new()
    @last_double_step_pawn
    create_board()
  end
  def create_board()
    FILES.each do |file|
      RANKS.each do |rank|
        position = "#{file}#{rank}"
        occupying_piece = add_pieces(file,rank,position)
        if occupying_piece != nil
          @pieces << occupying_piece
        end
        @chessboard[position] = Square.new(position, occupying_piece)
      end
    end
    refresh_moves()
  end
  def add_pieces(file,rank,position)
    case rank
    when 1
      occupying_piece = INITIAL_POSITIONS[file].new(position, 'white',self)
      if occupying_piece.class == King
        @white_king = occupying_piece
      end
    when 2
      occupying_piece = Pawn.new(position, 'white',self)
    when 7
      occupying_piece = Pawn.new(position, 'black',self)
    when 8
      occupying_piece = INITIAL_POSITIONS[file].new(position, 'black',self)
      if occupying_piece.class == King
        @black_king = occupying_piece
      end
    end
    occupying_piece
  end
  def refresh_moves()
    @pieces.each {|piece| piece.get_possible_moves}
  end
  # from_san
  def from_san(move,piece_color)
    piece_class = get_piece_class(move)
    capture = get_capture_info(move)
    piece_location = get_piece_location(move,piece_class,capture)
    move_type,des_pos = get_move_type_and_pos(move)
    piece = find_piece(piece_class,piece_color,piece_location,des_pos)
    special_info = get_special_info(move,move_type,piece_class,des_pos,capture)
    [piece,des_pos,move_type,special_info]
  end
  def get_piece_class(move)
    SAN_NOTATION_LETTERS[move[0]] || Pawn
  end
  def get_capture_info(move)
    move.include?("x")
  end
  def get_piece_location(move,piece_class,capture)
    if piece_class == Pawn
      move[0] if capture == true
    else
      if move.length > 3
        if FILES.include?(move[1]) && (FILES.include?(move[2] || move[2] == 'x'))
          move[1]
        elsif RANKS.include?(move[1])
          move[1]
        else
          nil
        end
      end
    end
  end
  def get_move_type_and_pos(move)
    if move[0] == 'O'
      des_pos = move
      move_type = 'castle'
    elsif move.include?('=')
      move_type = 'promotion'
      if move[-1] == "+" || move[-1] == '#'
        des_pos = move[-5..-4]
      else
        des_pos = move[-4..-3]
      end
    else
      case move[-1]
      when '1'..'8'
        des_pos = move[-2..-1]
        move_type = 'move'
      when '+'
        des_pos = move[-3..-2]
        move_type = 'check'
      else
        move_type = 'mate'
        des_pos = move[-3..-2]
      end
    end
    [move_type,des_pos]
  end
  def find_piece(piece_class, piece_color, piece_location, des_pos)
    @pieces.find do |piece|
      next unless piece.color == piece_color && piece.class == piece_class
      next unless piece.possible_moves.include?(des_pos)
      piece_location.nil? || piece.position.include?(piece_location.to_s)
    end
  end
  def get_special_info(move,move_type,piece_class,des_pos,capture)
    if move_type == 'promotion'
      get_promote_piece(move)
    elsif piece_class == Pawn && capture == true
      get_en_passant(des_pos)
    end
  end
  def get_promote_piece(move)
    SAN_NOTATION_LETTERS[move[-1]] || SAN_NOTATION_LETTERS[move[-2]]
  end
  def get_en_passant(des_pos)
    'en_passant' if chessboard[des_pos].occupying_piece == nil
  end
  #move making
  def move(params)
    piece, des_pos, move_type,special_info = params
    return unless valid_move?(piece,des_pos,special_info,move_type)

    player_king = piece.color == 'white' ? @white_king : @black_king

    saved_state = Marshal.dump(@chessboard)

    handle_moves(piece,des_pos,move_type,special_info)
    check_for_check()

    if player_king.in_check
      @chessboard = Marshal.load(saved_state)
    end
  end
  def valid_move?(piece,des_pos,special_info,move_type)
    return false if piece == nil
    if move_type == 'promotion'
      return false if special_info == nil
    end
    piece.possible_moves.include?(des_pos)
  end
  def handle_moves(piece,des_pos,move_type,special_info)
    case move_type
    when 'castle'
      perform_castle(piece,des_pos)
    when 'promotion'
      promote(piece,des_pos,special_info)
    else
      if special_info == 'en_passant'
        perform_en_passant(piece,des_pos)
      else
        perform_move(piece,des_pos)
      end
    end
    refresh_moves()
  end
  def add_piece(piece,des_pos)
    square = chessboard[des_pos]
    if square.is_occupied?
      @pieces.delete(square.occupying_piece)
    end
    square.add_piece(piece)
  end
  def promote(piece,des_pos,promote_piece)
    chessboard[piece.position].remove_piece
    piece = promote_piece.new(des_pos,piece.color,self)
    add_piece(piece,des_pos)
    @pieces.push(piece)
  end
  def perform_move(piece,des_pos)
    @last_double_step_pawn = piece if is_double_pawn_move?(piece,des_pos)
    @chessboard[piece.position].remove_piece()
    add_piece(piece,des_pos)
    piece.move(des_pos)
  end
  def is_double_pawn_move?(piece,des_pos)
    return false if piece.class != Pawn
    piece.position[1].to_i + (2*piece.move_direction) == des_pos[1].to_i
  end
  def perform_en_passant(piece,des_pos)
    @chessboard[piece.position].remove_piece()
    add_piece(piece,des_pos)
    @chessboard["#{des_pos[0]}#{des_pos[1].to_i - piece.move_direction}"].remove_piece()
    piece.move(des_pos)
  end
  def perform_castle(king,castle_type)
    rook,rook_target_pos,king_target_pos = castle_positions(king,castle_type)

    chessboard[king.position].remove_piece()
    chessboard[rook.position].remove_piece()

    chessboard[king_target_pos].add_piece(king)
    chessboard[rook_target_pos].add_piece(rook)
    
    king.move(king_target_pos)
    rook.move(rook_target_pos)
  end
  def castle_positions(king,castle_type)
    if castle_type == 'O-O'
      rook = chessboard["#{(king.position[0].ord + 3).chr}#{king.position[1]}"].occupying_piece

      king_target_pos = "#{king.position[0].next.next}#{king.position[1]}"
      rook_target_pos = "#{king.position[0].next}#{king.position[1]}"
    else
      rook = chessboard["#{(king.position[0].ord - 4).chr}#{king.position[1]}"].occupying_piece

      king_target_pos = "#{rook.position[0].next.next}#{king.position[1]}"
      rook_target_pos = "#{rook.position[0].next.next.next}#{king.position[1]}"
    end
    [rook,rook_target_pos,king_target_pos]
  end
  def check_for_check()
    [@white_king,@black_king].each do |king|
      king.in_check = false
      @pieces.each do |piece|
        next if piece.color == king.color
        if piece.possible_moves.include?(king.position)
          king.in_check = true
          break
        end
      end
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
  def inspect
    'board'
  end
end
chessboard = Chessboard.new()
chessboard.move(chessboard.from_san('a4','white'))
chessboard.move(chessboard.from_san('b6','black'))
chessboard.move(chessboard.from_san('a5','white'))
chessboard.move(chessboard.from_san('a6','black'))
chessboard.move(chessboard.from_san('axb6','white'))
chessboard.move(chessboard.from_san('a5','black'))
chessboard.move(chessboard.from_san('bxc7','white'))
chessboard.move(chessboard.from_san('h6','black'))
chessboard.move(chessboard.from_san('cxb8=Q','white'))
chessboard.move(chessboard.from_san('b5','black'))
chessboard.print_board()