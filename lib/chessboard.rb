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
  attr_accessor :chessboard, :pieces, :pgn ,:last_double_step_pawn, :white_king, :black_king
  def initialize()
    @pgn = ''
    @current_move_number = 0
    @pieces = []
    @white_pieces = []
    @black_pieces = []
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
          if occupying_piece.color == 'white'
            @white_pieces << occupying_piece
          else
            @black_pieces << occupying_piece
          end
        end
        @chessboard[position] = occupying_piece
      end
    end
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
  def reset()
    @pieces = []
    @current_move_number = 0
    @chessboard = Hash.new()
    @last_double_step_pawn = nil
    @pgn = ''
    create_board()
  end
  def save_to_pgn(move_notation,move_color)
    if move_color == 'white'
      @pgn << "#{@current_move_number}. #{move_notation}"
    else
      @pgn << " #{move_notation} "
    end
  end
  def load_from_pgn(pgn)
    reset()
    clean_pgn = pgn.gsub(/\d\/\d-?|[01]-[01]|\[.*\]/, '')
    @pgn = clean_pgn
    @current_move_number = @pgn.scan(/(\d+)\./).last&.first.to_i
    moves = clean_pgn.gsub(/\d?\d\. ?/,'').strip.split(' ')
    moves.each_with_index do |move,idx|
      color = idx % 2 == 0 ? 'white' : 'black'
      if !move(from_san(move,color))
        p "Error: The move #{move} is incorrect"
        reset()
        break
      end
    end
  end
  # from_san
  def from_san(move,piece_color)
    piece_class = get_piece_class(move)
    capture = get_capture_info(move)
    piece_location = get_piece_location(move,piece_class,capture)
    move_type,des_pos = get_move_type_and_pos(move)
    move_type = 'en_passant' if get_en_passant(des_pos,piece_class,capture)
    piece = find_piece(piece_class,piece_color,piece_location,des_pos)
    special_info = get_special_info(move,move_type,piece_class,des_pos,capture)
    [piece,des_pos,move_type,special_info,move]
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
    end
  end
  def get_promote_piece(move)
    SAN_NOTATION_LETTERS[move[-1]] || SAN_NOTATION_LETTERS[move[-2]]
  end
  def get_en_passant(des_pos,piece_class,capture)
    unless piece_class == Pawn && capture == true
      return false
    end
    'en_passant' if chessboard[des_pos].occupying_piece == nil
  end
  #move makindg
  def stalemate?()
    [@white_pieces,@black_pieces].each do |pieces|
      return true if pieces.all? {|p| p.possible_moves.all? {|m| move2(p.position,m) == false} == true}
    end
  end
  def move2(org_pos,trg_pos)
    piece = chessboard[org_pos]
    if piece.nil?
      p chessboard[org_pos].occupying_piece
      p org_pos,trg_pos
    end

    player_king = piece.color == 'white' ? @white_king : @black_king

    saved_state = Marshal.dump(@chessboard)

    move_type = get_move_type(org_pos,trg_pos,piece)
    handle_moves(piece,trg_pos,move_type,nil)
    check_for_check()

    if player_king.in_check
      @chessboard = Marshal.load(saved_state)
      return false
    end
    true
  end
  def get_move_type(org_pos,trg_pos,piece)
    if trg_pos[0] == "O"
      move_type = 'castle'
    elsif piece.class == Pawn
      if org_pos[0] != trg_pos[0] && chessboard[trg_pos] == nil
        move_type = 'en_passant'
      end
    else 
      move_type = 'normal'
    end
    move_type
  end
  def handle_moves(piece,des_pos,move_type,special_info)
    case move_type
    when 'castle'
      perform_castle(piece,des_pos)
    when 'promotion'
      promote(piece,des_pos,special_info)
    when 'en_passant'
      perform_en_passant(piece,des_pos)
    else
      perform_move(piece,des_pos)
    end
  end
  def move(params)
    piece, des_pos, move_type,special_info,move_notation = params
    return false unless valid_move?(piece,des_pos,special_info,move_type)

    player_king = piece.color == 'white' ? @white_king : @black_king

    saved_state = Marshal.dump(@chessboard)

    handle_moves(piece,des_pos,move_type,special_info)
    check_for_check()

    if player_king.in_check
      @chessboard = Marshal.load(saved_state)
      return false
    end
    if piece.color == 'white'
      @current_move_number += 1
    end
    save_to_pgn(move_notation,piece.color)
  end
  def valid_move?(piece,des_pos,special_info,move_type)
    return false if piece == nil
    if move_type == 'promotion'
      return false if special_info == nil
    end
    piece.possible_moves.include?(des_pos)
  end
  def add_piece(piece,des_pos)
    occupying_piece = chessboard[des_pos]
    if !occupying_piece.nil?
      @pieces.delete(occupying_piece)
    end
    @pieces.push(piece)
    chessboard[des_pos] = piece
  end
  def remove_piece(des_pos)
    occupying_piece = chessboard[des_pos]
    if !occupying_piece.nil?
      @pieces.delete(occupying_piece)
      chessboard[des_pos] = nil
    end
  end
  def promote(piece,des_pos,promote_piece)
    remove_piece(piece.position)
    piece = promote_piece.new(des_pos,piece.color,self)
    add_piece(piece,des_pos)
    @pieces.push(piece)
  end
  def perform_move(piece,des_pos)
    @last_double_step_pawn = piece if is_double_pawn_move?(piece,des_pos)
    remove_piece(piece.position)
    add_piece(piece,des_pos)
    piece.move(des_pos)
  end
  def is_double_pawn_move?(piece,des_pos)
    return false if piece.class != Pawn
    piece.position[1].to_i + (2*piece.move_direction) == des_pos[1].to_i
  end
  def perform_en_passant(piece,des_pos)
    remove_piece(piece.position)
    add_piece(piece,des_pos)
    remove_piece("#{des_pos[0]}#{des_pos[1].to_i - piece.move_direction}")
    piece.move(des_pos)
  end
  def perform_castle(king,castle_type)
    rook,rook_target_pos,king_target_pos = castle_positions(king,castle_type)

    remove_piece(king.position)
    remove_piece(rook.position)

    add_piece(king,king_target_pos)
    add_piece(rook,rook_target_pos)
    
    king.move(king_target_pos)
    rook.move(rook_target_pos)
  end
  def castle_positions(king,castle_type)
    if castle_type == 'O-O'
      rook = chessboard["#{(king.position[0].ord + 3).chr}#{king.position[1]}"]

      king_target_pos = "#{king.position[0].next.next}#{king.position[1]}"
      rook_target_pos = "#{king.position[0].next}#{king.position[1]}"
    else
      rook = chessboard["#{(king.position[0].ord - 4).chr}#{king.position[1]}"]

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
        piece = chessboard[position]
        if !piece.nil?
          print piece.icon
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