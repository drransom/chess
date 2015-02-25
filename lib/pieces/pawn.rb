# -*- coding: utf-8 -*-
require_relative 'piece'

class Pawn < Piece
  def initialize(color, board, position)
    super(color, board, position)
    @moved = false
  end

  def symbol
    @color == :white ? "♙" : "♟"
  end

  def attack_diffs
    moves = [[1, 1], [-1, 1]]

    if @color == :white
      moves.each { |move| move[1] *= -1 }
    end

    moves
  end

  def move_diffs
    moves = [[0,1]]
    moves << [0, 2] unless @moved

    if @color == :white
      moves.each { |move| move[1] *= -1 }
    end
    moves
  end

  def moves
    legal_moves = []

    move_diffs.each do |transformation|
      test_position = add_arrays(@position, transformation)
      break if @board.out_of_bounds?(test_position) || @board.occupied?(test_position)
      legal_moves << test_position
    end

    attack_diffs.each do |transformation|
      test_position = add_arrays(@position, transformation)
      next if @board.out_of_bounds?(test_position) ||
        (@board.occupied?(test_position) &&
        @board[test_position].color = @color)
      legal_moves << test_position
    end
    legal_moves
  end

  def add_arrays(arr1, arr2)
    [arr1[0] + arr2[0], arr1[1] + arr2[1]]
  end
end
