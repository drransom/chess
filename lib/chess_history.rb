require_relative 'game'
require_relative 'board'
require_relative 'pieces'

class ChessHistory
  def initialize
    @game_states = []
    @three_repeats = false
  end

  def update_history(game)
    @game_states.push(ChessGameState.new(game))
  end

  def three_repeats?
    @game_states.select { |board| board == @boards.last }.length >= 3
  end

end

class ChessGameState
  def initialize(game)
    @board = game.board
    @en_passant_capture = game.has_en_passant_capture
    @can_castle_white = @board.can_castle(:white)
    @can_castle_black = @board.can_castle(:black)
  end

end
