require_relative '../lib/chessboard'

describe King do
  let(:board) { Chessboard.new() }
  describe '#possible_moves' do
      let(:position) { 'd3' }
      subject(:king) { described_class.new(position, 'white', board) }
    before do
      board.add_piece(king,position)
      board.add_piece(Pawn.new('e4','black',board),'e4')
      board.add_piece(Pawn.new('e5','black',board),'e5')
    end
    it 'returns correct possible moves' do
      expected_result = ['c3','c4','d4','e3','e4']
      expect(king.possible_moves).to eq(expected_result)
    end
  end
  describe '#castle_moves' do
    let(:position) { 'e1' }
    subject(:king) { described_class.new(position, 'white', board) }
    before do
      board.add_piece(king,position)
    end
    describe 'when the squares need for the castle are empty' do
      before do
        board.remove_piece('f1')
        board.remove_piece('g1')
      end
      describe 'if the rook has not moved' do
        before do
          board.chessboard["h1"].has_moved = false
        end
        it 'add 0-0 to possibble moves' do
          expect(king.castle_moves).to eq(['O-O'])
        end
      end
      describe 'if the rook has moved' do
        before do
          board.chessboard["h1"].has_moved = true
        end
        it 'doesnt add anything' do
          king.castle_moves()
          expect(king.possible_moves).not_to include('O-O')
        end
      end
    end
    describe 'when the squares need for the castle arent empty' do
      it 'doesnt add anything' do
        king.castle_moves()
        expect(king.possible_moves).not_to include('O-O')
      end
    end
  end
  describe '#in_check?' do
    subject(:king) { described_class.new('e1', 'white', board) }
    before do
      board.remove_piece('e1')
      board.add_piece(king,'e1')
    end
    describe 'when king is in check' do
      before do
        board.add_piece(Queen.new('e5','black',board),'e5')
        board.remove_piece('e2')
      end
      it 'returns true' do
        result = king.in_check?
        expect(result).to eq(true)
      end
    end
    describe 'when king is not in check' do
      it 'returns false' do
        result = king.in_check?
        expect(result).to eq(false)
      end
    end
  end
end