# -*- coding: utf-8 -*-
require_relative 'piece'
require_relative 'stepable'

class King < Piece
  include Stepable
  alias_method :stepable_moves, :moves

  def initialize(color, board, position)
    @has_moved = false
    super(color, board, position)
  end

  def move_diffs
    [[0, 1], [1, 1], [1, 0], [1, -1], [0, -1], [-1, -1], [-1, 0], [-1, 1]]
  end

  def symbol
    "♚"
  end

  def moves
    puts "calling moves method for #{self.color}"
    stepable_moves + castle_moves
  end

  def attack_spaces
    stepable_moves
  end

  def castle_moves
    if has_moved?
      []
    else
      []
    end
  end

  def has_moved?
    @has_moved
  end
end
