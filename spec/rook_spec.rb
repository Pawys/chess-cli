
require_relative '../lib/chessboard'

describe Rook do
  let(:board) { Chessboard.new() }
  let(:position) { 'd5' }
  subject(:rook) { described_class.new(position, 'white', board) }
  describe '#get_possible_moves' do
    before do
      board.add_piece(rook,position)
    end
    it 'returns correct possible moves' do
      expected_result = ['a5','b5','c5','d3','d4','d6','d7','e5','f5','g5','h5']
      expect(rook.possible_moves).to eq(expected_result)
    end
  end
end