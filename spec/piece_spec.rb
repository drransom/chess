require 'spec_helper'
require 'board'
require 'pieces'

piece_classes = [King, Queen, Rook, Bishop, Knight, Pawn]

describe Piece do
  piece_classes.each_with_index do |piece_class, idx|
    context piece_class do
      let(:board) { double("board", :[]= => true) }
      let(:piece) { piece_class.new(:white, board, [0, 0]) }

      before(:example) do
        piece.position = [0, 0]
      end

      it "is itself at the same position" do
        expect piece.same_piece_at_same_position?(piece).to be_true
      end

      it "is still itself if it changes positions" do
        piece.position = [1, 1]
        expect piece.same_piece_at_same_position?(piece).to be_true
      end

      it "is the same as a piece of the same color at the same position" do
        other_piece = King.new(:white, board, [0, 0])
        expect piece.same_piece_at_same_position(other_piece).to be_false
      end

      it "is different from a piece of a different color at the same position" do
        other_piece = King.new(:black, board, [0, 0])
        expect piece.same_piece_at_same_position(other_piece).to be_false
      end

      it "is different from a piece of the same color at a different position" do
        other_piece = King.new(:white, board, [1, 1])
        expect piece.same_piece_at_same_position(other_piece).to be_false
      end

      it "is different from a different piece or no piece" do
        other_piece = piece_classes[(idx + 1) % piece_classes.length].new(:white, board, [0, 0])
        expect piece.same_piece_at_same_position?(other_piece).to be_false
        expect piece.same_piece_at_same_position?(nil).to be_false
      end

    end
  end

  context King do |variable|
    it "is different from the same piece that has moved" do
      let(:board) { double("board", :[]= => true) }
      let(:king) { King.new(:white, board, [0, 0]) }
      other_king = King.new(:white, board, [0, 0])
      other_king.update_has_moved
      expect king.same_piece_at_same_position?(other_king).to be_false
    end
  end
end
