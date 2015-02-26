# -*- coding: utf-8 -*-
require_relative 'piece'
require_relative 'slideable'

class Rook < Piece
  include Slideable

  def moves_diagonally?
    false
  end

  def moves_orthogonally?
    true
  end

  def symbol
    "♜"
  end

end
