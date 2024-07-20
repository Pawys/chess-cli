require_relative '../lib/chessboard'

describe King do
  let(:board) { Chessboard.new() }
  let(:position) { 'd3' }
  subject(:king) { described_class.new(position, 'white', board) }
  describe '#get_possible_moves' do
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
end