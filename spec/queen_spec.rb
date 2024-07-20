require_relative '../lib/chessboard'

describe Queen do
  let(:board) { Chessboard.new() }
  let(:position) { 'd5' }
  subject(:queen) { described_class.new(position, 'white', board) }
  describe '#get_possible_moves' do
    before do
      board.chessboard[position].add_piece(queen)
    end
    it 'returns correct possible moves' do
      expected_result = ["a5", "b3", "b5", "b7", "c4", "c5", "c6", "d3", "d4", "d6", "d7", "e4", "e5", "e6", "f3", "f5", "f7", "g5", "h5"]
      expect{queen.get_possible_moves}.to change{queen.possible_moves}.to(expected_result)
    end
  end
end