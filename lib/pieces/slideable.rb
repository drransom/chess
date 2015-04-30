require_relative 'piece'

module Slideable
  include ChessHelper

  def orthogonal_dirs
    [[0, 1], [0, -1], [1, 0], [-1, 0]]
  end

  def diagonal_dirs
    [[1, 1], [-1, 1], [1, -1], [-1, -1]]
  end

  def move_dirs
    transformations = []
    transformations += orthogonal_dirs if moves_orthogonally?
    transformations += diagonal_dirs if moves_diagonally?
    transformations
  end

  def moves
    legal_moves = []

    move_dirs.each do |transformation|
      blocked = false
      test_position = add_arrays(@position, transformation)
      until blocked || @board.out_of_bounds?(test_position)
        if @board.occupied?(test_position)
          legal_moves << test_position unless self.color == @board.color(test_position)
          blocked = true
        else
          legal_moves << test_position
        end
        test_position = add_arrays(test_position, transformation)
      end
    end
    legal_moves
  end

  def attack_spaces
    moves
  end
end
