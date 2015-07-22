# -*- coding: utf-8 -*-
require_relative 'piece'
require_relative 'stepable'

class King < Piece
  include Stepable
  alias_method :stepable_moves, :moves

  def initialize(color, board, position)
    @has_moved = false
    @initial_position = position
    super(color, board, position)
  end

  def move_diffs
    [[0, 1], [1, 1], [1, 0], [1, -1], [0, -1], [-1, -1], [-1, 0], [-1, 1]]
  end

  def symbol
    "♚"
  end

  def moves
    stepable_moves + castle_moves
  end

  def attack_spaces
    stepable_moves
  end

  def castle_moves
    if has_moved? || @board.in_check?(self.color)
      []
    else
      castles = []
      left_castle_move = left_castle
      castles << left_castle_move if left_castle_move
      right_castle_move = right_castle
      castles << right_castle_move if right_castle_move
      castles
    end
  end

  def left_castle
    test_position = add_arrays(@position, [0, -4])
    if @board.valid_rook?(test_position, self.color) &&
              @board.all_valid?(self, [[0, -3], [0, -2], [0, -1]])
      test_position
    else
      nil
    end
  end

  def right_castle
    test_position = add_arrays(@position, [0, 3])
    if @board.valid_rook?(test_position, self.color) &&
              @board.all_valid?(self, [[0, 1], [0, 2]])
      test_position
    else
      nil
    end
  end

  def has_moved?
    @has_moved
  end

  def update_has_moved
    @has_moved = true
  end

  def ==(other)
    super(other) && (has_moved? == other.has_moved?)
  end

  # def hash
  #   (super ^ has_moved?.hash).hash
  # end


end
