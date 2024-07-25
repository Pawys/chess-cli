require_relative '../lib/chessboard'

describe King do
  let(:board) { Chessboard.new() }
  describe '#get_possible_moves' do
      let(:position) { 'd3' }
      subject(:king) { described_class.new(position, 'white', board) }
    before do
      board.chessboard[position].add_piece(king)
      board.chessboard['e4'].add_piece(Pawn.new('e4','black',board))
      board.chessboard['d4'].add_piece(Pawn.new('d4','black',board))
    end
    it 'returns correct possible moves' do
      expected_result = ['c3','c4','d4','e3','e4']
      expect{king.get_possible_moves}.to change{king.possible_moves}.to(expected_result)
    end
  end
  describe '#check_castle' do
    let(:position) { 'e1' }
    subject(:king) { described_class.new(position, 'white', board) }
    before do
      board.chessboard[position].add_piece(king)
      board.chessboard["e1"].add_piece(king)
    end
    describe 'when the squares need for the castle are empty' do
      before do
        board.chessboard["f1"].remove_piece
        board.chessboard["g1"].remove_piece
      end
      describe 'if the rook has not moved' do
        before do
          board.chessboard["h1"].occupying_piece.has_moved = false
        end
        it 'add 0-0 to possible moves' do
          expect{king.check_castle}.to change{king.possible_moves}.to (['0-0'])
        end
      end
      describe 'if the rook has moved' do
        before do
          board.chessboard["h1"].occupying_piece.has_moved = true
        end
        it 'doesnt add anything' do
          king.check_castle()
          expect(king.possible_moves).not_to include('O-O')
        end
      end
    end
    describe 'when the squares need for the castle arent empty' do
      it 'doesnt add anything' do
        king.check_castle()
        expect(king.possible_moves).not_to include('O-O')
      end
    end
  end
end