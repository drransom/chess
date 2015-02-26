# -*- coding: utf-8 -*-
require_relative 'piece'
require_relative 'slideable'

class Bishop < Piece

  include Slideable
  def moves_diagonally?
    true
  end

  def moves_orthogonally?
    false
  end

  def symbol
    "♝"
  end
end
