require_relative 'board'
require_relative 'player'
require_relative 'chess_history'
require_relative '../vendor/keypress'
require_relative 'errors'
require 'byebug'

class Game
  attr_reader :history, :board

  def initialize(options = {})
    @white_player = options[:white] || HumanPlayer.new(:white)
    @black_player = options[:black] || HumanPlayer.new(:black)
    @current_player = @white_player
    @board = options[:board] || Board.new
    @history = ChessHistory.new
    @history.update_history(board)
  end

  def play_chess(moves = [])
    initialize_game(moves)
    result = play_game
    display_result(result)
  end

  def self.other_color(color)
    color == :white ? :black : :white
  end

  private

  def initialize_game(moves = [])
    puts "Welcome to chess."
    @moves = moves
    @move_counter = 0
    @fifty_move_draw = false
    @three_repeat_draw = false
  end

  def play_game
    until game_over?
      display_board
      quit = play_one_turn
      return quit if quit == :quit || quit == :three_repeat_draw
      flip_current_player
    end
  end

  def play_one_turn
    validate_three_repeat_rule
    validate_fifty_move_rule
    begin
      return if three_repeat_draw? || fifty_move_draw?
      move = @moves.empty? ? @current_player.play_turn : @moves.shift
      if move[0].downcase == 'q'
        move = @current_player.confirm_quit
        if move[0] && move[0].downcase == 'y'
          return :quit
        end
      end
      process_outcome(move, try_move_piece(move))
    rescue => e
      puts e.message
      retry
    end
  end

  def validate_three_repeat_rule
    if history.three_repeats?
      @current_player.request_three_repeat_draw
    else
      false
    end
  end

  #returns whether a pawn needs to be promoted
  def try_move_piece(move)
    raise InputError.new unless valid_format?(move)
    from = translate_move_notation(move[0..1])
    to = translate_move_notation(move[-2..-1])
    raise PieceNotOwnedError.new if !@board.occupied?(from) ||
      @board.color(from) != @current_player.color
    raise IllegalMoveError.new unless @board.move_legal?(from, to)
    raise CheckError.new if @board.leaves_self_in_check?(from, to, @current_player.color)
    @board.move_piece(from, to)
  end

  def process_outcome(move, move_outcome)
    @history.update_history(board)
    validate_three_repeat_rule
    case move_outcome
    when :pawn_promotion
      promote_pawn(move)
    when :pawn_move, :capture
      reset_move_counter
    else
      @move_counter += 1
      validate_fifty_move_rule
    end
  end

  def reset_move_counter
    @move_counter = 0
  end

  def fifty_move_draw?
    @fifty_move_draw
  end

  def validate_fifty_move_rule
    if @move_counter >= 100 # "moves" count both players
      @fifty_move_draw = @current_player.request_fifty_move_draw
    end
  end

  def valid_format?(move)
    move.match(/\A[a-hA-H][1-8][, ]+[a-hA-H][1-8]\Z/)
  end

  def translate_move_notation(string)
    row = 8 - string[1].to_i
    col = string[0].ord - 97
    [row, col]
  end

  def promote_pawn(move)
    display_board
    begin
      piece = @current_player.request_pawn.to_sym
      raise PromotePawnError.new unless [:bishop, :knight, :queen, :rook].include?(piece)
    rescue => e
      puts e.message
      retry
    end
    reset_move_counter
    new_position = (move.split.map { |elem| elem }).last
    @board.promote_pawn(piece, translate_move_notation(new_position))
  end

  def flip_current_player
    @current_player = @current_player == @white_player ? @black_player : @white_player
  end

  def game_over?
    fifty_move_draw? || three_repeat_draw? ||
    @board.checkmate?(@current_player.color) ||
    @board.stalemate?(@current_player.color)
  end

  def display_board
    puts @board.display
  end

  def display_result(result)
    if result == :quit
      puts "You have quit the program."
    else
      display_winner
    end
  end

  def display_winner
    display_board
    if fifty_move_draw? || three_repeat_draw?
      puts "Draw."
    elsif  @board.stalemate?(@current_player.color)
      puts "Stalemate."
    else
      flip_current_player
      puts "#{@current_player.color} wins!"
    end
  end

  def self.make_moves_from_file(filename)
    @moves = File.readlines(filename).map(&:chomp)
  end

  def three_repeat_draw?
    @three_repeat_draw
  end
end



if __FILE__ == $0
  filename = ARGV.shift
  ARGV.shift until ARGV.empty?
  begin
    moves = Game.make_moves_from_file(filename)
  rescue
    moves = []
  end
  Game.new.play_chess(moves)
end
