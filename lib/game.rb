require_relative 'board'

class InputError < ArgumentError
  def message
    "Please enter your move in this format: a1 a2"
  end
end

class PieceNotOwnedError < StandardError
  def message
    "You do not own a piece at that square."
  end
end

class CheckError <StandardError
  def message
    "That move would leave your king in check."
  end
end

class PromotePawnError < StandardError
  def message
    "You can only promote to a bishop, knight, queen, or rook."
  end
end

class IllegalMoveError < StandardError
  def message
    "That move is not legal."
  end
end

class Game
  def initialize
    @white_player = HumanPlayer.new(:white)
    @black_player = HumanPlayer.new(:black)
    @current_player = @white_player
    @board = Board.new
  end

  def play_chess
    #initialize_game
    play_game
    display_result
  end

  def play_game
    until game_over?
      display_board
      begin
        move = @current_player.play_turn #needs error checking
        promote_pawn(move) if try_move_piece(move)
      rescue => e
        puts e.message
        #puts e.backtrace
        retry
      end
      flip_current_player
    end

  end

  #returns whether a pawn needs to be promoted
  def try_move_piece(move)
    moves = move.split.map { |e| e.downcase }
    raise InputError.new unless valid_format?(moves)
    from = translate_move_notation(moves[0])
    to = translate_move_notation(moves[1])
    raise PieceNotOwnedError.new if !@board.occupied?(from) ||
      @board[from].color != @current_player.color
    raise IllegalMoveError.new unless @board.move_legal?(from, to)
    raise CheckError.new if @board.leaves_self_in_check?(from, to, @current_player.color)
    @board.move_piece(from, to)
  end

  def valid_format?(moves)
    moves.length == 2 &&
      ('a'..'h').include?(moves[0][0]) &&
      ('a'..'h').include?(moves[1][0]) &&
      ('1'..'8').include?(moves[0][1]) &&
      ('1'..'8').include?(moves[1][1])
  end

  def translate_move_notation(string)
    row = 8 - string[1].to_i
    col = string[0].ord - 97
    [row, col]
  end

  def promote_pawn(move)
    begin
      piece = @current_player.request_pawn[0].downcase.to_sym
      raise PromotePawnError.new unless [:b, :k, :q, :r].include?(piece)
    rescue => e
      puts e.message
      retry
    end
    new_position = (move.split.map { |e| e.downcase }).last
    @board.promote_pawn(piece, translate_move_notation(new_position))
  end



  def flip_current_player
    @current_player = @current_player == @white_player ? @black_player : @white_player
  end

  def game_over?
    @board.checkmate?(@current_player.color) || @board.stalemate?(@current_player.color)
  end

  def display_board
    puts @board.display
  end

  def display_result
    display_board
    if @board.stalemate?(@current_player.color)
      puts "Stalemate."
    else
      flip_current_player
      puts "#{@current_player.color} wins!"
    end
  end

end

class HumanPlayer
  attr_accessor :color
  def initialize(color)
    @color = color
  end

  def play_turn
    puts "It is #{@color}'s turn. Please select a move: "
    #next line uncommented for testing purposes
    #$moves.empty? ? gets.chomp : $moves.shift
    gets.chomp
  end

  def request_pawn
    puts "Congratulations! You get to promote a pawn!"
    puts "Choose bishop, knight, queen, or rook."
    gets.chomp
  end
end


if __FILE__ == $0
  $moves = []
  $moves = Board.make_moves_from_file('lib/pawnpromotion.txt')
  Game.new.play_chess
end
