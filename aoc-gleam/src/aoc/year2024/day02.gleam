import aoc/util/str
import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/string

/// Checks if a list of levels is safe  
fn is_safe(levels: List(Int)) -> Bool {
  let increments = list.zip(levels, list.drop(levels, 1))
  let diffs = list.map(increments, fn(t) { t.0 - t.1 })
  let all_increasing = list.all(diffs, fn(diff) { diff >= -3 && diff <= -1 })
  let all_decreasing = list.all(diffs, fn(diff) { diff >= 1 && diff <= 3 })
  all_increasing || all_decreasing
}

fn is_safe_with_dampener(levels: List(Int)) -> Bool {
  case is_safe(levels) {
    True -> True
    False ->
      list.index_map(levels, fn(_x, i) { i })
      |> list.any(fn(i) {
        list.index_fold(levels, [], fn(acc, t, index) {
          case i != index {
            True -> list.append(acc, [t])
            False -> acc
          }
        })
        |> is_safe
      })
  }
}

fn parse_line(input) -> List(List(Int)) {
  input
  |> str.lines
  |> list.map(fn(l) {
    string.trim_end(l) |> string.split(" ") |> list.filter_map(int.parse)
  })
}

pub fn part1(input: String) -> Int {
  input
  |> parse_line
  |> list.filter(is_safe)
  |> list.length
}

pub fn part2(input: String) -> Int {
  input
  |> parse_line
  |> list.filter(is_safe_with_dampener)
  |> list.length
}
