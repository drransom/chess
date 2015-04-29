Command Line Chess
==================
A command line chess game written in pure Ruby. Currently supports only two human
players. To play, download the repo and:
    bundle install
    ruby lib/game.rb

About the Code
===============
The Board
-------------
The board is implemented with a `Board` class. The centerpiece of this class is the `@grid` variable, an array which contains either `Piece` instances or `nil`. To keep the data structures and access simple, `@grid` is implemented as a 1 x 64 array that overwrites the
`Array#[]` and `Array#[]=` methods. Elements in the grid can be accessed with the notation `@grid[x, y]` and assigned with the notation `@grid[x, y] =`
Pieces
---------------
All six chess pieces inherit from a single `Piece` class, which no logic other than initialization. Most movement logic is delegated to `Slideable` and `Stepable` modules. `King` and `Knight` include `Stepable`, while `Queen`, `Bishop`, and `Rook` include `Slideable`. The `Pawn` class has its own movement logic due to the complexity of first moves, attacks, promotion, and en passant.
