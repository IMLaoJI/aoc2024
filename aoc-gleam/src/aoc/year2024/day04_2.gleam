import aoc/util/grid.{type Grid, type Point, type Word, Point, directions}
import aoc/util/re
import aoc/util/str
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/regexp
import gleam/result
import gleam/string

fn parse(input: String) -> Grid(String) {
  use graph, line, x <- list.index_fold(string.split(input, "\n"), dict.new())
  use graph, item, y <- list.index_fold(string.to_graphemes(line), graph)
  dict.insert(graph, Point(x, y), item)
}

pub fn part1(input: String) -> Int {
  let grid = input |> parse
  use count, point, _ <- dict.fold(grid, 0)
  count + count_words(grid, point, "XMAS")
}

/// Given a position in a grid, will count all valid words in all directions.
fn count_words(
  in grid: Grid(String),
  at position: Point,
  for word: String,
) -> Int {
  let words = word_lookups(word, position)

  use count, points <- list.fold(words, 0)
  case get_word(grid, points) {
    Ok(res) if res == word -> count + 1
    Ok(_) | Error(_) -> count
  }
}

/// Builds the word from the values in the Grid using our list of Points
/// 
/// We use results, because we might be "indexing" outside of the grid,
/// as our fn word_lookups generates point lists optimistically.
/// This function is what tells us if they're valid or not.
fn get_word(in grid: Grid(String), at points: Word) {
  use result, point <- list.try_fold(points, "")
  use letter <- result.try(dict.get(grid, point))
  Ok(result <> letter)
}

/// Given a word and a starting position, generates a
/// list of words represented by a coordinate list.
/// 
/// This allows us to easily check the letters of the word
fn word_lookups(str: String, pos: Point) -> List(Word) {
  let chars = string.to_graphemes(str)
  use Point(x, y) <- list.map(directions)
  use _char, index <- list.index_map(chars)
  Point(pos.x + x * index, pos.y + y * index)
}

fn count_mas_words(grid: Grid(String), pos: Point) -> Int {
  let Point(x, y) = pos
  let slash = [Point(x - 1, y - 1), Point(x, y), Point(x + 1, y + 1)]
  let back_slash = [Point(x - 1, y + 1), Point(x, y), Point(x + 1, y - 1)]
  case get_word(grid, slash), get_word(grid, back_slash) {
    Ok("MAS"), Ok("MAS")
    | Ok("SAM"), Ok("SAM")
    | Ok("SAM"), Ok("MAS")
    | Ok("MAS"), Ok("SAM")
    -> 1
    _, _ -> 0
  }
}

pub fn part2(input: String) -> Int {
  let grid = input |> parse
  use count, point, _ <- dict.fold(grid, 0)
  count + count_mas_words(grid, point)
}
