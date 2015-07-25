require 'spec_helper'
require 'board'
require 'game'
require 'pieces'
require 'player'

describe 'en passant' do
  describe 'basic en passant' do

    subject(:board) { Board.new }
    let(:en_passant_setup) { [ [[7, 1], [5, 2]], [[1, 3], [3, 3]], [[7, 6], [5, 5]],
                            [[3, 3], [4, 3]], [[6, 4], [4, 4]] ] }

    it 'pieces in right position' do
      en_passant_setup.each { |move| board.move_piece(move[0], move[1]) }
      board.move_piece([4, 3], [5, 4])
      expect(board[[5, 4]]).to be_a(Pawn)
      expect(board[[5, 4]].color).to eq(:black)
      expect(board[[4, 4]]).not_to be_a(Pawn)
    end

    it 'move after en passant is not legal' do
      en_passant_setup.each { |move| board.move_piece(move[0], move[1]) }
      board.move_piece([1, 0], [2, 0])
      board.move_piece([6, 0], [5, 0])
      expect(board.move_legal?([4, 3], [5, 4])).to be_falsy
    end

    it 'only pawns can capture en passant' do
      #try to capture with bishop
      moves = [ [[6, 0], [5, 0]], [[1, 4], [3, 4]], [[5, 0], [4, 0]],
                 [[0, 5], [3, 2]], [[6, 4], [4, 4]], [[3, 2], [5, 4]] ]
      moves.each { |move| board.move_piece(move[0], move[1]) }
      expect(board[[4, 4]]).to be_a(Pawn)
      expect(board[[4, 4]].color).to eq(:white)
    end

  end

  describe '#en_passant_available?' do
    subject(:b) { Board.new(false) }
    let(:attacking_pawn) { Pawn.new(:black, b, [4, 5]) }
    let(:add_attacking_pawn) do
      Proc.new { b[attacking_pawn.position] = attacking_pawn }
    end

    before(:each) do
      b[[0, 4]] = King.new(:black, b, [0, 4])
      b[[7, 4]] = King.new(:white, b, [7, 4])
      defending_pawn = Pawn.new(:white, b, [6, 6])
      b[[6, 6]] = defending_pawn
    end

    it "when no pawns have moved" do
      add_attacking_pawn.call
      expect(b.en_passant_available?(:white)).to be_falsy
      expect(b.en_passant_available?(:black)).to be_falsy
    end

    it "pawn has moved one space" do
      add_attacking_pawn.call
      b.move_piece([6, 6], [5, 6])
      expect(b.en_passant_available?(:black)).to be_falsy
      expect(b.en_passant_available?(:white)).to be_falsy
    end

    it "pawn has moved two spaces" do
      add_attacking_pawn.call
      b.move_piece([6, 6], [4, 6])
      expect(b.en_passant_available?(:black)).to be_truthy
    end

    it "turn passes after pawn advances" do
      add_attacking_pawn.call
      b.move_piece([6, 6], [4, 6])
      b.move_piece([0, 4], [0, 5])
      b.move_piece([7, 4], [7, 3])
      expect(b.en_passant_available?(:black)).to be_falsy
    end

    it "no pawn can capture en passant" do
      attacking_pawn = Pawn.new(:black, b, [3, 5])
      b[attacking_pawn.position] = attacking_pawn
      b.move_piece([6, 6], [4, 6])
      expect(b.en_passant_available?(:black)).to be_falsy
    end
  end

  describe 'en_passant_equivalent?' do
    subject(:board1) { Board.new(false) }
    let(:board2) { Board.new(false) }
    let(:setup_board) do
      Proc.new do |b|
        b[[0, 4]] = King.new(:black, b, [0, 4])
        b[[7, 4]] = King.new(:white, b, [7, 4])
        defending_pawn1 = Pawn.new(:black, b, [1, 6])
        defending_pawn2 = Pawn.new(:black, b, [1, 4])
        attacking_pawn =  Pawn.new(:white, b, [3, 5])
        [defending_pawn1, defending_pawn2, attacking_pawn].each do |pawn|
          b[pawn.position] = pawn
        end
      end
    end

    before(:each) do
      setup_board.call(board1)
      setup_board.call(board2)
    end

    it "starts equivalent" do
      expect(board1.en_passant_equivalent?(board2)).to be_truthy
    end

    it "remains equivalent when the pawns move the same way" do
      board1.move_piece([1, 6], [3, 6])
      board2.move_piece([1, 6], [3, 6])
      expect(board1.en_passant_equivalent?(board2)).to be_truthy
    end

    it "is not equivalent when the pawns move in different orders" do
      board1.move_piece([1, 6], [3, 6])
      board1.move_piece([0, 4], [0, 5])
      board1.move_piece([1, 4], [3, 4])
      board2.move_piece([1, 4], [3, 4])
      board2.move_piece([0, 4], [0, 5])
      board2.move_piece([1, 6], [3, 6])
      expect(board1.en_passant_equivalent?(board2)).to be_falsy
    end
  end
end
