require_relative 'pieces/pawn'
require_relative 'pieces/rook'
require_relative 'pieces/knight'
require_relative 'pieces/bishop'
require_relative 'pieces/queen'
require_relative 'pieces/king'
require_relative 'san_move_notation'

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
  attr_accessor :chessboard, :pieces, :pgn ,:last_double_step_pawn, :white_king, :black_king, :current_move_number
  def initialize()
    @pgn = ''
    @current_move_number = 0
    @pieces = []
    @white_pieces = []
    @black_pieces = []
    @chessboard = Hash.new()
    @last_double_step_pawn
    setup_board()
  end
  def setup_board()
    FILES.each do |file|
      RANKS.each do |rank|
        position = "#{file}#{rank}"
        occupying_piece = populate_board(file,rank,position)
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
  def populate_board(file,rank,position)
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
  def reset_board()
    @pieces = []
    @current_move_number = 0
    @chessboard = Hash.new()
    @last_double_step_pawn = nil
    @pgn = ''
    setup_board()
  end
  def record_move_to_pgn(move_notation,move_color)
    if move_color == 'white'
      @current_move_number += 1
      @pgn << "#{@current_move_number}. #{move_notation}"
    else
      @pgn << " #{move_notation} "
    end
  end
  def load_from_pgn(pgn)
    reset_board()
    clean_pgn = pgn.gsub(/\d\/\d-?|[01]-[01]|\[.*\]|\n/, '').strip
    return puts("invalid pgn.") if !pgn_valid?(clean_pgn)
    moves = clean_pgn.gsub(/\d?\d\. ?/,'').strip.split(' ')
    moves.each_with_index do |move,idx|
      san_move = SanMoveNotation.new(move,self)
      color = idx % 2 == 0 ? 'white' : 'black'
      if !move_legal?(san_move.find_piece(color),san_move.trg_pos,san_move.move_type,san_move.promotion_piece)
        puts "#{move} is an illegal move."
        reset_board()
        break
      else
        process_move(san_move.find_piece(color),san_move.trg_pos,san_move.move_type,san_move.promotion_piece)
      end
    end
    @pgn = clean_pgn
    @current_move_number = @pgn.scan(/(\d+)\./).last&.first.to_i
  end

  def pgn_valid?(pgn)
    return false if pgn.nil?
    if pgn[0..1] != "1."
      return false
    elsif pgn[3].class != String #checks if the fourth character is a string eg. 1.*a*4
      return false
    end
    true
  end
  def move_from_san(san_move,color)
    san_move_notation = SanMoveNotation.new(san_move,self)
    if move_legal?(san_move_notation.find_piece(color),san_move_notation.trg_pos,san_move_notation.move_type,san_move_notation.promotion_piece)
      process_move(san_move_notation.find_piece(color),san_move_notation.trg_pos,san_move_notation.move_type,san_move_notation.promotion_piece)
      record_move_to_pgn(san_move,color)
    end
  end
 
  def process_move(piece,des_pos,move_type,special_info)
    case move_type
    when 'castle'
      execute_castle(piece,des_pos)
    when 'promotion'
      execute_move(piece.position,des_pos,{:promotion => true, :promote_piece => special_info, :color => piece.color})
    when 'en_passant'
      execute_move(piece.position,des_pos,{:en_passant => true})
    else
      execute_move(piece.position,des_pos)
    end
  end
  
  def move_legal?(piece,trg_pos,move_type,promotion_piece)
    return false if !move_valid?(piece,trg_pos,move_type,promotion_piece)

    saved_state = Marshal.dump(self)

    player_king = piece.color == 'white' ? @white_king : @black_king

    process_move(piece,trg_pos,move_type,promotion_piece)

    check = player_king.in_check?
    restored_self = Marshal.load(saved_state)
    instance_variables.each do |var|
      instance_variable_set(var, restored_self.instance_variable_get(var))
    end
    !check
  end

  def move_valid?(piece,trg_pos,move_type,promotion_piece)
    return false if piece == nil
    if move_type == 'promotion'
      return false if promotion_piece == nil
    end
    piece.possible_moves.include?(trg_pos)
  end

  def stalemate?(color)
    player_king = color == 'white' ? @white_king : @black_king
    return false if player_king.in_check?
    @pieces.each do |piece|
      next if piece.color != color
      piece.possible_moves.each do |move| 
        if move_legal?(chessboard[piece.position],move,get_move_type_from_position(piece.position,move),nil)
          return false
        end
      end
    end
    true
  end
  def checkmate?(color)
    player_king = color == 'white' ? @white_king : @black_king
    return false if !player_king.in_check?
    @pieces.each do |piece|
      next if piece.color != color
      piece.possible_moves.each do |move| 
        if move_legal?(chessboard[piece.position],move,get_move_type_from_position(piece.position,move),nil)
          return false
        end
      end
    end
    true
  end

  def get_move_type_from_position(org_pos,trg_pos)
    piece = chessboard[org_pos]
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
  def execute_move(org_pos,trg_pos,special_info = {})
    if special_info[:promotion]
      piece = special_info[:promote_piece].new(org_pos,special_info[:color],self)
    else
      piece = chessboard[org_pos]
    end
    @last_double_step_pawn = piece if is_double_pawn_move?(piece,trg_pos)

    remove_piece(org_pos)
    add_piece(piece,trg_pos)
    piece.update_position(trg_pos)

    if special_info[:en_passant]
      remove_piece("#{trg_pos[0]}#{trg_pos[1].to_i - piece.move_direction}")
    end
  end
  def is_double_pawn_move?(piece,trg_pos)
    return false if piece.class != Pawn
    piece.position[1].to_i + (2*piece.move_direction) == trg_pos[1].to_i
  end
  def execute_castle(king,castle_type)
    rook,rook_target_pos,king_target_pos = get_castle_positions(king,castle_type)

    remove_piece(king.position)
    remove_piece(rook.position)

    add_piece(king,king_target_pos)
    add_piece(rook,rook_target_pos)
    
    king.update_position(king_target_pos)
    rook.update_position(rook_target_pos)
  end
  def get_castle_positions(king,castle_type)
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