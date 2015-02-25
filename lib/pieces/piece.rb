require 'byebug'
class Piece
  attr_reader :color
  attr_accessor :position

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
