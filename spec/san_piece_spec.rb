
require_relative '../lib/chessboard'

describe SanMoveNotation do
  let (:chessboard) {Chessboard.new()}
  describe '#piece_class' do
    describe 'when the piece is in the notation letters' do
      let (:smn) {described_class.new("Ne4",chessboard)}
      it 'returns correct piece class' do
        result = smn.piece_class()
        expect(result).to eq(Knight)
      end
    end
    describe 'when the pice is not in the notation leters' do
      let (:smn) {described_class.new("e4",chessboard)}
      it 'returns a pawn class' do
        result = smn.piece_class()
        expect(result).to eq(Pawn)
      end
    end
  end
  describe '#capture_move?' do
    describe 'if move has a capture' do 
      let (:smn) {described_class.new("exd4",chessboard)}
      it 'returns true' do
        result = smn.capture_move?()
        expect(result).to eq(true)
      end
    end
    describe 'if move has a capture' do 
      let (:smn) {described_class.new("e4",chessboard)}
      it 'returns true' do
        result = smn.capture_move?()
        expect(result).to eq(false)
      end
    end
  end
  describe '#piece_location_data' do
    describe 'when the piece is a pawn' do
      describe 'when the move is a capture' do
      let (:smn) {described_class.new("axc2",chessboard)}
        it 'returns location' do
        result = smn.piece_location_data()
          expect(result).to eq('a')
        end
      end
      describe 'when the move is a capture' do
      let (:smn) {described_class.new("c2",chessboard)}
        it 'returns location' do
        result = smn.piece_location_data()
          expect(result).to eq(nil)
        end
      end
    end
    describe 'when the piece is not a pawn' do
      describe 'if length is more than 3 and a valid rank or file' do
        let (:smn) {described_class.new("R8a4",chessboard)}
        it 'returns location' do
          result = smn.piece_location_data
          expect(result).to eq('8')
        end
      end
      describe 'if length is smaller than 3' do
        let (:smn) {described_class.new("Qe4",chessboard)}
        it 'returns nil' do
          result = smn.piece_location_data
          expect(result).to eq(nil)
        end
      end
      describe 'if third character is not a valid rank or file' do
        let (:smn) {described_class.new("Qe4+",chessboard)}
        it 'returns nil' do
          result = smn.piece_location_data
          expect(result).to eq(nil)
        end
      end
    end
  end
  describe '#move_type' do
    let (:smn) {described_class.new("cxc4",chessboard)}
    context 'when the move is an en passant move' do
      before do
        allow(smn).to receive(:en_passant?).and_return(true)
      end
      it 'returns en_passant' do
        result = smn.move_type()
        expect(result).to eq('en_passant')
      end
    end
    context 'when its an normal move' do
      let (:smn) {described_class.new("Qe4",chessboard)}
      before do
        allow(smn).to receive(:en_passant?).and_return(false)
        allow(smn).to receive(:normal_move_type).and_return('move')
      end
      it 'returns en_passant' do
        result = smn.move_type()
        expect(result).to eq('move')
      end
    end
  end
  describe "#normal_move_type" do
    describe 'when move is a castle' do
      let (:smn) {described_class.new("O-O",chessboard)}
      it 'returns castle' do
        result = smn.normal_move_type()
        expect(result).to eq('castle')
      end
    end
    describe 'when move is a promotion' do
      let (:smn) {described_class.new("exf8=Q",chessboard)}
      it 'returns promotion' do
        result = smn.normal_move_type()
        expect(result).to eq('promotion')
      end
    end
    describe 'when move is a normal move' do
      let (:smn) {described_class.new("e4",chessboard)}
      it 'returns move' do
        result = smn.normal_move_type()
        expect(result).to eq('move')
      end
    end
    describe 'when move is a check/mate' do
      let (:smn) {described_class.new("e4+",chessboard)}
      it 'returns check/mate' do
        result = smn.normal_move_type()
        expect(result).to eq('check/mate')
      end
    end
  end
  describe "#trg_pos" do
    describe 'when the move is a castle' do
      let (:smn) {described_class.new("O-O-O",chessboard)}
      it 'returns the correct move notation' do
        result = smn.trg_pos()
        expect(result).to eq('O-O-O')
      end
    end
    describe 'when the move is a promotion' do
      let (:smn) {described_class.new("gxh8=Q+",chessboard)}
      it 'returns the correct move notation' do
        result = smn.trg_pos()
        expect(result).to eq('h8')
      end
    end
    describe 'when the move is a normal move' do
      let (:smn) {described_class.new("Qg4",chessboard)}
      it 'returns the correct move notation' do
        result = smn.trg_pos()
        expect(result).to eq('g4')
      end
    end
    describe 'when the move is a check/mate' do
      let (:smn) {described_class.new("Qxe5+",chessboard)}
      it 'returns the correct move notation' do
        result = smn.trg_pos()
        expect(result).to eq('e5')
      end
    end
  end
  describe '#find_piece' do
    context 'when a single matching piece exists' do
      let (:smn) {described_class.new("e3",chessboard)}
      it 'finds correct piece' do
        piece = smn.find_piece('white')
        expect(piece).to be_a(Pawn)
        expect(piece.color).to eq('white')
        expect(piece.position).to eq('e2')
      end
    end
    context 'when two pieces can move to the position' do
      before do
        chessboard.remove_piece('a2')
        chessboard.remove_piece('a7')
        rook = Rook.new('a8','white',chessboard)
        chessboard.add_piece(rook,'a8')
      end
      context 'when piece location is specified' do
        let (:smn) {described_class.new("R8a4",chessboard)}
        it 'find the correct piece based on the location' do
          piece = smn.find_piece('white')
          expect(piece).to be_a(Rook)
          expect(piece.color).to eq('white')
          expect(piece.position).to eq('a8')
        end
      end
      context 'when piece location is not specified' do
        let (:smn) {described_class.new("Ra4",chessboard)}
        it 'finds a piece that can move to the positon' do
          piece = smn.find_piece('white')
          expect(piece).to be_a(Rook)
          expect(piece.color).to eq('white')
        end
      end
    end
    context 'when no piece can move to the position' do
      let (:smn) {described_class.new("Ra4",chessboard)}
      it 'returns nil' do 
        piece = smn.find_piece('white')
        expect(piece).to be(nil)
      end
    end
  end
  describe '#promotion_piece' do
    describe 'when the promote piece is the last letter of move' do
      let (:smn) {described_class.new("axb8=Q",chessboard)}
      it 'returns correct piece class' do
        result = smn.promotion_piece()
        expect(result).to eq(Queen)
      end
    end
    describe 'when the promote piece is the second last letter of move' do
      let (:smn) {described_class.new("axb8=R+",chessboard)}
      it 'returns correct piece class' do
        result = smn.promotion_piece()
        expect(result).to eq(Rook)
      end
    end
  end
  describe "#en_passant?" do
    context 'when the move is an en passant' do
      let (:smn) {described_class.new("exf4",chessboard)}
      it 'returns true' do 
        result = smn.en_passant?
        expect(result).to eq(true)
      end
    end
    context 'when the move is not an en passant' do
      before do 
        pawn = Rook.new('f4','black',chessboard)
        chessboard.add_piece(pawn,'f4')
      end
      let (:smn) {described_class.new("exf4",chessboard)}
      it 'returns false' do 
        result = smn.en_passant?
        expect(result).to eq(false)
      end
    end
  end
end