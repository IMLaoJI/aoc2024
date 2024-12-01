import aoc/util/li
import aoc/util/re
import aoc/util/str
import gleam/int
import gleam/io
import gleam/list
import gleam/regexp
import gleam/result
import gleam/string

fn parse_line(line: String) -> #(Int, Int) {
  let parts =
    regexp.split(with: re.from_string("\\s+"), content: string.trim_end(line))
  case parts {
    [left, right] -> #(
      result.unwrap(int.parse(left), 0),
      result.unwrap(int.parse(right), 0),
    )
    _ -> panic as "error"
  }
}

fn total_distance(tule: #(List(Int), List(Int))) -> Int {
  let sorted_left = list.sort(tule.0, int.compare)
  let sorted_right = list.sort(tule.1, int.compare)
  let distances =
    list.map2(sorted_left, sorted_right, fn(a, b) { int.absolute_value(a - b) })
  int.sum(distances)
}

fn count_occurrences(element: Int, list: List(Int)) -> Int {
  list.length(list.filter(list, fn(a) { a == element }))
}

fn get_frequencies(left: List(Int), right: List(Int)) -> List(Int) {
  list.map(left, fn(element) { count_occurrences(element, right) })
}

pub fn part1(input: String) -> Int {
  input
  |> str.lines
  |> list.map(parse_line)
  |> list.unzip
  |> total_distance
}

pub fn part2(input: String) -> Int {
  let tuple =
    input
    |> str.lines
    |> list.map(parse_line)
    |> list.unzip
  get_frequencies(tuple.0, tuple.1)
  |> list.zip(tuple.0, _)
  |> list.map(fn(t) { t.0 * t.1 })
  |> li.sum
}
