
require_relative '../lib/chessboard'

describe Pawn do
  let(:board) { Chessboard.new() }
  let(:position) { 'e2' }
  subject(:pawn) { described_class.new(position, 'white', board) }
    before do
      board.add_piece(pawn,position)
    end
  describe '#add_normal_moves' do
    describe 'if there is a pawn blocking the way' do
        before do 
          board.add_piece(Pawn.new('e3','black',board),'e3')
        end
        it 'doesnt add any move' do
          expected_result = []
          expect(pawn.possible_moves).to eq(expected_result)
        end
    end
    describe 'if there is no pawn' do
      it 'adds double moves' do
        expected_result = ['e3','e4']
        expect(pawn.possible_moves).to eq(expected_result)
      end
    end
  end
  describe '#add_capture_moves' do
    describe 'if theres a capture' do
      before do 
        board.add_piece(Pawn.new('d3','black',board),'d3')
      end
      it 'add an capture' do
        expected_result = ['d3']
        expect(pawn.capture_moves).to eq(expected_result)
      end
    end
    describe 'if there is no capture' do 
      it 'doesnt add anything' do
        expect(pawn.capture_moves).to eq([])
      end
    end
  end
  describe '#en_passant' do 
    describe 'if theres a jumping pawn on the right' do
      before do
        last_double_step_pawn = Pawn.new('d2','black',board)
        board.last_double_step_pawn = last_double_step_pawn
      end
      it 'adds the move' do
        expected_result = ['d3']
        expect(pawn.en_passant_moves).to eq(expected_result)
      end
    end
    describe 'if theres a jumping pawn on the left' do
      before do
        last_double_step_pawn = Pawn.new('f2','black',board)
        board.last_double_step_pawn = last_double_step_pawn
      end
      it 'adds the move' do
        expected_result = ['f3']
        expect(pawn.en_passant_moves).to eq(expected_result)
      end
    end
  end
end