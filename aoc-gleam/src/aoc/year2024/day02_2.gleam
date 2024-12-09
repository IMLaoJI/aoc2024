import gleam/int
import gleam/list
import gleam/string

pub fn parse(input) {
  use line <- list.filter_map(string.split(input, on: "\r\n"))
  let levels = line |> string.split(" ") |> list.filter_map(int.parse)

  case levels {
    [] -> Error(Nil)
    _ -> Ok(levels)
  }
}

fn check(windowed, to_delta) {
  use #(first, second) <- list.all(windowed)
  let delta = to_delta(first, second)
  delta >= 1 && delta <= 3
}

fn is_safe(report) {
  case list.window_by_2(report) {
    [#(first, second), ..] as windowed if first < second ->
      check(windowed, fn(first, second) { second - first })
    [#(first, second), ..] as windowed if second < first ->
      check(windowed, fn(first, second) { first - second })
    _ -> False
  }
}

pub fn part1(input: String) -> Int {
  input
  |> parse
  |> list.count(is_safe)
}

pub fn part2(input: String) -> Int {
  use report <- list.count(parse(input))
  use dampen <- list.any(list.combinations(report, list.length(report) - 1))
  is_safe(dampen)
}
