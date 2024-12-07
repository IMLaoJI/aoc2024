import aoc/util/str
import gleam/list

fn parse_line(line: String) {
  line
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
