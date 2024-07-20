
require_relative '../lib/chessboard'

describe Pawn do
  let(:board) { Chessboard.new() }
  let(:position) { 'e2' }
  subject(:pawn) { described_class.new(position, 'white', board) }
    before do
      board.chessboard[position].add_piece(pawn)
    end
  describe '#get_possible_moves' do
    describe 'if the pawn hasnt moved' do
      describe 'if theres an enemy pawn in the way' do
        before do 
          board.chessboard['e4'].add_piece(Pawn.new('e4','black',board))
        end
        it 'doesnt add a two step move' do
          expected_result = ['e3']
          expect{pawn.get_possible_moves}.to change{pawn.possible_moves}.to(expected_result)
        end
      end
      describe 'if the way is clear' do
        it 'adds a two step move' do
          expected_result = ['e3','e4']
          expect{pawn.get_possible_moves}.to change{pawn.possible_moves}.to(expected_result)
        end
      end
    end
    describe 'if theres a capture' do
        before do 
          board.chessboard['d3'].add_piece(Pawn.new('d3','black',board))
        end
        it 'add an capture' do
          expected_result = ['d3','e3','e4']
          expect{pawn.get_possible_moves}.to change{pawn.possible_moves}.to(expected_result)
        end
    end
  end
end