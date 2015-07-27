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
    end

    it '#request_fifty_move_draw' do
      expect(player.request_fifty_move_draw).to be_truthy
    end

    it '#request_three_repeat_draw' do
      expect(player.request_three_repeat_draw).to be_truthy
    end

  context 'select moves' do
    describe 'outcome' do
    end
  end

end
