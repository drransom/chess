require_relative 'pieces'
require 'byebug'

class Board
  attr_accessor :grid

  def initialize(fill_board = true)
    @grid = Array.new(64)
    build_grid if fill_board
  end

  def [](position)
    row, col = position
    raise 'invalid position' if out_of_bounds?(position)
    @grid[(row * 8) + col]
  end

  def []=(position, new_value)
    row, col = position
    raise 'invalid position' if out_of_bounds?(position)
    @grid[(row * 8) + col] = new_value
  end

  def checkmate?(color)
    in_check?(color) && !has_legal_move?(color)
  end

  def has_legal_move?(color)
    player_pieces = find_all_pieces(color)

    player_pieces.each do |piece|
      piece.moves.each do |move|
        clone = self.clone
        clone.move_piece(piece.position, move)
        return true unless clone.in_check?(color)
      end
    end
    false
  end

  def stalemate?(color)
    !(in_check?(color) || has_legal_move?(color))
  end

  def in_check?(color)
    king = @grid.find { |piece| piece.is_a?(King) && piece.color == color }
    king ? threatened?(king.position, king.color) : false
  end

  def threatened?(position, color)
    opponent_pieces = find_all_pieces(flip_color(color))
    opponent_pieces.each do |piece|
      return true if piece.moves.include?(position)
    end
    false
  end

  def find_all_pieces(color)
    @grid.select { |piece| piece && piece.color == color }
  end

  def flip_color color
    color == :white ? :black : :white
  end

  def occupied?(position)
    self[position] ? true : false
  end

  def empty?(position)
    !occupied?(position)
  end

  def color(position)
    self[position].color
  end

  def out_of_bounds?(position)
    !((0...8).include?(position[0]) && (0...8).include?(position[1]))
  end

  def clone
    clone_grid = []

    @grid.each do |square|
      clone_grid << (square ? square.dup : nil)
    end

    clone_board = Board.new(false)
    clone_board.grid = clone_grid
    clone_board
  end

  def move_legal?(from, to)
    self[from].moves.include?(to)
  end

  def leaves_self_in_check?(from, to, color)
    clone = self.clone
    clone.move_piece(from, to)
    clone.in_check?(color)
  end

  def move_piece(from, to)
    self[to] = self[from]
    self[from] = nil
    self[to].position = to
  end

  def build_grid
    build_pawns
    build_back_row(:black)
    build_back_row(:white)
  end

  def build_pawns
    8.times do |col|
      position = [1, col]
      self[position] = Pawn.new(:black, self, position)
      position = [6, col]
      self[position] = Pawn.new(:white, self, position)
    end
  end

  def build_back_row(color)
    #debugger
    row = (color == :black) ? 0 : 7
    pieces = [:rook, :knight, :bishop, :queen, :king, :bishop, :knight, :rook]
    pieces.each_with_index do |piece, index|
      position = [row, index]
      self[position] = case piece
      when :rook
        Rook.new(color, self, position)
      when :knight
        Knight.new(color, self, position)
      when :bishop
        Bishop.new(color, self, position)
      when :queen
        Queen.new(color, self, position)
      when :king
        King.new(color, self, position)
      end
    end
  end

  def display
    letters = "  " + %w( a b c d e f g h).join(" ")
    display_string = letters + "\n"
    8.times do |i|
      display_string += "#{8 - i} "
      8.times do |j|
        square = self[[i,j]]
        display_string += (square ? square.symbol : "_") + " "
      end
      display_string += " #{8 - i}\n"
    end
    display_string += letters
    display_string
  end
end
