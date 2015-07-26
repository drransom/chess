require 'spec_helper'
require 'board'
require 'pieces'

describe Board do
  context 'simple boards' do
    subject(:board) { Board.new(false) }

    it 'simple case' do
      board[[7, 0]] = King.new(:white, board, [7, 0])
      board[[0, 0]] = King.new(:black, board, [0, 0])
      board[[6, 7]] = Rook.new(:black, board, [6, 7])
      expect(board.legal_moves(:white)).to eq ([[7, 0], [7, 1]])
    end

    it 'two available moves' do
      board[[7, 1]] = King.new(:white, board, [7, 1])
      board[[0, 0]] = King.new(:black, board, [0, 0])
      board[[6, 7]] = Rook.new(:black, board, [6, 7])
      expect(board.legal_moves(:white).sort).to eq([ [[7, 1], [7, 0]], [[7, 1], [7, 2]] ])
    end

    it 'options for multiple pieces' do
      board[[7, 0]] = King.new(:white, board, [7, 0])
      board[[3, 3]] = Pawn.new(:white, board, [3, 3])
      board[[0, 0]] = King.new(:black, board, [0, 0])
      correct_outcome = [ [[3, 3]], [[2, 3]], [[7, 1], [7, 0]], [[7, 1], [7, 2]] ]
      expect(board.legal_moves(:white).sort).to eq(correct_outcome)
    end

    it 'moves king out of check if the king is in check' do
      board[[7, 0]] = King.new(:white, board, [7, 0])
      board[[3, 3]] = Pawn.new(:white, board, [3, 3])
      board[[0, 0]] = King.new(:black, board, [0, 0])
      board[[7, 7]] = Rook.new(:black, board, [7, 7])
      expect(board.legal_moves(:white).sort).to eq([ [[7, 0], [6, 0]], [[7, 0], [6, 1]] ])
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
      expect( pawn_moves ).to eq([[1, 4], [2, 4]], [[1, 4], [3, 4]])
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
      expect(moves).to_include([[1, 4], [2, 5]])
      expect(moves).not_to include([[1, 4], [2, 3]])
    end

    it 'bishop' do
      board[[7, 4]] = King.new(:white, board, [7, 4])
      board[[0, 4]] = King.new(:black, board, [0, 4])
      board[[3, 3]] = Bishop.new(:black, board, [3, 3])
      bishop_moves = [0, 1, 2, 4, 5, 6, 7].map { |i| [[3, 3], [i, i]] }
      bishop_moves += [0, 1, 2, 4, 5, 6].map { |i| [[3, 3], [i, 6 - i]] }
      moves = board.legal_moves(:black)
      expect(moves.sort).to eq(bishop_moves.sort)
    end

    it 'rook' do
      board[[7, 4]] = King.new(:white, board, [7, 4])
      board[[0, 4]] = King.new(:black, board, [0, 4])
      board[[3, 3]] = Rook.new(:black, board, [3, 3])
      board[[3, 5]] = Pawn.new(:white, board, [3, 5])
      rook_moves = [0, 1, 2, 4, 5, 6, 7].map { |i| [[3, 3], [i, 3]] }
      rook_moves += [1, 2, 3, 4, 5].map { |i| [[3, 3], [3, i]] }
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
      rook_moves += [1, 2, 3, 4, 5].map { |i| [[3, 3], [3, i]] }
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

  context 'initial setup' do
    subject(:board) { Board.new(true) }

    it 'calculates all the initial moves' do
      expect(board.legal_moves(:white).length).to eq(20)
    end
  end

end
