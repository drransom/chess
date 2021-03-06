require 'spec_helper'
require 'board'
require 'game'
require 'pieces'
require 'player'

context "chess history integration" do
  let(:white_player) { double("white player", color: :white, play_turn: 'e2 e4',
    request_three_repeat_draw: 'n') }
  let(:black_player) { double("black player", color: :black, play_turn: 'e7 e5',
    request_three_repeat_draw: 'n') }
  let(:game) { Game.new({ white: white_player, black: black_player }) }
  let(:history) { game.instance_variable_get(:@history) }

  def play_test_game(moves)
    (moves.length).times do |i|
      game.send(:play_one_turn)
      game.send(:flip_current_player)
    end
  end

  it "does not have three repeats when the game has not been repeated three times" do
    game.send(:initialize_game, [])
    expect(history.three_repeats?).to be_falsy
  end

  it "does have three repeats when the game has been repeated three times" do
    moves = ['g1 h3', 'g8 h6', 'h3 g1', 'h6 g8', 'g1 h3', 'g8 h6', 'h3 g1', 'h6 g8']
    game.send(:initialize_game, moves )
    expect(white_player).not_to receive(:request_three_repeat_draw)
    expect(black_player).to receive(:request_three_repeat_draw).once
    play_test_game(moves)
  end

  it "different position" do
    moves = File.readlines('spec/moves/open_rooks.txt').map(&:chomp)
    game.send(:initialize_game, moves)
    expect(white_player).not_to receive(:request_three_repeat_draw)
    expect(black_player).to receive(:request_three_repeat_draw).once
    play_test_game(moves)
  end

  it "rooks that have moved differently are not the same" do
    moves = File.readlines('spec/moves/one_moving_rook.txt').map(&:chomp)
    game.send(:initialize_game, moves)
    expect(white_player).not_to receive(:request_three_repeat_draw)
    expect(black_player).not_to receive(:request_three_repeat_draw)
    play_test_game(moves)
  end

  it "rooks that have moved differently are the same after a fourth iteration" do
    moves = File.readlines('spec/moves/one_moving_rook_four_repeats.txt').map(&:chomp)
    game.send(:initialize_game, moves)
    expect(white_player).to receive(:request_three_repeat_draw).once.and_return('n')
    play_test_game(moves)
  end

  it "three iterations are not a repeat if en passant was available the first time" do
    moves = File.readlines('spec/moves/en_passant_three_repeats.txt').map(&:chomp)
    game.send(:initialize_game, moves)
    expect(white_player).not_to receive(:request_three_repeat_draw)
    expect(black_player).not_to receive(:request_three_repeat_draw)
    play_test_game(moves)
  end

  it "four iterations are a repeat if en passant was available the first time" do
    moves = File.readlines('spec/moves/en_passant_four_repeats.txt').map(&:chomp)
    game.send(:initialize_game, moves)
    expect(white_player).to receive(:request_three_repeat_draw).once.and_return('n')
    play_test_game(moves)
  end

  it "three iterations are not a repeat if the king moves" do
    moves = File.readlines('spec/moves/king_move_three_repeats.txt').map(&:chomp)
    game.send(:initialize_game, moves)
    expect(white_player).not_to receive(:request_three_repeat_draw)
    expect(black_player).not_to receive(:request_three_repeat_draw)
    play_test_game(moves)
  end

  it "four iterations are a repeat if the king moved the first time" do
    moves = File.readlines('spec/moves/king_move_four_repeats.txt').map(&:chomp)
    game.send(:initialize_game, moves)
    expect(black_player).to receive(:request_three_repeat_draw).once
    expect(white_player).not_to receive(:request_three_repeat_draw)
    play_test_game(moves)
  end

  it "repeat requires the same player to move" do
    moves = File.readlines('spec/moves/three_repeats_different_player_moving.txt').map(&:chomp)
    game.send(:initialize_game, moves)
    expect(white_player).not_to receive(:request_three_repeat_draw)
    expect(black_player).not_to receive(:request_three_repeat_draw)
    play_test_game(moves)

  end
end
