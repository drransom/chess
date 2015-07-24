require 'spec_helper'
require 'player'

describe Player do
  subject(:player) { Player.new(:black) }

  it "has a color" do
    expect(player.color).to eq(:black)
  end
end

describe HumanPlayer do
  subject(:player) { HumanPlayer.new(:black) }

  it "has a color" do
    expect(player.color).to eq(:black)
  end

  it "responds to required methods" do
    expect(player).to respond_to(:play_turn)
    expect(player).to respond_to(:confirm_quit)
    expect(player).to respond_to(:request_pawn)
    expect(player).to respond_to(:request_fifty_move_stalemate)
  end

end
