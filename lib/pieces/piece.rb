module PieceHelpers
  def add_arrays(arr1, arr2)
    [arr1[0] + arr2[0], arr1[1] + arr2[1]]
  end
end

class Piece
  include PieceHelpers

  attr_reader :color
  attr_accessor :position, :board

  def initialize(color, board, position)
    @color = color
    @board = board
    @position = position
    @board[position] = self
  end

  def moves
    raise "moves not implemented"
  end
end
