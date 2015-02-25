# -*- coding: utf-8 -*-
require_relative 'piece'
require_relative 'slideable'

class Queen < Piece
  include Slideable

  def moves_diagonally?
    true
  end

  def moves_orthogonally?
    true
  end

  def symbol
    @color == :white ? "♕" : "♛"
  end

end
