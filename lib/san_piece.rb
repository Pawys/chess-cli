class SanMove
  def initialize(move)
    @san_move = move
  end
  def piece_class()
    SAN_NOTATION_LETTERS[@san_move[0]] || Pawn
  end
  def capture?()
    @san_move.include?("x")
  end
  def piece_location()
    if piece_class == Pawn
      @san_move[0] if capture?
    else
      if @san_move.length > 3
        if FILES.include?(@san_move[1]) && (FILES.include?(@san_move[2] || @san_move[2] == 'x'))
          @san_move[1]
        elsif RANKS.include?(@san_move[1])
          @san_move[1]
        else
          nil
        end
      end
    end
  end
  def move_type()
    if @san_move[0] == 'O'
      move_type = 'castle'
    elsif @san_move.include?('=')
      move_type = 'promotion'
    elsif piece_class == Pawn && capture?
      move_type = 'en_passant'
    else
      case @san_move[-1]
      when '1'..'8'
        move_type = 'move'
      when '+'
        move_type = 'check'
      else
        move_type = 'mate'
      end
    end
    move_type
  end
  def trg_pos()
    case move_type
    when 'castle'
      trg_pos = @san_move
    when 'promotion'
      if @san_move[-1] == "+" || @san_move[-1] == '#'
        trg_pos = @san_move[-5..-4]
      else
        trg_pos = @san_move[-4..-3]
      end
    when 'move'
      trg_pos = @san_move[-2..-1]
    else
      trg_pos = @san_move[-3..-2]
    end
    trg_pos
  end
  def promote_piece()
    SAN_NOTATION_LETTERS[move[-1]] || SAN_NOTATION_LETTERS[move[-2]]
  end
  def find_piece(piece_class, piece_color, piece_location, des_pos)
    @pieces.find do |piece|
      next unless piece.color == piece_color && piece.class == piece_class
      next unless piece.possible_moves.include?(des_pos)
      piece_location.nil? || piece.position.include?(piece_location.to_s)
    end
  end
  def get_en_passant(des_pos)
    'en_passant' if chessboard[des_pos].occupying_piece == nil
  end 
end