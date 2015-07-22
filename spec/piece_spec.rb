require 'spec_helper'
require 'board'
require 'pieces'

piece_classes = [King, Queen, Rook, Bishop, Knight, Pawn]

describe Piece do
  piece_classes.each_with_index do |piece_class, idx|
    context ( "#{piece_class}" + '#same_piece_at_same_position?')  do
      random_position = [rand(8), rand(8)]
      other_position = [(random_position[0] + 1) % 8, (random_position[1] + 3) % 8]
      let(:board) { double("board", :[]= => true) }
      let(:other_board) { double("board", :[]= => true)}
      let(:piece) { piece_class.new(:white, board, random_position) }

      before(:each) do
        piece.position = random_position
      end

      it "is itself at the same position" do
        expect(piece.same_piece_at_same_position?(piece)).to be_truthy
      end

      it "is still the same as itself if it changes positions" do
        piece.position = other_position
        expect(piece.same_piece_at_same_position?(piece)).to be_truthy
      end

      it "is the same as a piece of the same color at the same position" do
        other_piece = piece_class.new(:white, board, random_position)
        third_piece = piece_class.new(:white, other_board, random_position)
        expect(piece.same_piece_at_same_position?(other_piece)).to be_truthy
        expect(piece.same_piece_at_same_position?(third_piece)).to be_truthy
      end

      it "is different from a piece of a different color at the same position" do
        other_piece = piece_class.new(:black, board, random_position)
        third_piece = piece_class.new(:black, other_board, random_position)
        expect(piece.same_piece_at_same_position?(other_piece)).to be_falsy
        expect(piece.same_piece_at_same_position?(third_piece)).to be_falsy
      end

      it "is different from a piece of the same color at a different position" do
        other_piece = piece_class.new(:white, board, other_position)
        third_piece = piece_class.new(:white, other_board, other_position)
        expect(piece.same_piece_at_same_position?(other_piece)).to be_falsy
        expect(piece.same_piece_at_same_position?(other_piece)).to be_falsy
      end

      it "is different from a different piece or no piece" do
        other_piece = piece_classes[(idx + 1) % piece_classes.length].new(:white, board, random_position)
        third_piece = piece_classes[(idx + 1) % piece_classes.length].new(:white, other_board, random_position)
        expect(piece.same_piece_at_same_position?(other_piece)).to be_falsy
        expect(piece.same_piece_at_same_position?(third_piece)).to be_falsy
        expect(piece.same_piece_at_same_position?(nil)).to be_falsy
      end

    end
  end

  [King, Rook].each do |piece_class|
    context ( "#{piece_class}" + '#same_piece_at_same_position?') do
      let(:board) { double("board", :[]= => true) }
      let(:piece) { piece_class.new(:white, board, [0, 0]) }

      it "is different from the same piece that has moved" do
        other_piece = piece_class.new(:white, board, [0, 0])
        other_piece.update_has_moved
        expect(piece.same_piece_at_same_position?(other_piece)).to be_falsy
      end
    end
  end
end
