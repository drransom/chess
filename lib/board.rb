require_relative 'pieces'
require_relative 'game'
require 'colorize'
require 'byebug'

class Board
  attr_accessor :grid, :en_passant

  def initialize(fill_board = true)
    @grid = Array.new(64)
    @en_passant = { white: nil, black: nil, target: nil }
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

  def stalemate?(color)
    !in_check?(color) && !has_legal_move?(color)
  end

  def checkmate?(color)
    in_check?(color) && !has_legal_move?(color)
  end

  def in_check?(color)
    king = @grid.find { |piece| piece.is_a?(King) && piece.color == color }
    king ? threatened?(king.position, king.color) : false
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
    clone_board.grid.compact.each {|piece| piece.board = clone_board }
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

  # return: whether a pawn needs to be promoted, boolean
  def move_piece(from, to)
    self[to] = self[from]
    current_piece = self[to]
    self[from] = nil
    current_piece.position = to
    process_en_passant(current_piece, from, to)
    self[to].is_a?(Pawn) && (to[0] % 7 == 0) ? true : false
  end

  def process_en_passant (piece, from, to)
    if piece.is_a?(Pawn) && ((to[0] - from[0]).abs == 2)
      allow_en_passant(piece, from, to)
    elsif self[to].is_a?(Pawn) && @en_passant[Game.other_color(piece.color)] == to
      self[@en_passant[:target].position] = nil
    end
  end

  def allow_en_passant (piece, from, to)
    en_passant_pos = [(to[0] + from[0]) / 2, to[1]]
    @en_passant[piece.color] = en_passant_pos
    @en_passant[:target] = self[to]
  end

  def display
    letters = "  " + %w( a b c d e f g h).join(" ")
    display_string = letters + "\n"
    8.times do |i|
      display_string += "#{8 - i} "
      8.times do |j|
        square = self[[i,j]]
        background = (i + j).even? ? :yellow : :blue
        display_string += ((square ? square.symbol.colorize(square.color) : " ") + " ").colorize(background: background)
      end
      display_string += " #{8 - i}\n"
    end
    display_string += letters
    display_string
  end

  def reset_en_passant(color)
    @en_passant[color] = nil
  end

  def promote_pawn(sym, position)
    self[position] = create_piece(color(position), self, position, sym)
  end

  private

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
      row = (color == :black) ? 0 : 7
      pieces = [:rook, :knight, :bishop, :queen, :king, :bishop, :knight, :rook]
      pieces.each_with_index do |piece, index|
        position = [row, index]
        self[position] = create_piece(color, self, position, piece)
      end
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

    def create_piece(color, board, position, sym)
      case sym
      when :rook
        Rook
      when :knight
        Knight
      when :bishop
        Bishop
      when :queen
        Queen
      when :king
        King
      end.new(color, self, position)
    end

    def threatened?(position, color)
      opponent_pieces = find_all_pieces(Game.other_color(color))
      opponent_pieces.each do |piece|
        return true if piece.is_a?(Pawn) && piece.attack_spaces.include?(position)
        return true if !piece.is_a?(Pawn) && piece.moves.include?(position)
      end
      false
    end

    def find_all_pieces(color)
      @grid.select { |piece| piece && piece.color == color }
    end
end
