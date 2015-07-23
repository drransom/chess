require 'spec_helper'
require 'board'
require 'pieces'

piece_classes = [King, Queen, Rook, Bishop, Knight, Pawn]

describe Piece do
  piece_classes.each_with_index do |piece_class, idx|
    context ( "#{piece_class}" + '#==')  do
      piece_position = [rand(8), rand(8)]
      other_position = [(piece_position[0] + 1) % 8, (piece_position[1] + 3) % 8]
      let(:board) { double("board", :[]= => true) }
      let(:other_board) { double("board", :[]= => true)}
      let(:piece) { piece_class.new(:white, board, piece_position) }

      before(:each) do
        piece.position = piece_position
      end

      it "is itself at the same position" do
        expect(piece ==(piece)).to be_truthy
      end

      it "is still the same as itself if it changes positions" do
        piece.position = other_position
        expect(piece ==(piece)).to be_truthy
      end

      it "is the same as a piece of the same color at the same position" do
        other_piece = piece_class.new(:white, board, piece_position)
        third_piece = piece_class.new(:white, other_board, piece_position)
        expect(piece == other_piece).to be_truthy
        expect(piece.hash).to eq(other_piece.hash)
        expect(piece == third_piece).to be_truthy
        expect(piece.hash).to eq(third_piece.hash)
      end

      it "is different from a piece of a different color at the same position" do
        other_piece = piece_class.new(:black, board, piece_position)
        third_piece = piece_class.new(:black, other_board, piece_position)
        expect(piece == other_piece).to be_falsy
        expect(piece.hash).to_not eq(other_piece.hash)
        expect(piece == third_piece).to be_falsy
        expect(piece.hash).to_not eq(third_piece.hash)
      end

      it "is different from a piece of the same color at a different position" do
        other_piece = piece_class.new(:white, board, other_position)
        third_piece = piece_class.new(:white, other_board, other_position)
        expect(piece == other_piece).to be_falsy
        expect(piece.hash).to_not eq(other_piece.hash)
        expect(piece == third_piece).to be_falsy
        expect(piece.hash).to_not eq(third_piece.hash)
      end

      it "is different from a different piece or no piece" do
        new_class = piece_classes[(idx + 1) % piece_classes.length]
        other_piece = new_class.new(:white, board, piece_position)
        third_piece = new_class.new(:white, other_board, piece_position)
        expect(piece == other_piece).to be_falsy
        expect(piece.hash).to_not eq(other_piece.hash)
        expect(piece == third_piece).to be_falsy
        expect(piece.hash).to_not eq(third_piece.hash)
        expect(piece ==(nil)).to be_falsy
      end




    end
  end

  [King, Rook].each do |piece_class|
    context ( "#{piece_class}" + '#==') do
      let(:board) { double("board", :[]= => true) }
      let(:piece) { piece_class.new(:white, board, [0, 0]) }

      it "is different from the same piece that has moved" do
        other_piece = piece_class.new(:white, board, [0, 0])
        other_piece.update_has_moved
        expect(piece == other_piece).to be_falsy
        expect(piece.hash).to_not eq(other_piece.hash)
      end
    end

    context ( "#{piece_class}" + '#equivalent?')  do
      let(:board) { double("board", :[]= => true) }
      let(:piece) { piece_class.new(:white, board, [0, 0]) }

      it "is equivalent if the other piece has not moved" do
        other_piece = piece_class.new(:white, board, [0, 0])
        expect(piece.equivalent?(other_piece, [:white])).to be_truthy
      end

      it "is not equivalent if the other piece has moved" do
        other_piece = piece_class.new(:white, board, [0, 0])
        other_piece.update_has_moved
        expect(piece.equivalent?(other_piece, [:white])).to be_falsy
      end

      it "is equivalent if no class is given" do
        other_piece = piece_class.new(:white, board, [0, 0])
        other_piece.update_has_moved
        expect(piece.equivalent?(other_piece)).to be_truthy
      end
    end
  end
end
