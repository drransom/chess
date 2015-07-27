require 'spec_helper'
require 'board'
require 'pieces'

describe Board do
  context '#legal_moves with simple boards' do
    subject(:board) { Board.new(false) }

    it 'simple case' do
      board[[7, 4]] = King.new(:white, board, [7, 4])
      board[[0, 0]] = King.new(:black, board, [0, 0])
      board[[6, 7]] = Rook.new(:black, board, [6, 7])
      correct_outcome = [[7, 4], [7, 3]], [[7, 4], [7, 5]]
      expect(board.legal_moves(:white).sort).to eq (correct_outcome)
    end

    it 'options for multiple pieces' do
      board[[7, 4]] = King.new(:white, board, [7, 4])
      board[[7, 0]] = Knight.new(:white, board, [7, 0])
      board[[0, 0]] = King.new(:black, board, [0, 0])
      board[[6, 7]] = Rook.new(:black, board, [6, 7])
      correct_outcome = [ [[7, 0], [5, 1]], [[7, 0], [6, 2]], [[7, 4], [7, 3]], [[7, 4], [7, 5]] ]
      expect(board.legal_moves(:white).sort).to eq(correct_outcome)
    end

    it 'moves king out of check if the king is in check' do
      board[[7, 4]] = King.new(:white, board, [7, 4])
      board[[3, 3]] = Pawn.new(:white, board, [3, 3])
      board[[0, 0]] = King.new(:black, board, [0, 0])
      board[[7, 7]] = Rook.new(:black, board, [7, 7])
      correct_outcome = [ [[7, 4], [6, 3]], [[7, 4], [6, 4]], [[7, 4], [6, 5]] ]
      expect(board.legal_moves(:white).sort).to eq(correct_outcome)
    end

    it 'revealed check' do
      board[[7, 4]] = King.new(:white, board, [7, 4])
      board[[0, 4]] = King.new(:black, board, [0, 4])
      board[[0, 5]] = Queen.new(:black, board, [7, 0])
      board[[7, 2]] = Knight.new(:white, board, [7, 2])
      moves = board.legal_moves(:white)
      expect(moves.length).not_to eq(0)
      expect(moves.select { |move| move[0] == [7, 2] }.length).to eq(0)
    end

    it 'can avoid check by interposing pieces' do
      board[[7, 0]] = King.new(:white, board, [7, 0])
      board[[3, 3]] = Rook.new(:white, board, [3, 3])
      board[[0, 0]] = King.new(:black, board, [0, 0])
      board[[7, 7]] = Rook.new(:black, board, [7, 7])
      moves = board.legal_moves(:white)
      expect(moves).to include([[3, 3], [7, 3]])
      expect(moves.select { |move| move[0] == [3, 3] }.length).to eq(1)
    end

    it 'legal moves includes castling' do
      board[[7, 4]] = King.new(:white, board, [7, 4])
      board[[7, 7]] = Rook.new(:white, board, [7, 7])
      board[[0, 0]] = King.new(:black, board, [0, 0])
      moves = board.legal_moves(:white)
      expect(moves).to include([[7, 4], [7, 6]])
    end

    it 'legal moves does not include castling out of check' do
      board[[7, 4]] = King.new(:white, board, [7, 4])
      board[[7, 7]] = Rook.new(:white, board, [7, 7])
      board[[0, 0]] = King.new(:black, board, [0, 0])
      board[[3, 4]] = Rook.new(:black, board, [3, 4])
      moves = board.legal_moves(:white)
      expect(moves.select { |move| move[0] == [7, 4] }.length).to_not eq(0)
      expect(board.legal_moves(:white)).not_to include([[7, 4], [7, 6]])
    end

    it 'legal moves does not including castling through check' do
      board[[7, 4]] = King.new(:white, board, [7, 4])
      board[[7, 7]] = Rook.new(:white, board, [7, 7])
      board[[0, 0]] = King.new(:black, board, [0, 0])
      board[[3, 5]] = Rook.new(:black, board, [3, 5])
      moves = board.legal_moves(:white)
      expect(moves.select { |move| move[0] == [7, 4] }.length).to_not eq(0)
      expect(board.legal_moves(:white)).not_to include([[7, 4], [7, 6]])
    end

    it 'pawn moves' do
      board[[7, 4]] = King.new(:white, board, [7, 4])
      board[[0, 4]] = King.new(:black, board, [0, 4])
      board[[1, 4]] = Pawn.new(:black, board, [1, 4])
      pawn_moves = board.legal_moves(:black).select { |move| move[0] == [1, 4] }.sort
      expect(pawn_moves).to eq([[[1, 4], [2, 4]], [[1, 4], [3, 4]]])
    end

    it 'pawn blocked' do
      board[[7, 4]] = King.new(:white, board, [7, 4])
      board[[0, 4]] = King.new(:black, board, [0, 4])
      board[[1, 4]] = Pawn.new(:black, board, [1, 4])
      board[[3, 4]] = Pawn.new(:white, board, [3, 4])
      moves = board.legal_moves(:black)
      expect(moves).to include([[1, 4], [2, 4]])
      expect(moves).not_to include([[1, 4], [3, 4]])
    end

    it 'pawn immediately blocked' do
      board[[7, 4]] = King.new(:white, board, [7, 4])
      board[[0, 4]] = King.new(:black, board, [0, 4])
      board[[1, 4]] = Pawn.new(:black, board, [1, 4])
      board[[2, 4]] = Pawn.new(:white, board, [3, 4])
      moves = board.legal_moves(:black)
      expect( moves.select { |move| move[0] == [1, 4] }.length).to eq(0)
    end

    it 'pawn attacks' do
      board[[7, 4]] = King.new(:white, board, [7, 4])
      board[[0, 4]] = King.new(:black, board, [0, 4])
      board[[1, 4]] = Pawn.new(:black, board, [1, 4])
      board[[2, 5]] = Rook.new(:white, board, [2, 5])
      moves = board.legal_moves(:black)
      expect(moves).to include([[1, 4], [2, 5]])
      expect(moves).not_to include([[1, 4], [2, 3]])
    end

    it 'bishop' do
      board[[7, 4]] = King.new(:white, board, [7, 4])
      board[[0, 4]] = King.new(:black, board, [0, 4])
      board[[3, 3]] = Bishop.new(:black, board, [3, 3])
      bishop_moves = [0, 1, 2, 4, 5, 6, 7].map { |i| [[3, 3], [i, i]] }
      bishop_moves += [0, 1, 2, 4, 5, 6].map { |i| [[3, 3], [i, 6 - i]] }
      moves = board.legal_moves(:black).select { |move| move[0] == [3, 3] }
      expect(moves.sort).to eq(bishop_moves.sort)
    end

    it 'rook' do
      board[[7, 4]] = King.new(:white, board, [7, 4])
      board[[0, 4]] = King.new(:black, board, [0, 4])
      board[[3, 3]] = Rook.new(:black, board, [3, 3])
      rook_moves = [0, 1, 2, 4, 5, 6, 7].map { |i| [[3, 3], [i, 3]] }
      rook_moves += [0, 1, 2, 4, 5, 6, 7].map { |i| [[3, 3], [3, i]] }
      moves = board.legal_moves(:black).select { |move| move[0] == [3, 3] }
      expect(moves.sort).to eq(rook_moves.sort)
    end

    it 'knight' do
      board[[7, 4]] = King.new(:white, board, [7, 4])
      board[[0, 4]] = King.new(:black, board, [0, 4])
      board[[3, 3]] = Knight.new(:black, board, [3, 3])
      targets = [ [1, 2], [1, 4], [2, 1], [2, 5], [4, 1], [4, 5], [5, 2], [5, 4] ]
      knight_moves = targets.map { |space| [[3, 3], space] }
      moves = board.legal_moves(:black).select { |move| move[0] == [3, 3] }
      expect(moves.sort).to eq(knight_moves.sort)
    end

    it 'queen' do
      board[[7, 4]] = King.new(:white, board, [7, 4])
      board[[0, 4]] = King.new(:black, board, [0, 4])
      board[[3, 3]] = Queen.new(:black, board, [3, 3])
      rook_moves = [0, 1, 2, 4, 5, 6, 7].map { |i| [[3, 3], [i, 3]] }
      rook_moves += [0, 1, 2, 4, 5, 6, 7].map { |i| [[3, 3], [3, i]] }
      bishop_moves = [0, 1, 2, 4, 5, 6, 7].map { |i| [[3, 3], [i, i]] }
      bishop_moves += [0, 1, 2, 4, 5, 6].map { |i| [[3, 3], [i, 6 - i]] }
      queen_moves = rook_moves + bishop_moves
      moves = board.legal_moves(:black).select { |move| move[0] == [3, 3] }
      expect(moves.sort).to eq(queen_moves.sort)
    end

    it 'capture' do
      board[[7, 4]] = King.new(:white, board, [7, 4])
      board[[0, 4]] = King.new(:black, board, [0, 4])
      board[[3, 3]] = Queen.new(:black, board, [3, 3])
      board[[3, 1]] == Queen.new(:white, board, [3, 1])
      moves = board.legal_moves(:white)
      expect(moves).to include([[3, 1], [3, 3]])
      expect(moves).not_to include([[3, 1], [3, 4]])
    end

    it 'cannot move through piece of the same color' do
      board[[7, 4]] = King.new(:white, board, [7, 4])
      board[[0, 4]] = King.new(:black, board, [0, 4])
      board[[3, 3]] = Rook.new(:black, board, [3, 3])
      board[[3, 1]] == Rook.new(:black, board, [3, 1])
      moves = board.legal_moves(:black)
      expect( moves.select { |move| move[0] == [3, 3]}.length).to_not eq(0)
      expect(moves).to_not include([[3, 3], [3, 1]])
      expect(moves).to_not include([[3, 3], [3, 0]])
      expect( moves.select { |move| move[0] == [3, 1]}.length).to_not eq(0)
      expect(moves).to_not include([[3, 1], [3, 3]])
      expect(moves).to_not include([[3, 1], [3, 4]])
    end
  end

  context '#legal_moves with initial setup' do
    subject(:board) { Board.new(true) }

    it 'calculates all the initial moves' do
      expect(board.legal_moves(:white).length).to eq(20)
    end
  end

  context 'future move evaluation'
    subject(:board) { Board.new(false) }

    describe '#move_checkmates_other_color?' do

      before(:each) do
        board[[0, 4]] = King.new(:black, board, [0, 4])
        board[[7, 4]] = King.new(:white, board, [7, 4])
      end

      it 'handles a simple case' do
        board[[6, 7]] = Queen.new(:black, board, [6, 7])
        board[[5, 6]] = Rook.new(:black, board, [5, 6])
        expect board.move_checkmates_other_color?([[5, 6], [7, 6]], :black).to be_truthy
      end

      it 'revealed check' do
        board[[0, 0]] = Rook.new(:white, board, [0, 0])
        board[[0, 1]] = Knight.new(:white, board, [0, 1])
        board[[1, 7]] = Rook.new(:white, board, [1, 7])
        expect(board.move_checkmates_other_color?([[0, 1], [2, 0]], :white)).to be_truthy
      end

      it 'recognizes moves that are not checkmate' do
        expect(board.move_checkmates_other_color?([[0, 4], [0, 5]], :black)).to be_falsy
      end

      it 'stalemate is not checkmate' do
        board[[6, 0]] = Rook.new(:black, board, [6, 0])
        board[[7, 3]] = Knight.new(:black, board, [7, 3])
        expect(board.move_checkmates?([[7, 3], [5, 4]], :black)).to be_falsy
      end
    end

    describe '#move_stalemates_other_color?' do
      before(:each) do
        board[[0, 4]] = King.new(:black, board, [0, 4])
        board[[7, 4]] = King.new(:white, board, [7, 4])
      end

      it 'handles a simple case' do
        board[[6, 0]] = Rook.new(:black, board, [6, 0])
        board[[7, 3]] = Knight.new(:black, board, [7, 3])
        expect(board.move_stalemates_other_color?([[7, 3], [5, 4]], :black)).to be_truthy
      end

      it 'revealed stalemate' do
        board[[6, 0]] = Rook.new(:black, board, [6, 0])
        board[[6, 1]] = Bishop.new(:black, board, [6, 1])
        board[[5, 4]] = Knight.new(:black, board, [5, 4])
        expect(board.move_stalemates_other_color?([[6, 1], [4, 3]], :black)).to be_truthy
      end

      it 'checkmate is not stalemate' do
        board[[6, 0]] = Rook.new(:black, board, [6, 0])
        board[[7, 3]] = Knight.new(:black, board, [7, 3])
        expect(board.move_stalemates_opponent?([[7, 3], [5, 4]], :black)).to be_falsy
      end
    end
  end

  # context '#legal_caputures' do
  #   subject(:board) { Board.new(true) }
  #
  #   before(:each) do
  #     board[[7, 4]] = King.new(:white, board, [7, 4])
  #     board[[0, 4]] = King.new(:black, board, [0, 4])
  #   end
  #
  #   it 'handles a simple case' do
  #     expect(board.legal_captures(:white)).to eq([])
  #     expect(board.legal_captures(:black)).to eq([])
  #   end
  #
  #   it 'finds a simple capture' do
  #     board[[0, 5]] = Queen.new(:white, board, [0, 5])
  #
  #     expect(board.legal_captures(:black)).to eq([ [[0, 4], [0, 5]]])
  #     expect(board.legal_captures(:white)).to eq([])
  #   end
  #
  #   it 'cannot capture into check' do
  #     board[[0, 5]] = Queen.new(:white, board, [0, 5])
  #     board[[1, 3]] = Knight.new(:white, board, [1, 3])
  #
  #     expect(board.legal_captures(:black)).to eq([])
  #   end
  #
  #   it 'finds multiple captures for the same piece' do
  #     board[[0, 5]] = Bishop.new(:white, board, [0, 5])
  #     board[[0, 3]] = Knight.new(:white, board, [0, 3])
  #
  #     captures = board.legal_captures(:black)
  #     expect(captures.sort).to eq([ [[0, 4], [0, 3]], [[0, 4], [0, 5]] ])
  #   end
  #
  #   it 'finds captures by different pieces' do
  #     board[[0, 5]] = Knight.new(:white, board, [0, 5])
  #     board[[2, 2]] = Knight.new(:white, board, [2, 2])
  #     board[[1, 4]] = Knight.new(:black, board, [1, 4])
  #     captures = board.legal_captures(:black)
  #     correct_outcome = [ [[0, 4], [0, 5]], [[0, 4], [1, 4]], [[2, 2], [1, 4]] ]
  #     expect(captures.sort).to eq(correct_outcome)
  #   end

  end

end
