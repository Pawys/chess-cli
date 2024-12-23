require_relative '../lib/chessboard'
describe Chessboard do
  let (:chessboard) {described_class.new()}
  describe '#move_legal?' do
    context 'When the move is illegal' do
      context 'When the move is invalid' do
        before do
          allow(chessboard).to receive(:move_valid?).and_return(false)
        end
        it 'returns false' do
          result = chessboard.move_legal?(nil,nil,nil,nil)
          expect(result).to eq(false)
        end
      end
      context 'when there is a check' do
        context 'when a piece blocking check moves' do
          before do
            chessboard.add_piece(Queen.new('e6','black',chessboard),'e6')
            chessboard.remove_piece('e2')
            chessboard.add_piece(Queen.new('e2','white',chessboard),'e2')
          end
          it 'returns false' do
            result = chessboard.move_legal?(chessboard.chessboard['e2'],'c4','move',nil)
            expect(result).to eq(false)
          end
        end
        context 'when a move doesnt block an existing check' do
          before do
            chessboard.add_piece(Queen.new('e6','black',chessboard),'e6')
            chessboard.remove_piece('e2')
            chessboard.add_piece(Queen.new('c4','white',chessboard),'c4')
          end
          it 'returns false' do
            result = chessboard.move_legal?(chessboard.chessboard['c4'],'c3','move',nil)
            expect(result).to eq(false)
          end
        end
        context 'when a king move puts a king into check' do
          before do
            chessboard.add_piece(Queen.new('e6','black',chessboard),'e6')
            chessboard.remove_piece('e2')
          end
          it 'returns false' do
            result = chessboard.move_legal?(chessboard.chessboard['e1'],'e2','move',nil)
            expect(result).to eq(false)
          end
        end
      end
    end
    context 'when the move is legal' do
      it 'returns true' do
        result = chessboard.move_legal?(chessboard.chessboard['e2'],'e3','move',nil)
        expect(result).to eq(true)
      end
    end
  end
  describe '#move_valid?' do
    context 'when a piece is nil' do
      it 'returns false' do
        result = chessboard.move_legal?(nil,nil,nil,nil)
        expect(result).to eq(false)
      end
    end
    context 'when a move type is a promotion but theres no promotion piece given' do
      it 'returns false' do
        result = chessboard.move_legal?(chessboard.chessboard['e2'],nil,'promotion',nil)
        expect(result).to eq(false)
      end
    end
    context 'if a move is not a possible move for the piece' do
      it 'returns false' do
        result = chessboard.move_legal?(chessboard.chessboard['e2'],'e8','move',nil)
        expect(result).to eq(false)
      end
    end
  end
  describe '#process_move' do
    before do
      allow(chessboard).to receive(:execute_castle)
      allow(chessboard).to receive(:execute_move)
    end
    context 'when the move is a castle' do
      it 'callls execute castle' do
        expect(chessboard).to receive(:execute_castle).with(King,'O-O')
        chessboard.process_move(King,'O-O','castle',nil)
      end
    end
    context 'when the move is a promotion' do
      it 'calls perform move with promotion info' do
        expect(chessboard).to receive(:execute_move).with('e7','e8',{:promotion => true, :promote_piece => Queen, :color => 'white'})
        chessboard.process_move(Pawn.new('e7','white',self),'e8','promotion',Queen)
      end
    end
    context 'when the move is not a special move' do
      it 'calls execute move' do
        expect(chessboard).to receive(:execute_move).with('e3','e4')
        chessboard.process_move(Pawn.new('e3',nil,nil),'e4','move',nil)
      end
    end
  end
  describe '#stalemate' do
    describe 'when white is stalemated' do
      before do
        chessboard.load_from_pgn("1.d4 e5 2.Qd2 e4 3.Qf4 f5 4.h3 Bb4+ 5.Nd2 d6 6.Qh2 Be6 7.a4 Qh4 8.Ra3 c5 9.Rg3 f4 10.f3 Bb3 11.d5 Ba5 12.c4 e3 1/2-1/2")
      end
      it 'returns true' do
        result = chessboard.stalemate?('white')
        expect(result).to eq(true)
      end
    end
    describe 'when black is stalemated' do
      before do
        chessboard.load_from_pgn("1. e4 e5 2. Nf3 Nc6 3. Bc4 Bc5 4. c3 Nf6 5. b4 Bb6 6. d3 d6 7. O-O O-O 8. Bg5 Be6 9. Nbd2 Qe7 10. a4 a6 11. a5 Ba7 12. Kh1 h6 13. Bh4 Rad8 14. b5 Bxc4 15. Nxc4 axb5 16. Ne3 Bxe3 17. fxe3 Qe6 18. Qb1 g5 19. Bg3 Na7 20. c4 c6 21. c5 Nh5 22. a6 bxa6 23. Rxa6 Qd7 24. d4 Nxg3+ 25. hxg3 Nc8 26. cxd6 f6 27. Rc1 Nxd6 28. Rcxc6 Ne8 29. Qxb5 g4 30. Nh4 exd4 31. exd4 Qxd4 32. Nf5 Qxe4 33. Re6 Rd1+ 34. Kh2 Qb1 35. Qxb1 Rxb1 36. Ra7 Rb5 37. Nxh6+ Kh8 38. Nxg4 Rg5 39. Rxe8 Rh5+ 40. Kg1 Rxe8 41. Nxf6 Rh1+ 42. Kxh1 Re1+ 43. Kh2 Rh1+ 44. Kxh1 1/2-1/2")
      end
      it 'returns true' do
        result = chessboard.stalemate?('black')
        expect(result).to eq(true)
      end
    end
    describe 'when black is checkmated' do
      before do
        chessboard.load_from_pgn("1. e4 e5 2. Qh5 Nc6 3. Bc4 Nf6 4.Qxf7#")
      end
      it 'returns false' do
        result = chessboard.stalemate?('black')
        expect(result).to eq(false)
      end
    end
    describe 'when theres not a stalemate' do
      before do
        chessboard.load_from_pgn("1. e4 d5 2. exd5 Qxd5 3. Nf3 Qe4+ 4. Be2 Qg4 5. h3 Qxg2 6. Bf1 Qxf3 7. Qxf3")
      end
      it 'returns false' do
        result = chessboard.stalemate?('black')
        expect(result).to eq(false)
      end
    end
  end
  describe '#checkmate' do
    describe 'when white is checkmated' do
      before do
        chessboard.load_from_pgn("1. e4 e5 2. f4 exf4 3. b3 Qh4+ 4. g3 fxg3 5. h3 g2+ 6. Ke2 Qxe4+ 7. Kf2 gxh1=N# 0-1")
      end
      it 'returns true' do
        result = chessboard.checkmate?('white')
        expect(result).to eq(true)
      end
    end
    describe 'when black is checkmated' do
      before do
        chessboard.load_from_pgn("1. e4 e5 2. Qh5 Nc6 3. Bc4 Nf6 4.Qxf7#")
      end
      it 'returns true' do
        result = chessboard.checkmate?('black')
        expect(result).to eq(true)
      end
    end
    describe 'when white is stalemated' do
      before do
        chessboard.load_from_pgn("1.d4 e5 2.Qd2 e4 3.Qf4 f5 4.h3 Bb4+ 5.Nd2 d6 6.Qh2 Be6 7.a4 Qh4 8.Ra3 c5 9.Rg3 f4 10.f3 Bb3 11.d5 Ba5 12.c4 e3 1/2-1/2")
      end
      it 'returns false' do
        result = chessboard.checkmate?('white')
        expect(result).to eq(false)
      end
    end
    describe 'when theres not a checkmate' do
      before do
        chessboard.load_from_pgn("1. e4 d5 2. exd5 Qxd5 3. Nf3 Qe4+ 4. Be2 Qg4 5. h3 Qxg2 6. Bf1 Qxf3 7. Qxf3")
      end
      it 'returns false' do
        result = chessboard.checkmate?('black')
        expect(result).to eq(false)
      end
    end
  end
  describe '#load_from_pgn' do
      before do
        allow(chessboard).to receive(:reset_board) 
        allow(chessboard).to receive(:process_move) 
        allow(chessboard).to receive(:move_legal?).and_return(true) 
        allow(chessboard).to receive(:pgn_valid?).and_return(true) 
      end
    context 'when given a valid PGN string' do
      let(:pgn) { '1. e4 e5 2. Nf3 Nc6 3. Bb5 a6' }
      it 'cleans the pgn and assigns it to the @pgn variable' do
        chessboard.load_from_pgn(pgn)

        result = chessboard.pgn

        expect(result).to eq("1. e4 e5 2. Nf3 Nc6 3. Bb5 a6")
      end
      it 'calculates the current move number' do
        chessboard.load_from_pgn(pgn)

        result = chessboard.current_move_number

        expect(result).to eq(3)
      end
      it 'callls procces move the correct number of times' do
        expect(chessboard).to receive(:process_move).exactly(6).times

        chessboard.load_from_pgn(pgn)
      end
    end
    context 'when given a PGN with metadata' do
      let(:pgn) { "[Event 'Test Event']\n1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 1-0" } 
      it 'cleans it an sets it as @pgn' do
        chessboard.load_from_pgn(pgn)

        result = chessboard.pgn

        expect(result).to eq("1. e4 e5 2. Nf3 Nc6 3. Bb5 a6")
      end
    end
    context 'when a move is illegal' do
      let(:pgn) { "[Event 'Test Event']\n1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Qe8#" } 
      before do
        allow(chessboard).to receive(:move_legal?).and_return(true, true, true, true,true,true,false) 
      end
      it 'prints a message saying the move is illegal' do
        expect { chessboard.load_from_pgn(pgn) }.to output(/Qe8# is an illegal move\./).to_stdout
      end
      it 'reset_boards the game' do
        expect(chessboard).to receive(:reset_board)

        chessboard.load_from_pgn(pgn)
      end
    end
    context 'when a pgn is invalid' do
      let(:pgn) { "invalid pgn"} 
      before do
        allow(chessboard).to receive(:pgn_valid?).and_return(false) 
      end
      it 'returns invalid pgn' do
        expect { chessboard.load_from_pgn(pgn) }.to output(/invalid pgn\./).to_stdout
      end
    end
  end
  describe '#pgn_valid?' do
    context 'when a pgn is nil' do
      it 'returns false' do
        result = chessboard.pgn_valid?(nil)

        expect(result).to eq(false)
      end
    end
    context 'when a pgn is does not start with "1."' do
      it 'returns false for a pgn that starts with a 2' do
        result = chessboard.pgn_valid?('2. a2')

        expect(result).to eq(false)
      end
      it 'returns false for an empty pgn' do
        result = chessboard.pgn_valid?('')

        expect(result).to eq(false)
      end
    end
    context 'when the fourth character of the PGN is not a string' do
      it 'returns false if the fourth character is nil' do
        result = chessboard.pgn_valid?('1.')

        expect(result).to eq(false)
      end
    end  
  end
  describe '#execute_move' do
    context 'when the move is a normal move' do
      let(:pawn) {chessboard.chessboard['a2']}
      let(:move) {'a4'}
      context 'when pawn performs a double step move' do
        it 'sets the last double pawn' do
          expect{chessboard.execute_move('a2',move)}.to change{chessboard.last_double_step_pawn}.to(pawn)
        end
      end
      context 'when a piece moves to a new position' do
        it 'removes the piece from the old square' do
          expect{chessboard.execute_move('a2',move)}.to change{chessboard.chessboard['a2']}.from(pawn).to(nil)
        end
        it 'adds a piece to the new square' do
          expect{chessboard.execute_move('a2',move)}.to change{chessboard.chessboard['a4']}.from(nil).to(pawn)
        end
        it 'changes the piece internal positon' do
          expect(pawn).to receive(:update_position).with(move)
          chessboard.execute_move('a2',move)
        end
      end
    end
    context 'when the move is an en passant' do
      before do
        chessboard.load_from_pgn('1. e4 a6 2. e5 f5')
      end
      let(:pawn) {chessboard.chessboard['e5']}
      let(:capture_pawn) {chessboard.chessboard['f5']}
      let(:move) {'f6'}
      it 'removes the captured piece from the old square' do
        expect{chessboard.execute_move('e5',move,{:en_passant => true})}.to change{chessboard.chessboard['f5']}.from(capture_pawn).to(nil)
      end
      it 'removes the piece from the old square' do
        expect{chessboard.execute_move('e5',move,{:en_passant => true})}.to change{chessboard.chessboard['e5']}.from(pawn).to(nil)
      end
      it 'adds a piece to the new square' do
        expect{chessboard.execute_move('e5',move,{:en_passant => true})}.to change{chessboard.chessboard['f6']}.from(nil).to(pawn)
      end
      it 'changes the piece internal positon' do
        expect(pawn).to receive(:update_position).with(move)
        chessboard.execute_move('e5',move)
      end
    end
    context 'when the move is a promotion' do
      let(:pawn) {Pawn.new('b7','white',chessboard)}
      let(:move) {'b8'}
      let(:promote_piece) {Queen}
      before do
        chessboard.remove_piece('b8')
        chessboard.remove_piece('b7')
        chessboard.add_piece(pawn,'b7')
      end
      it 'removes the piece from the old square' do
        expect{chessboard.execute_move(pawn.position,move,{:promotion => true, :promote_piece => promote_piece, :color => pawn.color})}.to change{chessboard.chessboard['b7']}.from(pawn).to (nil)
      end
      it 'adds a piece to the new square' do
        chessboard.execute_move(pawn.position,move,{:promotion => true, :promote_piece => promote_piece, :color => pawn.color})
        expect(chessboard.chessboard['b8']).to be_a(Queen)
        expect(chessboard.chessboard['b8'].color).to eq('white') 
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
  describe '#get_castle_positions' do
    context 'when castle type is long castle' do
      it 'returns correct positions' do
        king = chessboard.chessboard['e1']
        rook = chessboard.chessboard['a1']

        result = chessboard.get_castle_positions(king,'O-O-O')
        expect(result).to eq([rook,'d1','c1'])
      end
    end
    context 'when castle type is short castle' do
      it 'returns correct positions' do
        king = chessboard.chessboard['e8']
        rook = chessboard.chessboard['h8']

        result = chessboard.get_castle_positions(king,'O-O')
        expect(result).to eq([rook,'f8','g8'])
      end
    end
  end
  describe '#execute_castle' do
    let(:king) {chessboard.chessboard['e1']}
    let(:rook) {chessboard.chessboard['h1']}
    before do
      chessboard.remove_piece('f1')
      chessboard.remove_piece('g1')
    end
    it 'removes the king from the old square' do
      expect{chessboard.execute_castle(king,'O-O')}.to change{chessboard.chessboard['e1']}.from(king).to(nil)
    end
    it 'removes the rook from the old square' do
      expect{chessboard.execute_castle(king,'O-O')}.to change{chessboard.chessboard['h1']}.from(rook).to(nil)
    end
    it 'adds the king to the new square' do
      expect{chessboard.execute_castle(king,'O-O')}.to change{chessboard.chessboard['g1']}.from(nil).to(king)
    end
    it 'adds the rook to the new square' do
      expect{chessboard.execute_castle(king,'O-O')}.to change{chessboard.chessboard['f1']}.from(nil).to(rook)
    end
    it 'changes the internal position of the king' do
      expect(king).to receive(:update_position).with('g1')
      chessboard.execute_castle(king,'O-O')
    end
    it 'changes the internal position of the rook' do
      expect(rook).to receive(:update_position).with('f1')
      chessboard.execute_castle(king,'O-O')
    end
  end
end