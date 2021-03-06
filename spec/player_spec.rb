require 'spec_helper'
require 'player'
require 'game'
require 'board'

describe Player do
  subject(:player) { Player.new(:black) }

  it 'has a color' do
    expect(player.color).to eq(:black)
  end
end

describe HumanPlayer do
  subject(:player) { HumanPlayer.new(:black) }

  it 'has a color' do
    expect(player.color).to eq(:black)
  end

  it 'responds to required methods' do
    expect(player).to respond_to(:play_turn)
    expect(player).to respond_to(:confirm_quit)
    expect(player).to respond_to(:request_pawn)
    expect(player).to respond_to(:request_fifty_move_draw)
    expect(player).to respond_to(:request_three_repeat_draw)
  end

end

describe ComputerPlayer do
  subject(:player) { ComputerPlayer.new(:white) }

  context 'basics' do


    it 'has a color' do
      expect(player.color).to eq(:white)
    end

    it 'responds to required methods' do
      expect(player).to respond_to(:play_turn)
      expect(player).to respond_to(:confirm_quit)
      expect(player).to respond_to(:request_pawn)
      expect(player).to respond_to(:request_fifty_move_draw)
      expect(player).to respond_to(:request_three_repeat_draw)
      expect(player).to respond_to(:add_new_game)
    end

    it '#request_fifty_move_draw' do
      expect(player.request_fifty_move_draw).to be_truthy
    end

    it '#request_three_repeat_draw' do
      expect(player.request_three_repeat_draw).to be_truthy
    end

    it '#convert_move_to_chess_notation' do
      move = player.send(:convert_move_to_chess_notation, [ [1, 4], [3, 4] ])
      expect(move).to eq('e7 e5')
    end
  end

  context 'move selection' do
    let(:board) { Board.new(false) }
    let(:game) { double("game", board: board, white: player) }

    before(:each) do
      player.add_new_game(game)
      board[[0, 4]] = King.new(:black, board, [0, 4])
      board[[7, 4]] = King.new(:white, board, [7, 4])
    end

    it 'selects a legal move' do
      board[[6, 4]] = Pawn.new(:white, board, [6, 4])
      available_moves = ["e1 d1", "e1 f1", "e1 d2", "e1 f2", "e2 e3", "e2 e4"]
      10.times do
        move = player.play_turn
        expect(available_moves).to include(move)
      end
    end

    it 'checkmates when available' do
      board[[1, 0]] = Rook.new(:white, board, [1, 0])
      board[[5, 1]] = Rook.new(:white, board, [5, 1])
      10.times do
        expect(player.play_turn).to eq('b3 b8')
      end
    end

    it 'captures when available' do
      board[[6, 4]] = Pawn.new(:white, board, [6, 4])
      board[[5, 3]] = Pawn.new(:black, board, [5, 3])
      10.times do
        expect(player.play_turn).to eq('e2 d3')
      end
    end

    it 'prefers checkmate to capture' do
      board[[1, 0]] = Rook.new(:white, board, [1, 0])
      board[[5, 1]] = Rook.new(:white, board, [5, 1])
      board[[5, 4]] = Pawn.new(:white, board, [5, 4])
      board[[4, 3]] = Pawn.new(:black, board, [4, 3])
      10.times do
        expect(player.play_turn).to eq('b3 b8')
      end
    end

    it 'captures a higher-value piece over a lower-value piece' do
      board[[6, 4]] = Pawn.new(:white, board, [6, 4])
      board[[5, 3]] = Pawn.new(:black, board, [5, 3])
      board[[5, 5]] = Bishop.new(:black, board, [5, 5])
      10.times do
        expect(player.play_turn).to eq('e2 f3')
      end
    end
  end

  context 'initial move selection' do

    let(:board) { Board.new(true) }
    let(:game) { double("game", board: board, white: player) }

    before(:each) do
      player.add_new_game(game)
    end

    it 'does not always select the same move' do
      move = player.play_turn
      counter = 0
      1000.times do
        break unless player.play_turn == move
        counter += 1
      end
      expect(counter).not_to eq(1000)
    end

    it 'does not try to move an illegal piece' do
      legal_pieces = ('a'..'h').map { |char| "#{char}2"} + ['b1', 'g1']
      10.times do |i|
        piece = player.play_turn.split(' ')[0]
        expect(legal_pieces).to include(piece)
      end
    end
  end

end
