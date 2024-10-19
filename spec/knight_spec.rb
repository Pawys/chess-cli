require_relative '../lib/chessboard'

describe Knight do
  let(:board) { Chessboard.new() }
  let(:position) { 'd5' }
  subject(:knight) { described_class.new(position, 'white', board) }
    before do
      board.add_piece(knight,position)
      board.add_piece(Pawn.new('e3','white',board),'e3')
    end
  describe '#get_possible_moves' do
    it 'returns correct possible moves' do
      expected_result = ['b4','b6','c3','c7','e7','f4','f6']
      expect(knight.possible_moves).to eq(expected_result)
    end
  end
end