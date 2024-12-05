import gleam/dict.{type Dict}

pub type Point {
  Point(x: Int, y: Int)
}

pub const directions = [
  // Up
  Point(1, 0),
  // Down
  Point(-1, 0),
  // Right
  Point(0, 1),
  // Left
  Point(0, -1),
  // Up-Right
  Point(1, 1),
  // Up-left
  Point(1, -1),
  // Down-Right
  Point(-1, 1),
  // Down-left
  Point(-1, -1),
]

/// Using a Dictionary as a lookup table for data.
/// This is much better in FP, since indexing into arrays is a big anti-pattern in gleam.
/// 
/// Functionally, its not different than a 2d array.
pub type Grid(data) =
  Dict(Point, data)

/// A word is a list of points, which can be used to look up the letter
pub type Word =
  List(Point)
