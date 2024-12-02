import aoc/util/re
import aoc/util/str
import gleam/int
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

fn total_distance(list_t: #(List(Int), List(Int))) -> Int {
  let #(left, right) = list_t
  list.map2(
    list.sort(left, int.compare),
    list.sort(right, int.compare),
    fn(a, b) { int.absolute_value(a - b) },
  )
  |> int.sum
}

pub fn part1(input: String) -> Int {
  input
  |> str.lines
  |> list.map(parse_line)
  |> list.unzip
  |> total_distance
}

pub fn part2(input: String) -> Int {
  let #(left, right) =
    input
    |> str.lines
    |> list.map(parse_line)
    |> list.unzip

  left
  |> list.fold(0, fn(acc, n) {
    acc + n * { right |> list.count(fn(x) { x == n }) }
  })
}
