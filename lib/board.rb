require_relative 'pieces'
require_relative 'game'
require 'colorize'
require 'byebug'

class Board
  include ChessHelper
  attr_accessor :grid, :en_passant

  def initialize(fill_board = true)
    @grid = Array.new(64)
    @en_passant = { white: nil, black: nil, target: nil }
    build_grid if fill_board
  end

  def validate_position(position)
    raise 'invalid position' if out_of_bounds?(position)
    position
  end

  def [](position)
    row, col = validate_position(position)
    @grid[(row * 8) + col]
  end

  def []=(position, new_value)
    row, col = validate_position(position)
    @grid[(row * 8) + col] = new_value
  end

  def stalemate?(color)
    !in_check?(color) && !has_legal_move?(color)
  end

  def checkmate?(color)
    in_check?(color) && !has_legal_move?(color)
  end

  def in_check?(color)
    king = find_king(color)
    king ? threatened?(king.position, king.color) : false
  end

  def find_king(color)
    @grid.find { |piece| piece.is_a?(King) && piece.color == color }
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
    clone_board.en_passant = @en_passant.clone
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

  # return: outcome of move, symbol
  def move_piece(from, to, ignore_castle = false)
    if !ignore_castle && castle?(self[from], to)
      process_castle(from, to)
    else
      old_piece = self[to]
      self[to] = self[from]
      current_piece = self[to]
      self[from] = nil
      current_piece.position = to
      process_en_passant(current_piece, from, to)
      current_piece.update_has_moved
      if self[to].is_a?(Pawn) && (to[0] % 7 == 0)
        :pawn_promotion
      elsif old_piece
        :capture
      elsif self[to].is_a?(Pawn)
        :pawn_move
      else
        false
      end
    end
  end

  def process_en_passant (piece, from, to)
    other_color = Game.other_color(piece.color)
    if piece.is_a?(Pawn) && ((to[0] - from[0]).abs == 2)
      allow_en_passant(piece, from, to)
    elsif self[to].is_a?(Pawn) && @en_passant[other_color] == to
      self[@en_passant[:target].position] = nil
    else
      reset_en_passant
    end
  end

  def allow_en_passant (piece, from, to)
    en_passant_pos = [(to[0] + from[0]) / 2, to[1]]
    @en_passant[piece.color] = en_passant_pos
    @en_passant[:target] = self[to]
  end

  def display
    letters = "  " + ('a'..'h').to_a.join(" ")
    display_string = letters + "\n"
    8.times do |i|
      display_string += "#{8 - i} "
      8.times do |j|
        square = self[[i,j]]
        background = (i + j).even? ? :light_white : :light_black
        display_string += ((square ? square.symbol.colorize(square.color) : " ") + " ").colorize(background: background)
      end
      display_string += " #{8 - i}\n"
    end
    display_string += letters
    display_string
  end

  def reset_en_passant
    @en_passant.keys.each { |key| @en_passant[key] = nil }
  end

  def promote_pawn(sym, position)
    self[position] = create_piece(color(position), self, position, sym)
  end

  def valid_rook?(position, color)
    piece = self[position]
    if (piece.is_a?(Rook) && !piece.has_moved? && piece.color == color)
      piece
    else
      nil
    end
  end

  def all_valid?(piece, test_positions)
    test_positions.each do |test_position|
      test_position = add_arrays(piece.position, test_position)
      if occupied?(test_position) || threatened?(test_position, piece.color)
        return false
      end
    end
    true
  end

  def process_castle(from, to)
    if to[1] > from[1]
      move_piece(add_arrays(to, [0, 1]), add_arrays(from, [0, 1]))
    else
      move_piece(add_arrays(to, [0, -1]), add_arrays(from, [0, -2]))
    end
    move_piece(from, to, true)
  end

  def ==(other_board)
      can_castle_colors = [:white, :black].select { |color| can_castle?(color) }
      other_can_castle_colors = [:white, :black].select { |color| other_board.can_castle?(color) }
      return false unless can_castle_colors == other_can_castle_colors
      equivalent = Proc.new do | piece1, piece2 |
        if !piece1 && !piece2
          true
        elsif piece1
          piece1.equivalent?(piece2, can_castle_colors)
        else
          false
        end
      end
    all_equivalent = (0...8).all? do |row|
      (0...8).all? do |col|
        equivalent.call(self[[row, col]], other_board[[row, col]])
      end
    end

    en_passant_proc = Proc.new do |color|
      if en_passant_available?(color) || other_board.en_passant_available?(color)
        @en_passant[color] == other_board.en_passant[color] &&
        @en_passant[:target] == other_board.en_passant[:target]
      else
        true
      end
    end
    all_equivalent && en_passant_proc.call(:white) && en_passant_proc.call(:black)
  end

  def eql?(other_board)
    self == other_board
  end

  def hash
    can_castle_colors = [:white, :black].select { |color| can_castle?(color) }
    hash_proc = Proc.new do |piece|
      if !piece || can_castle_colors.include?(piece.color)
        piece.hash
      else
        Piece.instance_method(:hash).bind(piece).call
      end
    end
    if en_passant_available?(:white) || en_passant_available?(:black)
      en_passant_element = @en_passant
    else
      en_passant_element = {}
    end
    [ @grid.map { |piece| hash_proc.call(piece) },
      en_passant_element
    ].hash
  end

  #returns if a player has enough unmoved pieces to castle
  def can_castle?(color)
    rooks = @grid.select { |piece| piece.class == Rook && piece.color == color }
    !find_king(color).has_moved? && rooks.any? { |rook| !rook.has_moved? }
  end

  def en_passant_available?(color) #color is color of player who can capture
    other_color = (color == :black) ? :white : :black
    return false unless @en_passant[other_color]
    pawns = @grid.select { |piece| piece.is_a?(Pawn) && piece.color == color }
    pawns.any? do |pawn|
      pawn.attack_spaces.include?(@en_passant[other_color])
    end
  end

  def en_passant_equivalent?(other)
    if [:white, :black].any? do |color|
        [self, other].any? do |board|
          board.en_passant_available?(color)
        end
      end
      @en_passant == other.en_passant
    else
      true
    end
  end

  private

  def build_grid
    build_pawns
    build_back_row(:black)
    build_back_row(:white)
  end

  def threatened?(position, color)
    opponent_pieces = find_all_pieces(Game.other_color(color))
    opponent_pieces.each do |piece|
      return true if piece.attack_spaces.include?(position)
    end
    false
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

  def find_all_pieces(color)
    @grid.select { |piece| piece && piece.color == color }
  end

  def castle?(piece, to)
    piece.is_a?(King) && ((to[1] - piece.position[1]).abs > 1)
  end


end
