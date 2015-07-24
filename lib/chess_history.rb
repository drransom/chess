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
    current_player_check = if @boards.length.even?
      Proc.new { |x| x.odd? }
    else
      Proc.new { |x| x.even? }
    end
    @boards.select.with_index do |board, index|
      board == @boards.last && current_player_check.call(index)
    end.length >= 3
  end

end
