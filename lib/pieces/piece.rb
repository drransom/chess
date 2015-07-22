require_relative '../chess_helpers.rb'

class Piece
  include ChessHelper

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

  def update_has_moved
  end

  def ==(other)
    self.class == other.class &&
    color == other.color &&
    position == other.position
  end

  # def hash
  #   [self.class, color, position].hash
  # end
end
