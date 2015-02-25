module Stepable
  def moves
    legal_moves = []

    move_diffs.each do |transformation|
      test_position = add_arrays(@position, transformation)
      next if @board.out_of_bounds?(test_position)
      unless @board.occupied?(test_position) &&
          self.color == @board[test_position].color
        legal_moves << test_position
      end
    end

    legal_moves
  end

  def add_arrays(arr1, arr2)
    [arr1[0] + arr2[0], arr1[1] + arr2[1]]
  end
end
