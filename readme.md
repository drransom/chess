Command Line Chess
==================
A command line chess game written in pure Ruby. The game supports two human players.
The game implements the full rule set including castling, en passant, and 50-move
rules, but not the 3-repeat rule.
To play, download the repo and:

````
    > bundle install
    > ruby lib/game.rb
````

About the Code
===============
The Board
-------------
The board is implemented with a `Board` class. The centerpiece of this class is the `@grid` variable, an array which contains either `Piece` instances or `nil`. To keep the data structures and access simple, `@grid` is implemented as a 1 x 64 array, and the `Board` class is given its own accessor methods, allowing positions to be represented as 2-arrays, while positions can be accessed as `board[position]`.

```ruby
def set_position(position)
  row, col = position
  raise 'invalid position' if out_of_bounds?(position)
end

def [](position)
  row, col = set_position(position)
  @grid[(row * 8) + col]
end

def []=(position, new_value)
  row, col = set_position(position)
  @grid[(row * 8) + col] = new_value
end
```
Pieces
---------------
All six chess pieces inherit from a single `Piece` class, which holds no logic other than initialization. Most movement logic is delegated to `Slideable` and `Stepable` modules. `King` and `Knight` include `Stepable`, while `Queen`, `Bishop`, and `Rook` include `Slideable`. The `Pawn` class has its own movement logic due to the complexity of first moves, attacks, promotion, and en passant.
