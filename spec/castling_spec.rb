require 'spec_helper'
require 'board'
require 'game'
require 'pieces'

context 'Castling' do
  let(:board) { Board.new(false) }
  let(:game) { Game.new(board: board) }
  def set_current_player(color)
    player = game.instance_variable_get("@#{color}_player")
    game.instance_variable_set(:@current_player, player)
  end

  def move_piece (move_string)
    Game.instance_method(:try_move_piece).bind(game).call(move_string)
  end

  { black: 0, white: 7 }.each do |color, row|
    current_color = color
    other_color = (color === :white) ? :black : :white
    king_space = [row, 4]

    right_castle = "e#{8- row} g#{8 - row}"
    right_rook_space = [row, 7]
    right_castle_king_target = [row, 6]
    right_castle_rook_target = [row, 5]

    left_castle = "e#{8 - row} b#{8 - row}"
    left_rook_space = [row, 0]
    left_castle_king_target = [row, 1]
    left_castle_rook_target = [row, 2]

    king_slides = ["e#{8-row} f#{8 - row}", "e#{row + 1} f#{row + 1}",
                   "f#{8-row} e#{8 - row}", "f#{row + 1}, e#{row + 1}"]

    rook_space = Proc.new do |col|
      [7 - row, col]
    end

    before(:each) do
      { black: 0, white: 7 }.each do |color, row|
        board[[row, 0]] = Rook.new(color, board, [row, 0])
        board[[row, 7]] = Rook.new(color, board, [row, 7])
        board[[row, 4]] = King.new(color, board, [row, 4])
      end
    end

    it "#{color} can castle right" do
      set_current_player(color)
      move_piece(right_castle)
      expect(board[right_castle_king_target]).to be_a(King)
      expect(board[right_castle_rook_target]).to be_a(Rook)
      expect(board.empty?(king_space)).to be_truthy
      expect(board.empty?(right_rook_space)).to be_truthy
    end

    it "#{color} can castle left" do
      set_current_player(color)
      move_piece(left_castle)
      expect(board[left_castle_king_target]).to be_a(King)
      expect(board[left_castle_rook_target]).to be_a(Rook)
      expect(board.empty?(king_space)).to be_truthy
      expect(board.empty?(left_rook_space)).to be_truthy
    end

    it "#{color} cannot castle right two spaces" do
      set_current_player(color)
      expect { move_piece("e#{8 - row} c#{8 - row}") }.to raise_error(IllegalMoveError)
      expect(board[king_space]).to be_a(King)
      expect(board[left_rook_space]).to be_a(Rook)
    end

    it "#{color} cannot castle after moving" do
      set_current_player(color)
      move_piece(king_slides[0])
      set_current_player(other_color)
      move_piece(king_slides[1])
      set_current_player(color)
      move_piece(king_slides[2])
      set_current_player(other_color)
      move_piece(king_slides[3])
      set_current_player(color)
      expect { move_piece(left_castle)}.to raise_error(IllegalMoveError)
    end

    it "#{color} cannot castle into check" do
      new_rook_space = rook_space.call(1)
      set_current_player(color)
      board[new_rook_space] = Rook.new(other_color, board, new_rook_space)
      expect { move_piece(left_castle) }.to raise_error(IllegalMoveError)
    end

    it "#{color} cannot castle through check" do
      new_rook_space = rook_space.call(2)
      board[new_rook_space] = Rook.new(other_color, board, new_rook_space)
      set_current_player(color)
      expect { move_piece(left_castle) }.to raise_error(IllegalMoveError)
    end

    it "#{color} cannot castle out of check" do
      new_rook_space = rook_space.call(4)
      board[new_rook_space] = Rook.new(other_color, board, new_rook_space)
      set_current_player(color)
      expect { move_piece(left_castle) }.to raise_error(IllegalMoveError)
    end
  end

end
