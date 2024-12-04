import aoc/util/re
import aoc/util/str
import gleam/int
import gleam/list
import gleam/regexp
import gleam/result
import gleam/string

fn parse_line(line: String) {
  todo
}

pub fn part1(input: String) -> Int {
  input
  |> str.lines
  |> list.map(parse_line)

  1
}

pub fn part2(input: String) -> Int {
  input
  |> str.lines
  |> list.map(parse_line)
  1
}
