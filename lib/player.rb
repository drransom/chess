class Player
  attr_accessor :color

  def initialize(color)
    @color = color
  end

  def confirm_quit
    'n'
  end

  def request_pawn(board = nil)
    'queen'
  end

  def request_fifty_move_draw
    true
  end

  def request_three_repeat_draw
    true
  end

  def add_new_game(game = nil)
  end

  def notify_of_color
  end
end

class HumanPlayer < Player

  def play_turn(board = nil)
    puts "It is #{@color}'s turn. Please select a move (e.g. e2 e4) or press q to quit: "
    gets.downcase.chomp
  end

  def confirm_quit
    puts "Are you sure you want to quit? Enter y to confirm, or enter "+
      "a valid move to continue playing:"
    gets.downcase.chomp
  end

  def request_pawn(board = nil)
    puts "Congratulations! You get to promote a pawn!"
    puts "Choose bishop, knight, queen, or rook."
    gets.downcase.chomp
  end

  def request_fifty_move_draw
    puts "#{color.to_s.capitalize} may now request a draw thanks to the fifty move rule."
    puts "Enter 'y' for draw, or any other key to continue playing."
    gets[0].match(/y/i)
  end

  def request_three_repeat_draw
    puts "#{color.to_s.capitalize} may now request a draw thanks to the three repeat rule."
    puts "Enter 'y' for draw, or any other key to continue playing."
    gets[0].match(/y/i)
  end

  def notify_of_color
    puts "You are #{color}."
  end
end

class ComputerPlayer < Player

  def add_new_game(game)
    @game = game
    @board = game.board
  end

  def play_turn
     move = get_best_move(@board.legal_moves(color))
     convert_move_to_chess_notation(move)
  end

  private

  def get_best_move(possible_moves)
    select_best_moves(possible_moves).sample
  end

  def convert_move_to_chess_notation(move)
    letters = ('a'..'h').to_a
    rows = (1..8).to_a.reverse
    move.map { |row, col| "#{letters[col]}#{rows[row]}" }.join(' ')
  end

  def select_best_moves(possible_moves)
    best_moves = [possible_moves[0]]
    current_best_result = find_result(possible_moves[0])
    (1...possible_moves.length).each do |i|
      move_result = find_result(possible_moves[i])
      case compare_results(current_best_result, move_result)
      when 1
        best_moves = [possible_moves[i]]
        current_best_result = move_result
      when 0
        best_moves << possible_moves[i]
      end
    end
    best_moves
  end

  def compare_results(result1, result2)
    results = [:stalemate, :nilclass, :pawn, :knight, :bishop, :rook, :queen, :pawn_promotion, :checkmate]
    result1_val = results.find_index(result1)
    result2_val = results.find_index(result2)
    if result2_val > result1_val
      1
    elsif result2_val == result1_val
      0
    else
      -1
    end
  end

  def find_result(move)
    from, to = move
    if @board.move_checkmates_other_color?(from, to, color)
      :checkmate
    elsif @board.move_stalemates_other_color?(from, to, color)
      :stalemate
    elsif (@board[from]).is_a?(Pawn) && (to[0] % 7 == 0)
      :pawn_promotion
    else
      @board[to].class.to_s.downcase.to_sym
    end
  end
end
