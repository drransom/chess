Command Line Chess
==================
A command line chess game written in pure Ruby. The game supports two human players,
or a human player against a (not very bright) AI. The game implements the full rule
set including the [50-move rule][50-move], [three-repeat rule][three-repeat], and all edge cases associated with the definition of "repeat".

To play, download the repo and:

````
    > bundle install
    > ruby lib/game.rb
````
[50-move]: https://en.wikipedia.org/wiki/Fifty-move_rule
[three-repeat]: https://en.wikipedia.org/wiki/Threefold_repetition

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

The Players
==============
The `HumanPlayer` and `ComputerPlayer` classes handle the logic for requesting
moves from the player and sending that information back to the `Game`. The `Game`
object interacts with the `HumanPlayer` and `ComputerPlayer` objects exclusively
by calling `#play_turn`, which returns the player's move (or attempted move). The
IO logic is handled by the two player classes, as is the AI.

The AI
-----------
`ComputerPlayer#get_best_move` follows a greedy algorithm, selecting options
based on the following priority ranking:
* Checkmate opponent
* Promote pawn
* Capture highest-value piece
* Any non-capture move that does not cause stalemate
* Any move that causes stalemate

If there is more than one "best" move, the AI chooses randomly.
