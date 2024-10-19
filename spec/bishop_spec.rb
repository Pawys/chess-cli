require_relative '../lib/chessboard'

describe Bishop do
  let(:board) { Chessboard.new() }
  let(:position) { 'd5' }
  subject(:bishop) { described_class.new(position, 'white', board) }
  describe '#get_possible_moves' do
    before do
      board.add_piece(bishop,position)
    end
    it 'returns correct possible moves' do
      expected_result = ['b3','b7','c4','c6','e4','e6','f3','f7']
      expect(bishop.possible_moves).to eq(expected_result)
    end
  end
end