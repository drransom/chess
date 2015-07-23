require 'spec_helper'
require 'board'
require 'pieces'

context 'Castling' do
  subject(:board) { Board.new(false) }

  before(:each) do
    {0 => :black, 7 => :white }.each do |row, color|
      board[[row, 0]] = Rook.new(color, board, [row, 0])
      board[[row, 7]] = Rook.new(color, board, [row, 7])
      board[[row, 4]] = King.new(color, board, [row, 4])
    end
  end

  it "black can castle right" do
    board.move_piece([0, 4], [0, 6])
    expect(board[[0, 6]]).to be_a(King)
    expect(board[[0, 5]]).to be_a(Rook)
    expect(board.empty?([0, 4])).to be_truthy
    expect(board.empty?([0, 7])).to be_truthy
  end

  it "white can castle right" do
    board.move_piece([7, 4], [7, 6])
    expect(board[[7, 6]]).to be_a(King)
    expect(board[[7, 5]]).to be_a(Rook)
    expect(board.empty?([7, 4])).to be_truthy
    expect(board.empty?([7, 7])).to be_truthy
  end

  it "black can castle left" do
    board.move_piece([0, 4], [0, 1])
    expect(board[[0, 1]]).to be_a(King)
    expect(board[[0, 2]]).to be_a(Rook)
    expect(board.empty?([0, 4])).to be_truthy
    expect(board.empty?([0, 0])).to be_truthy
  end

  it "white can castle left" do
    board.move_piece([7, 4], [7, 1])
    expect(board[[7, 1]]).to be_a(King)
    expect(board[[7, 2]]).to be_a(Rook)
    expect(board.empty?([7, 4])).to be_truthy
    expect(board.empty?([7, 0])).to be_truthy
  end
end
