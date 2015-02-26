class InputError < ArgumentError
  def message
    "Please enter your move in this format: a1 a2 (rows a-h, columns 1-8)"
  end
end

class PieceNotOwnedError < StandardError
  def message
    "You do not own a piece at that square."
  end
end

class CheckError <StandardError
  def message
    "That move would leave your king in check."
  end
end

class PromotePawnError < StandardError
  def message
    "You can only promote to a bishop, knight, queen, or rook."
  end
end

class IllegalMoveError < StandardError
  def message
    "That move is not legal."
  end
end
