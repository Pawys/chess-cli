require_relative '../lib/chessboard'

describe Knight do
  let(:board) { Chessboard.new() }
  let(:position) { 'd5' }
  subject(:knight) { described_class.new(position, 'white', board) }
    before do
      board.chessboard[position].add_piece(knight)
      board.chessboard['e3'].add_piece(Pawn.new('e3','white',board))
    end
  describe '#get_possible_moves' do
    it 'returns correct possible moves' do
      expected_result = ['b4','b6','c3','c7','e7','f4','f6']
      expect{knight.get_possible_moves}.to change{knight.possible_moves}.to(expected_result)
    end
  end
end