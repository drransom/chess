module Slideable
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
          legal_moves << test_position unless self.color == @board[test_position].color
          blocked = true
        else
          legal_moves << test_position
        end
        test_position = add_arrays(test_position, transformation)
      end
    end
    legal_moves
  end

  def add_arrays(arr1, arr2)
    [arr1[0] + arr2[0], arr1[1] + arr2[1]]
  end
end
