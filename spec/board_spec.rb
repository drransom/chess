require 'spec_helper'
require 'board'
require 'pieces'

describe Board do
  subject(:b) { Board.new }

  describe '#[]' do
    it 'has a [] getter method' do
      expect(b).to respond_to(:[])
    end

    it 'raises an exception if the position is invalid' do
      expect do
        b[[9, 9]]
      end.to raise_exception('invalid position')
    end
  end

  describe '#[]=' do
    it 'has a []= getter method' do
      expect(b).to respond_to(:[]=)
    end

    it 'raises an exception if the position is invalid' do
      expect do
        pos = 9, 9
        b[pos] = :blah
      end.to raise_exception('invalid position')
    end
  end

  describe '#in_check?' do
    it 'correctly checks for a board that is not in check' do
      expect(b).not_to be_in_check(:black)
      expect(b).not_to be_in_check(:white)
    end

    it 'correctly checks for a board that IS in check' do
      b2 = Board.new(false)
      b2[[4, 4]] = Queen.new(:black, b2, [4, 4])
      b2[[4, 6]] = King.new(:white, b2, [4, 6])
      b2[[0, 0]] = King.new(:black, b2, [0, 0])
      expect(b2).to be_in_check(:white)
      expect(b2).not_to be_in_check(:black)
    end
  end

  describe '#checkmate?' do
    it 'correctly checks for a board that is not in checkmate' do
      b2 = Board.new(false)
      b2[[4, 4]] = Queen.new(:black, b2, [4, 4])
      b2[[4, 6]] = King.new(:white, b2, [4, 6])
      b2[[0, 0]] = King.new(:black, b2, [0, 0])
      expect(b2).not_to be_checkmate(:white)
      expect(b2).not_to be_checkmate(:black)
    end

    it 'correctly checks for a board that IS in checkmate' do
      b2 = Board.new(false)
      b2[[1, 4]] = Rook.new(:black, b2, [1, 4])
      b2[[0, 4]] = Rook.new(:black, b2, [0, 4])
      b2[[4, 6]] = King.new(:black, b2, [4, 6])
      b2[[0, 0]] = King.new(:white, b2, [0, 0])
      expect(b2).to be_checkmate(:white)
      expect(b2).not_to be_checkmate(:black)
    end
  end

  describe '::new(true)' do
    it 'adds pawns to grid' do
      expect(b[[1, 1]].class).to eq(Pawn)
      expect(b[[6, 6]].class).to eq(Pawn)
      expect(b[[6, 6]].color).to eq(:white)
    end

    it 'adds rook to grid' do
      expect(b[[0, 0]].class).to eq(Rook)
      expect(b[[0, 0]].color).to eq(:black)
      expect(b[[0, 7]].class).to eq(Rook)
      expect(b[[7, 0]].class).to eq(Rook)
      expect(b[[7, 7]].color).to eq(:white)
    end

    it 'adds knights to grid' do
      expect(b[[0, 1]].class).to eq(Knight)
      expect(b[[0, 1]].color).to eq(:black)
      expect(b[[0, 6]].class).to eq(Knight)
      expect(b[[7, 1]].class).to eq(Knight)
      expect(b[[7, 6]].color).to eq(:white)
    end

    it 'adds bishops to grid' do
      expect(b[[0, 2]].class).to eq(Bishop)
      expect(b[[0, 2]].color).to eq(:black)
      expect(b[[0, 5]].class).to eq(Bishop)
      expect(b[[7, 2]].class).to eq(Bishop)
      expect(b[[7, 5]].color).to eq(:white)
    end

    it 'adds kings to grid' do
      expect(b[[0, 4]].class).to eq(King)
      expect(b[[0, 4]].color).to eq(:black)
      expect(b[[7, 4]].class).to eq(King)
      expect(b[[7, 4]].color).to eq(:white)
    end

    it 'adds queens to grid' do
      expect(b[[0, 3]].class).to eq(Queen)
      expect(b[[0, 3]].color).to eq(:black)
      expect(b[[7, 3]].class).to eq(Queen)
      expect(b[[7, 3]].color).to eq(:white)
    end
  end

  it '#empty? returns true if a space is empty' do
    expect(b.empty?([4, 4])).to be(true)
    expect(b.empty?([0, 0])).to be(false)
  end

  describe '#==' do

    it 'finds that two boards with identical setups are ==' do
      b2 = Board.new
      expect(b == b2).to be_truthy
    end

    it 'finds that two boards with different setups are not ==' do
      b2 = Board.new(false)
      b2[[4, 4]] = Rook.new(:black, b2, [4, 4])
      b2[[4, 6]] = King.new(:black, b2, [4, 6])
      b2[[0, 0]] = King.new(:white, b2, [0, 0])
      expect(b == b2).to be_falsy
    end

    it 'finds that boards are not == if a king has moved on one but not the other' do
      b2 = Board.new(false)
      b2[[0, 4]] = King.new(:black, b2, [0, 4])
      b2[[0, 0]] = Rook.new(:black, b2, [0, 0])
      b2[[7, 4]] = King.new(:white, b2, [7, 4])
      b3 = Board.new(false)
      b3[[0, 4]] = King.new(:black, b3, [0, 4])
      b3[[0, 0]] = Rook.new(:black, b3, [0, 0])
      b3[[7, 4]] = King.new(:white, b3, [7, 4])
      expect(b2 == b3).to be_truthy
      b2.move_piece([0, 4], [0, 5])
      b2.move_piece([0, 5], [0, 4])
      expect(b2 == b3).to be_falsy
    end

  end

  describe '#hash' do
    en_passant_setup = Proc.new do |b|
      b[[0, 4]] = King.new(:black, b, [0, 4])
      b[[7, 4]] = King.new(:white, b, [7, 4])
      defending_pawn1 = Pawn.new(:black, b, [1, 6])
      defending_pawn2 = Pawn.new(:black, b, [1, 4])
      attacking_pawn =  Pawn.new(:white, b, [3, 5])
      [defending_pawn1, defending_pawn2, attacking_pawn].each do |pawn|
        b[pawn.position] = pawn
      end
    end

    it 'finds that two boards with identical setups have the same hash' do
      b2 = Board.new
      expect(b.hash).to eq(b2.hash)
    end

    it 'finds that two boards with different setups have different hashes' do
      b2 = Board.new(false)
      b2[[1, 4]] = Rook.new(:black, b2, [4, 4])
      b2[[4, 6]] = King.new(:black, b2, [4, 6])
      b2[[0, 0]] = King.new(:white, b2, [0, 0])
      expect(b.hash).not_to eq(b2.hash)
    end

    it 'the same en passant status produces the same hash' do
      b1 = Board.new(false)
      b2 = Board.new(false)
      [b1, b2].each do |b|
        en_passant_setup.call(b)
      end

      b1.move_piece([1, 6], [3, 6])
      b2.move_piece([1, 6], [3, 6])
      expect(b1.hash).to eq(b2.hash)
    end

    it 'different en passant statuses produce different hashes' do
      b1 = Board.new(false)
      b2 = Board.new(false)
      [b1, b2].each do |b|
        en_passant_setup.call(b)
      end

      b1.move_piece([1, 6], [3, 6])
      b1.move_piece([0, 4], [0, 5])
      b1.move_piece([1, 4], [3, 4])
      b2.move_piece([1, 4], [3, 4])
      b2.move_piece([0, 4], [0, 5])
      b2.move_piece([1, 6], [3, 6])

      expect(b1.hash).not_to eq(b2.hash)
    end

  end

  describe '#clone' do
    it 'can clone a board' do
      expect(b.clone).to be_a Board
    end

    it 'cloned boards are == to original board' do
      expect(b.clone == b).to be_truthy
    end

  end

  describe '#can_castle' do

    it "can castle when initialized" do
      expect(b.can_castle?(:white)).to be_truthy
      expect(b.can_castle?(:black)).to be_truthy
    end

    it "can castle when one rook has moved" do
      b2 = Board.new(false)
      b2[[0, 0]] = Rook.new(:black, b2, [0, 0])
      b2[[0, 7]] = Rook.new(:black, b2, [0, 7])
      b2[[0, 4]] = King.new(:black, b2, [0, 4])
      b2[[7, 0]] = Rook.new(:white, b2, [7, 0])
      b2[[7, 7]] = Rook.new(:white, b2, [7, 7])
      b2[[7, 4]] = King.new(:white, b2, [7, 4])
      b2.move_piece([0, 0], [0, 1])
      expect(b2.can_castle?(:black)).to be_truthy
    end

    it "cannot castle when both rooks have moved" do
      b2 = Board.new(false)
      b2[[0, 0]] = Rook.new(:black, b2, [0, 0])
      b2[[0, 7]] = Rook.new(:black, b2, [0, 7])
      b2[[0, 4]] = King.new(:black, b2, [0, 4])
      b2[[7, 0]] = Rook.new(:white, b2, [7, 0])
      b2[[7, 7]] = Rook.new(:white, b2, [7, 7])
      b2[[7, 4]] = King.new(:white, b2, [7, 4])
      b2.move_piece([0, 0], [0, 1])
      b2.move_piece([0, 7], [0, 6])
      expect(b2.can_castle?(:black)).to be_falsy
    end

    it "cannot castle when the king has moved" do
      b2 = Board.new(false)
      b2[[0, 0]] = Rook.new(:black, b2, [0, 0])
      b2[[0, 4]] = King.new(:black, b2, [0, 4])
      b2[[7, 0]] = Rook.new(:white, b2, [7, 0])
      b2[[7, 4]] = King.new(:white, b2, [7, 4])
      b2.move_piece([0, 4], [0, 5])
      expect(b2.can_castle?(:black)).to be_falsy
      b2.move_piece([0, 5], [0, 4])
      expect(b2.can_castle?(:black)).to be_falsy
    end

    it "cannot castle if there are no rooks" do
      b2 = Board.new(false)
      b2[[0, 0]] = Rook.new(:black, b2, [0, 0])
      b2[[0, 4]] = King.new(:black, b2, [0, 4])
      b2[[7, 4]] = King.new(:white, b2, [7, 4])
      expect(b2.can_castle?(:white)).to be_falsy
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

  it 'displays nicely' do
    # this is for you :)
    b.display
  end
end
