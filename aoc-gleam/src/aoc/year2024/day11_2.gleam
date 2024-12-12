import aoc/util/array2d.{type Posn}

import aoc/util/to
import gleam/dict.{type Dict}

import gleam/list

import pocket_watch

fn parse_line(line: String) {
  line
}

fn parse(input) {
  to.ints(input, " ")
}

fn count_blinks() {
  todo
}

pub fn part1(input: String) -> Int {
  use <- pocket_watch.simple("part 1")
  input
  |> parse
  |> list.fold(0, fn(acc, n) { 1 })
}

pub fn part2(input: String) -> Int {
  input
  |> parse
  1
}
