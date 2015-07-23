# -*- coding: utf-8 -*-
require_relative 'piece'
require_relative 'slideable'

class Rook < Piece
  include Slideable

  def initialize(color, board, position)
    @has_moved = false
    super(color, board, position)
  end

  def moves_diagonally?
    false
  end

  def moves_orthogonally?
    true
  end

  def symbol
    "♜"
  end

  def update_has_moved
    @has_moved = true
  end

  def has_moved?
    @has_moved
  end

  def ==(other)
    super(other) && (has_moved? == other.has_moved?)
  end

  def hash
    (super ^ has_moved?.hash).hash
  end

  def equivalent?(other_piece, can_castle_colors = [])
    if can_castle_colors.include?(color)
      self == other_piece
    else
      self.class == other_piece.class &&
      self.class.superclass.instance_method(:==).bind(self).call(other_piece)
    end
  end



end
