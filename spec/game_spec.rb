require 'spec_helper'
require 'game'
require 'board'
require 'pieces'

describe Game do
  subject(:g) { Game.new }

  # describe '#validate_fifty_move_rule' do
  #
  #   it "correctly evaluates stalemate on the fifty move rule" do
  #     moves = Game.make_moves_from_file_then_quit('games/fifty_moves.txt')
  #     fifty_move = /You may now request a stalemate thanks to the fifty move rule/
  #     expect do
  #       g.play_chess(moves)
  #     end.to output(fifty_move).to_stdout
  #
  #   end
  # end

end
