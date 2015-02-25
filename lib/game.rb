require_relative 'board'

class Game
  def initialize
    @white_player = HumanPlayer.new
    @black_player = HumanPlayer.new
    @current_player = @white_player
  end

  def play_chess
    initialize_board
    result = play_game
    display_result(result)
  end

  def play_game
    until game_over?
      move = @current_player.request_move
      @board.update(move)

      flip_current_player
    end

  end

  def flip_current_player
    @current_player = @current_player == @white_player ? @black_player : @white_player
  end

  def game_over
    #stalemnate
    #checkmate
  end
end

class HumanPlayer
end
