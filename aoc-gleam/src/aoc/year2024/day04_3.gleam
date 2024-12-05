import aoc/util/constant.{get_directions}
import aoc/util/re
import aoc/util/str
import gleam/bool
import gleam/dict
import gleam/int
import gleam/list
import gleam/regexp
import gleam/result
import gleam/string

fn parse(line: String) {
  use dict, line, row <- list.index_fold(str.lines(line), dict.new())
  use dict, char, col <- list.index_fold(string.to_graphemes(line), dict)
  case char {
    "X" | "M" | "A" | "S" -> dict.insert(dict, #(row, col), char)
    _ -> dict
  }
}

pub fn part1(input: String) -> Int {
  let input_dict = parse(input)
  use count, #(row, col), char <- dict.fold(input_dict, 0)
  use <- bool.guard(char != "X", count)
  use count, #(dx, dy) <- list.fold(get_directions(), count)
  case
    dict.get(input_dict, #(row + dx * 1, col + dy * 1)),
    dict.get(input_dict, #(row + dx * 2, col + dy * 2)),
    dict.get(input_dict, #(row + dx * 3, col + dy * 3))
  {
    Ok("M"), Ok("A"), Ok("S") -> count + 1
    _, _, _ -> count
  }
}

pub fn part2(input: String) -> Int {
  let input_dict = parse(input)
  use count, #(row, col), char <- dict.fold(input_dict, 0)
  use <- bool.guard(char != "A", count)
  case
    dict.get(input_dict, #(row + 1, col + 1)),
    dict.get(input_dict, #(row - 1, col - 1)),
    dict.get(input_dict, #(row + 1, col - 1)),
    dict.get(input_dict, #(row - 1, col + 1))
  {
    Ok("M"), Ok("S"), Ok("M"), Ok("S")
    | Ok("M"), Ok("S"), Ok("S"), Ok("M")
    | Ok("S"), Ok("M"), Ok("M"), Ok("S")
    | Ok("S"), Ok("M"), Ok("S"), Ok("M")
    -> count + 1
    _, _, _, _ -> count
  }
}
