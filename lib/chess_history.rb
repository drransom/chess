require_relative 'game'
require_relative 'board'
require_relative 'pieces'

class ChessHistory
  def initialize
    @boards = []
  end

  def update_history(board)
    @boards.push(board)
  end

  def three_repeats?
    @boards.select { |board| board == @boards.last }.length >= 3
  end

end
