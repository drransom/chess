class Player
  attr_accessor :color

  def initialize(color)
    @color = color
  end

  def request_three_repeat_draw
    'n'
  end
end

class HumanPlayer < Player

  def play_turn
    puts "It is #{@color}'s turn. Please select a move (e.g. e2 e4) or press q to quit: "
    gets.downcase.chomp
  end

  def confirm_quit
    puts "Are you sure you want to quit? Enter y to confirm, or enter "+
      "a valid move to continue playing:"
    gets.downcase.chomp
  end

  def request_pawn
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
end
