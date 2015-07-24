require 'spec_helper'
require 'game'
require 'board'
require 'pieces'
require 'chess_history'

class MockBoard
  attr_reader :value
  def initialize(value = 0)
    @value = value
  end

  def ==(other)
    value == other.value
  end

  def clone
    self
  end
end

describe ChessHistory do
  subject(:history) { ChessHistory.new }

  describe '#add_to_history' do
    it 'can update the history' do
      expect(history).to respond_to(:update_history)
    end
  end

  describe '#three_repeats?' do
    it 'can add repeats' do
      expect(history).to respond_to(:three_repeats?)
    end

    it 'says there are not three repeats when initialized' do
      expect(history.three_repeats?).to be_falsy
    end


    it 'recognizes three repeats when updated with items that are ==' do
      test_history = ChessHistory.new
      5.times do
        test_history.update_history(MockBoard.new)
      end
      expect(test_history.three_repeats?).to be_truthy
    end

    it 'does not recognize three repeats when there are not three == items' do
      test_history = ChessHistory.new
      2.times do
        test_history.update_history(MockBoard.new)
        test_history.update_history(MockBoard.new(1))
      end
      expect(test_history.three_repeats?).to be_falsy
    end

    it 'recognizes three repeats regardless of order added' do
      boards = [ MockBoard.new, MockBoard.new(11) ]
      11.times { |i| boards.push(MockBoard.new(i)) }
      history = ChessHistory.new
      boards.each { |board| history.update_history(board) }
      expect(history.three_repeats?).to be_falsy
      history.update_history(MockBoard.new(12))
      history.update_history(MockBoard.new)
      expect(history.three_repeats?).to be_truthy
    end

    it 'says there are not three repeats if the repeated position is not the most recent' do
      history = ChessHistory.new
      6.times { history.update_history(MockBoard.new) }
      history.update_history(MockBoard.new(1))
      expect(history.three_repeats?).to be_falsy
    end

    it 'says there are not three repeats if the moving player is not the same' do
      history = ChessHistory.new
      2.times do
        history.update_history(MockBoard.new)
        history.update_history(MockBoard.new(1))
      end
      history.update_history(MockBoard.new(3))
      history.update_history(MockBoard.new(4))
      history.update_history(MockBoard.new(1)) #this is the whote player's move
      expect(history.three_repeats?).to be_falsy
    end
  end
end
