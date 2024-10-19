require_relative '../lib/piece'
require_relative '../lib/chessboard'

describe Piece do
  let(:board) { instance_double("Chessboard") }
  let(:oc_pc) { instance_double("Piece") }
  let(:position) { 'e4' }
  let(:color) { 'white' }
  subject(:piece) { described_class.new(position, color, board) }

  describe '#move' do
    before do
      piece.define_singleton_method(:possible_moves) do
      end
      allow(piece).to receive(:possible_moves)
    end
    let (:new_position) {'e5'}
    it 'updates its positon' do
      expect{piece.move(new_position)}.to change{piece.position}.from('e4').to('e5')
    end
    it 'updates has moved' do
      expect{piece.move(new_position)}.to change{piece.has_moved}.from(false).to(true)
    end
  end
  describe '#evaluate_move' do
    it 'checks if the move is on the board' do
      move = 'p2'
      result = piece.evaluate_move(move)
      expect(result).to eq ('impossible_move')
    end
    describe 'when a move is possible' do
      before do
        allow(board).to receive(:chessboard).and_return({'e5'=> nil})
      end
      it 'returns possible move' do
        move = 'e5'
        result = piece.evaluate_move(move)
        expect(result).to eq ('possible_move')
      end
    end
    describe 'when a move is a capture' do
      before do
        allow(board).to receive(:chessboard).and_return({'e5'=> oc_pc})
        allow(oc_pc).to receive(:color).and_return('black')
      end
      it 'returns possible move' do
        move = 'e5'
        result = piece.evaluate_move(move)
        expect(result).to eq ('capture')
      end
    end
    describe 'when a move is a impossible' do
      before do
        allow(board).to receive(:chessboard).and_return({'e5'=> oc_pc})
        allow(oc_pc).to receive(:color).and_return('white')
      end
      it 'returns possible move' do
        move = 'e5'
        result = piece.evaluate_move(move)
        expect(result).to eq ('impossible_move')
      end
    end
  end
  describe "#possible_move_patterns" do
    let(:pattern) {[{rank_moves: (1..3).to_a,file_moves: ('a'..'c').to_a}]}
    before do
      allow(piece).to receive(:evaluate_move).and_return('possible_move')
    end
    it 'goes through all the moves' do
      expect(piece.possible_move_patterns(pattern)).to eq(['a1','b2','c3'])
    end
    describe 'when there is a capture in the pattern' do
      before do
        allow(piece).to receive(:evaluate_move).and_return('possible_move','capture')
      end
      it 'adds the capture and stops the loop' do
        expect(piece.possible_move_patterns(pattern)).to eq(['a1','b2'])
      end
    end
    describe 'when there is a impossible move in the pattern' do
      before do
        allow(piece).to receive(:evaluate_move).and_return('possible_move','impossible_move')
      end
      it 'stops the loop but doesnt add the impossible move' do
        expect(piece.possible_move_patterns(pattern)).to eq(['a1'])
      end
    end
  end
end
