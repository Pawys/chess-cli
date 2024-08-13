require_relative '../lib/chessboard'
describe Chessboard do
  let (:chessboard) {described_class.new()}
  describe 'from SAN functions' do
    describe '#get_piece_class' do
      describe 'when the piece is in the notation letters' do
        it 'returns correct piece class' do
          piece_sign = 'N'
          result = chessboard.get_piece_class(piece_sign)
          expect(result).to eq(Knight)
        end
      end
      describe 'when the pice is not in the notation leters' do
        it 'returns a pawn class' do
          move = 'e2'
          result = chessboard.get_piece_class(move)
          expect(result).to eq(Pawn)
        end
      end
    end
    describe '#get_capture info' do
      it 'returns true if move has capture' do
        result = chessboard.get_capture_info('x')
        expect(result).to eq(true)
      end
      it 'returns false if move doesnt have capture' do
        result = chessboard.get_capture_info('e2')
        expect(result).to eq(false)
      end
    end
    describe '#get_piece_location' do
      describe 'when the piece is a pawn' do
        it 'returns location if the moves is a capture' do
          result = chessboard.get_piece_location('axc2',Pawn,true)
          expect(result).to eq('a')
        end
        it 'returns nil if the move is not a capture' do
          result = chessboard.get_piece_location('c2',Pawn,false)
          expect(result).to eq(nil)
        end
      end
      describe 'when the piece is not a pawn' do
        it 'returns location if length is more than 3 and a valid rank or file' do
          result = chessboard.get_piece_location('Qef4',Queen,false)
          expect(result).to eq('e')
        end
        it 'returns nil if length is smaller than 3' do
          result = chessboard.get_piece_location('Qf4',Queen,false)
          expect(result).to eq(nil)
        end
        it 'returns nil if third character is not a valid rank or file' do
          result = chessboard.get_piece_location('Qf4+',Queen,false)
          expect(result).to eq(nil)
        end
      end
    end
    describe "#chessboard.get_move_type_and_pos" do
      it 'returns castle and whole move when move is a castle' do
        move = 'O-O-O'
        result = chessboard.get_move_type_and_pos(move)
        expect(result).to eq(['castle',move])
      end
      describe 'when move is a promotion' do
        it 'returns correct pos when move is mate/check' do
          move = 'axb8=Q+'
          result = chessboard.get_move_type_and_pos(move)
          expect(result).to eq(['promotion','b8'])
        end
        it 'returns correct pos when its not a mate/check' do
          move = 'axb8=Q'
          result = chessboard.get_move_type_and_pos(move)
          expect(result).to eq(['promotion','b8'])
        end
      end
      it 'returns move when move is not a check or mate' do
        move = 'Nf3'
        result = chessboard.get_move_type_and_pos(move)
        expect(result).to eq(['move','f3'])
      end
      it 'returns check when move is a check' do
        move = 'Qh4+'
        result = chessboard.get_move_type_and_pos(move)
        expect(result).to eq(['check','h4'])
      end
      it 'returns mate when move is a mate' do
        move = 'Qh4#'
        result = chessboard.get_move_type_and_pos(move)
        expect(result).to eq(['mate','h4'])
      end
    end
    describe '#find_piece' do
      context 'when a single matching piece exists' do
        it 'finds correct piece' do
          piece = chessboard.find_piece(Pawn,'white',nil,'e3')
          expect(piece).to be_a(Pawn)
          expect(piece.color).to eq('white')
          expect(piece.position).to eq('e2')
        end
      end
      context 'when two pieces can move to the position' do
        before do
          chessboard.chessboard['a2'].remove_piece
          chessboard.chessboard['a7'].remove_piece
          rook = Rook.new('a8','white',chessboard)
          chessboard.chessboard['a8'].add_piece(Rook.new('a8','white',chessboard))
          chessboard.pieces.push(rook)
          chessboard.refresh_moves
        end
        context 'when piece location is specified' do
          it 'find the correct piece based on the location' do
            piece = chessboard.find_piece(Rook,'white',8,'a4')
            expect(piece).to be_a(Rook)
            expect(piece.color).to eq('white')
            expect(piece.position).to eq('a8')
          end
        end
        context 'when piece location is not specified' do
          it 'finds a piece that can move to the positon' do
            piece = chessboard.find_piece(Rook,'white',nil,'a4')
            expect(piece).to be_a(Rook)
            expect(piece.color).to eq('white')
          end
        end
      end
      context 'when no piece can move to the position' do
        it 'returns nil' do 
          piece = chessboard.find_piece(Queen,'white',nil,'d5')
          expect(piece).to be(nil)
        end
      end
    end
    describe '#get_special_info' do
      it 'calls get_promote_piece if a move is a promotion' do
        allow(chessboard).to receive(:get_promote_piece)
        expect(chessboard).to receive(:get_promote_piece).with(nil)
        chessboard.get_special_info(nil,'promotion',nil,nil,nil)
      end
      describe 'if the piece class is a Pawn' do
        it 'calls get_en_passant if the move is a capture' do
          allow(chessboard).to receive(:get_en_passant)
          expect(chessboard).to receive(:get_en_passant).with(nil)
          chessboard.get_special_info(nil,nil,Pawn,nil,true)
        end
        it 'doesnt call en passant if the move is not a capture' do
          allow(chessboard).to receive(:get_en_passant)
          expect(chessboard).to_not receive(:get_en_passant)
          chessboard.get_special_info(nil,nil,Pawn,nil,false)
        end
      end
    end
    describe '#get_promote_piece' do
      describe 'when the promote piece is the last letter of move' do
        it 'returns correct piece class' do
          move = 'axb8=Q'
          result = chessboard.get_promote_piece(move)
          expect(result).to eq(Queen)
        end
      end
      describe 'when the promote piece is the second last letter of move' do
        it 'returns correct piece class' do
          move = 'axb8=R+'
          result = chessboard.get_promote_piece(move)
          expect(result).to eq(Rook)
        end
      end
    end
    describe "#get_en_passant" do
      it 'returns en_passant if the occupying piece of the move is nil' do
        des_pos = 'e5'
        result = chessboard.get_en_passant(des_pos)
        expect(result).to eq('en_passant')
      end
      it 'returns en_passant if the occupying piece of the move is not nil' do
        des_pos = 'e2'
        result = chessboard.get_en_passant(des_pos)
        expect(result).to eq(nil)
      end
    end
  end
  describe 'move making functions' do
    describe '#move' do
      before do
        allow(Marshal).to receive(:dump)
        allow(Marshal).to receive(:load)
        allow(chessboard).to receive(:valid_move?).and_return(true)
        allow(chessboard).to receive(:handle_moves)
        allow(chessboard).to receive(:check_for_check)
      end
      it 'returns when move is not valid' do
        allow(chessboard).to receive(:valid_move?).and_return(false)
        expect(chessboard).not_to receive(:handle_moves)
        chessboard.move(Array.new(4))
      end
      it 'loads previous state if player king is in check after player move' do
        king = instance_double(King)
        allow(king).to receive(:color).and_return('white')
        allow(king).to receive(:in_check).and_return(true)
        chessboard.instance_variable_set(:@white_king, king)

        expect(Marshal).to receive(:load)

        chessboard.move([king,nil,nil,nil])
      end
    end
    describe '#handle_moves' do
      before do
        allow(chessboard).to receive(:perform_castle)
        allow(chessboard).to receive(:perform_en_passant)
        allow(chessboard).to receive(:perform_move)
        allow(chessboard).to receive(:promote)
      end
      context 'when the move is a castle' do
        it 'callls peform castle' do
          expect(chessboard).to receive(:perform_castle).with(King,'O-O')
          chessboard.handle_moves(King,'O-O','castle',nil)
        end
      end
      context 'when the move is a promotion' do
        it 'calls promotion' do
          expect(chessboard).to receive(:promote).with(Pawn,'e8',Queen)
          chessboard.handle_moves(Pawn,'e8','promotion',Queen)
        end
      end
      context 'when the move is en_passant' do
        it 'perform en passant' do
          expect(chessboard).to receive(:perform_en_passant).with(Pawn,'e6')
          chessboard.handle_moves(Pawn,'e6','capture','en_passant')
        end
      end
      context 'when the move is not a special move' do
        it 'perform move' do
          expect(chessboard).to receive(:perform_move).with(Pawn,'e3')
          chessboard.handle_moves(Pawn,'e3','move',nil)
        end
      end
      it 'refreshes the pieces moves' do
        expect(chessboard).to receive(:refresh_moves).once
        chessboard.handle_moves(Pawn,'e3','move',nil)
      end
    end
    describe '#promote' do
      context 'when a piece moves to a new position' do
        let(:pawn) {Pawn.new('b7','white',chessboard)}
        let(:move) {'b8'}
        let(:promote_piece) {Queen}
        before do
          chessboard.chessboard['b8'].remove_piece
          chessboard.chessboard['b7'].remove_piece
          chessboard.add_piece(pawn,'b7')
        end
        it 'removes the piece from the old square' do
          expect{chessboard.promote(pawn,move,promote_piece)}.to change{chessboard.chessboard['b7'].occupying_piece}.from(pawn).to(nil)
        end
        it 'adds a piece to the new square' do
          chessboard.promote(pawn,move,promote_piece)
          expect(chessboard.chessboard['b8'].occupying_piece).to be_a(Queen)
          expect(chessboard.chessboard['b8'].occupying_piece.color).to eq('white') 
        end
        it 'adds the piece to the pieces array' do
          chessboard.promote(pawn,move,promote_piece)
          expect(chessboard.pieces).to include(chessboard.chessboard[move].occupying_piece)
        end
      end
    end
    describe '#perform_move' do
      let(:pawn) {chessboard.chessboard['a2'].occupying_piece}
      let(:move) {'a4'}
      context 'when pawn performs a double step move' do
        it 'sets the last double pawn' do
          expect{chessboard.perform_move(pawn,move)}.to change{chessboard.last_double_step_pawn}.to(pawn)
        end
      end
      context 'when a piece moves to a new position' do
        it 'removes the piece from the old square' do
          expect{chessboard.perform_move(pawn,move)}.to change{chessboard.chessboard['a2'].occupying_piece}.from(pawn).to(nil)
        end
        it 'adds a piece to the new square' do
          expect{chessboard.perform_move(pawn,move)}.to change{chessboard.chessboard['a4'].occupying_piece}.from(nil).to(pawn)
        end
        it 'changes the piece internal positon' do
          expect(pawn).to receive(:move).with(move)
          chessboard.perform_move(pawn,move)
        end
      end
    end
    describe '#is_double_pawn_move?' do
      let(:pawn) {instance_double(Pawn)}
      before do
        allow(pawn).to receive(:position).and_return('e2')
        allow(pawn).to receive(:class).and_return(Pawn)
        allow(pawn).to receive(:move_direction).and_return(1)
      end
      it 'returns false if piece is not a pawn' do
        result = chessboard.is_double_pawn_move?(King,'O-O')
        expect(result).to eq(false)
      end
      it 'returns false if move is not a double square move' do
        result = chessboard.is_double_pawn_move?(pawn,'e3')
        expect(result).to eq(false)
      end
      it 'returns true whe move is a double pawn move' do 
        result = chessboard.is_double_pawn_move?(pawn,'e4')
        expect(result).to eq(true)
      end
    end
    describe '#perform_en_passant' do
      let(:pawn) {instance_double(Pawn)}
      let(:capture_pawn) {instance_double(Pawn)}
      let(:move) {'f4'}
      before do
        chessboard.chessboard['e3'].add_piece(pawn)
        chessboard.chessboard['f3'].add_piece(capture_pawn)
        allow(pawn).to receive(:move)
        allow(pawn).to receive(:position).and_return('e3')
        allow(pawn).to receive(:move_direction).and_return(1)
      end
      it 'removes the captured piece from the old square' do
        expect{chessboard.perform_en_passant(pawn,move)}.to change{chessboard.chessboard['f3'].occupying_piece}.from(capture_pawn).to(nil)
      end
      it 'removes the piece from the old square' do
        expect{chessboard.perform_en_passant(pawn,move)}.to change{chessboard.chessboard['e3'].occupying_piece}.from(pawn).to(nil)
      end
      it 'adds a piece to the new square' do
        expect{chessboard.perform_en_passant(pawn,move)}.to change{chessboard.chessboard['f4'].occupying_piece}.from(nil).to(pawn)
      end
      it 'changes the piece internal positon' do
        expect(pawn).to receive(:move).with(move)
        chessboard.perform_en_passant(pawn,move)
      end
    end
    describe '#castle_positions' do
      context 'when castle type is long castle' do
        it 'returns correct positions' do
          king = chessboard.chessboard['e1'].occupying_piece
          rook = chessboard.chessboard['a1'].occupying_piece

          result = chessboard.castle_positions(king,'O-O-O')
          expect(result).to eq([rook,'d1','c1'])
        end
      end
      context 'when castle type is short castle' do
        it 'returns correct positions' do
          king = chessboard.chessboard['e8'].occupying_piece
          rook = chessboard.chessboard['h8'].occupying_piece

          result = chessboard.castle_positions(king,'O-O')
          expect(result).to eq([rook,'f8','g8'])
        end
      end
    end
    describe '#perform_castle' do
      let(:king) {chessboard.chessboard['e1'].occupying_piece}
      let(:rook) {chessboard.chessboard['h1'].occupying_piece}
      before do
        chessboard.chessboard['f1'].remove_piece
        chessboard.chessboard['g1'].remove_piece
      end
      it 'removes the king from the old square' do
        expect{chessboard.perform_castle(king,'O-O')}.to change{chessboard.chessboard['e1'].occupying_piece}.from(king).to(nil)
      end
      it 'removes the rook from the old square' do
        expect{chessboard.perform_castle(king,'O-O')}.to change{chessboard.chessboard['h1'].occupying_piece}.from(rook).to(nil)
      end
      it 'adds the king to the new square' do
        expect{chessboard.perform_castle(king,'O-O')}.to change{chessboard.chessboard['g1'].occupying_piece}.from(nil).to(king)
      end
      it 'adds the rook to the new square' do
        expect{chessboard.perform_castle(king,'O-O')}.to change{chessboard.chessboard['f1'].occupying_piece}.from(nil).to(rook)
      end
      it 'changes the internal position of the king' do
        expect(king).to receive(:move).with('g1')
        chessboard.perform_castle(king,'O-O')
      end
      it 'changes the internal position of the rook' do
        expect(rook).to receive(:move).with('f1')
        chessboard.perform_castle(king,'O-O')
      end
    end
    describe '#check_for_check' do
      context 'when a white king is in check' do
        before do
          chessboard.chessboard['e2'].remove_piece
          queen = Queen.new('e5','black',chessboard)
          chessboard.pieces.push(queen)
          chessboard.chessboard['e5'].add_piece(queen)
          chessboard.refresh_moves()
        end
        it 'changes in check to true' do
          expect{chessboard.check_for_check}.to change{chessboard.instance_variable_get(:@white_king).in_check}.from(false).to (true)
        end
      end
      context 'when a black king is in check' do
        before do
          chessboard.chessboard['d7'].remove_piece
          bishop = Bishop.new('b5','white',chessboard)
          chessboard.pieces.push(bishop)
          chessboard.chessboard['b5'].add_piece(bishop)
          chessboard.refresh_moves()
        end
        it 'changes in check to true' do
          expect{chessboard.check_for_check}.to change{chessboard.instance_variable_get(:@black_king).in_check}.from(false).to (true)
        end
      end
      context 'when no king is in check' do
        before do
          chessboard.instance_variable_get(:@black_king).in_check = true
        end
        it 'changes in check to false' do
          expect{chessboard.check_for_check}.to change{chessboard.instance_variable_get(:@black_king).in_check}.from(true).to (false)
        end
      end
    end
  end
end