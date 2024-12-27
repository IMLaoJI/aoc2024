import aoc/util/array2d.{type Posn, Posn}
import aoc/util/fun
import aoc/util/to
import gleam/bool
import gleam/deque
import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/set
import gleam/string

fn parse(input: String) {
  input
  |> string.split("\r\n")
  |> list.map(string.split(_, "x"))
  |> list.map(fn(n) { list.map(n, to.int) })
}

pub fn part1(input: String) -> Int {
  let config =
    input
    |> parse

  use acc, i <- list.fold(config, 0)
  let pairs =
    list.combination_pairs(i)
    |> list.map(fn(t) { t.0 * t.1 })
    |> list.sort(int.compare)
  acc
  + list.fold(pairs, 0, fn(acc2, i) { acc2 + 2 * i })
  + to.unwrap(list.first(pairs))
}

pub fn part2(input: String) -> Int {
  let config =
    input
    |> parse
  use acc, i <- list.fold(config, 0)
  acc
  + {
    list.sort(i, int.compare)
    |> list.take(2)
    |> list.flat_map(list.repeat(_, 2))
    |> list.fold(0, int.add)
  }
  + int.product(i)
}
