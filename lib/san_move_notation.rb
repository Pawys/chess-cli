class SanMoveNotation
  SAN_NOTATION_LETTERS = {
    'R' => Rook,
    'N' => Knight,
    'B' => Bishop,
    'Q' => Queen,
    'K' => King,
    'O' => King
  }
  FILES = ('a'..'h').to_a
  RANKS = (1..8).to_a
  def initialize(move,chessboard)
    @move_notation = move
    @chessboard = chessboard
  end
  def piece_class()
    SAN_NOTATION_LETTERS[@move_notation[0]] || Pawn
  end
  def capture_move?()
    @move_notation.include?("x")
  end
  def piece_location_data()
    if piece_class == Pawn
      @move_notation[0] if capture_move?()
    else
      if @move_notation.length > 3
        if FILES.include?(@move_notation[1]) && (FILES.include?(@move_notation[2]) || @move_notation[2] == 'x')
          @move_notation[1]
        elsif RANKS.include?(@move_notation[1].to_i)
          @move_notation[1]
        else
          nil
        end
      end
    end
  end
  def move_type()
    if en_passant?()
      return 'en_passant'
    else
      normal_move_type()
    end
  end
  def normal_move_type()
    if @move_notation[0] == 'O'
      move_type = 'castle'
    elsif @move_notation.include?('=')
      move_type = 'promotion'
    else
      case @move_notation[-1]
      when '1'..'8'
        move_type = 'move'
      else
        move_type = 'check/mate'
      end
    end
    move_type
  end
  def trg_pos()
    case normal_move_type()
    when 'castle'
      trg_pos = @move_notation
    when 'promotion'
      if @move_notation[-1] == "+" || @move_notation[-1] == '#'
        trg_pos = @move_notation[-5..-4]
      else
        trg_pos = @move_notation[-4..-3]
      end
    when 'check/mate'
      trg_pos = @move_notation[-3..-2]
    else
      trg_pos = @move_notation[-2..-1]
    end
    trg_pos
  end
  def promotion_piece()
    SAN_NOTATION_LETTERS[@move_notation[-1]] || SAN_NOTATION_LETTERS[@move_notation[-2]]
  end
  def en_passant?()
    unless piece_class() == Pawn && capture_move?
      return false
    end
    @chessboard.chessboard[trg_pos()] == nil
  end
  def find_piece(piece_color)
    @chessboard.pieces.find do |piece|
      next unless piece.color == piece_color && piece.class == piece_class
      next unless piece.possible_moves.include?(trg_pos)
      piece_location_data.nil? || piece.position.include?(piece_location_data.to_s)
    end
  end
end