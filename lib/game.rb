require_relative 'board'
require_relative 'keypress'
require_relative 'errors'

class Game
  def initialize
    @white_player = HumanPlayer.new(:white)
    @black_player = HumanPlayer.new(:black)
    @current_player = @white_player
    @board = Board.new
  end

  def play_chess(moves = [])
    @moves = moves
    initialize_game
    play_game
    display_result
  end

  def self.other_color(color)
    color == :white ? :black : :white
  end

  private

    def initialize_game
      puts "Welcome to chess."
    end

    def play_game
      until game_over?
        @board.reset_en_passant(@current_player.color)
        display_board
        begin
          move = @moves.empty? ? @current_player.play_turn : @moves.shift
          promote_pawn(move) if try_move_piece(move)
        rescue => e
          puts e.message
          retry
        end
        flip_current_player
      end
    end

    #returns whether a pawn needs to be promoted
    def try_move_piece(move)
      raise InputError.new unless valid_format?(move)
      from = translate_move_notation(move[0..1].downcase)
      to = translate_move_notation(move[-2..-1].downcase)
      raise PieceNotOwnedError.new if !@board.occupied?(from) ||
        @board.color(from) != @current_player.color
      raise IllegalMoveError.new unless @board.move_legal?(from, to)
      raise CheckError.new if @board.leaves_self_in_check?(from, to, @current_player.color)
      @board.move_piece(from, to)
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
        piece = @current_player.request_pawn.downcase.to_sym
        raise PromotePawnError.new unless [:bishop, :knight, :queen, :rook].include?(piece)
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

    def self.make_moves_from_file(filename)
      @moves = File.readlines(filename).map(&:chomp)
    end
end

class HumanPlayer
  attr_accessor :color
  def initialize(color)
    @color = color
  end

  def play_turn
    puts "It is #{@color}'s turn. Please select a move: "
    gets.chomp
  end

  def request_pawn
    puts "Congratulations! You get to promote a pawn!"
    puts "Choose bishop, knight, queen, or rook."
    gets.chomp
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
