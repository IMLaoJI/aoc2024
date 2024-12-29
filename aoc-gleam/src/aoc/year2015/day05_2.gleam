import gleam/list
import gleam/string

import gleam/set.{type Set}

pub fn good(string: String) -> Bool {
  let letters = string.to_graphemes(string)
  is_sandwich(letters) && has_repeated_pair(letters)
}

fn is_sandwich(line: List(a)) -> Bool {
  case line {
    [c1, _, c2, ..] if c1 == c2 -> True
    [_, ..rest] -> is_sandwich(rest)
    [] -> False
  }
}

fn has_repeated_pair(line: List(String)) {
  has_repeated_pair_loop(line, set.new())
}

fn has_repeated_pair_loop(
  line: List(String),
  pairs: Set(#(String, String)),
) -> Bool {
  case line {
    [] | [_] | [_, _] -> False
    [c1, c2, c3, ..rest] ->
      case set.contains(pairs, #(c2, c3)) {
        True -> True
        False -> {
          let pairs = set.insert(pairs, #(c1, c2))
          has_repeated_pair_loop([c2, c3, ..rest], pairs)
        }
      }
  }
}

pub fn part1(input: String) -> Int {
  1
}

pub fn part2(input: String) -> Int {
  input
  |> string.split("\r\n")
  |> list.filter(good)
  |> list.length
}
