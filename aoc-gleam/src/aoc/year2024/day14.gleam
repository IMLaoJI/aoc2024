import aoc/util/re
import aoc/util/to
import gleam/bool
import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp.{type Match, Match}
import gleam/string

type QUADRANT {
  FIRST
  SECOND
  THIRD
  FOUTH
}

fn get_number(str) {
  let regex_str = re.from_string("(-?\\d+),(-?\\d+)")
  list.fold(regexp.scan(regex_str, str), [], fn(sumal, match) {
    let assert Match(submatches: [Some(left), Some(right)], ..) = match
    list.append(sumal, [#(to.int(left), to.int(right))])
  })
}

fn mod(first, second) {
  { { first % second } + second } % second
}

fn get_quadrant(report, move_num, weight, height) {
  let assert [#(x, y), #(xv, yv)] = report
  let end_x = mod(x + move_num * xv, weight)
  let end_y = mod(y + move_num * yv, height)
  let middle_height = height / 2
  let middle_width = weight / 2
  use <- bool.guard(
    end_y == middle_height || end_x == middle_width,
    option.None,
  )

  let top = end_y < middle_height
  let left = end_x < middle_width
  let quad = case top, left {
    True, True -> FIRST
    True, False -> SECOND
    False, True -> THIRD
    False, False -> FOUTH
  }
  Some(#(quad, #(end_x, end_y)))
}

fn parse(input) {
  input |> string.trim |> string.split("\r\n") |> list.map(get_number)
}

pub fn part1(input: String) -> Int {
  input
  |> parse
  |> list.map(get_quadrant(_, 100, 101, 103))
  |> list.filter(option.is_some)
  |> list.group(fn(p) {
    let assert Some(#(quad, _)) = p
    quad
  })
  |> dict.values
  |> list.map(list.length)
  |> int.product
}

fn get_first_unique_reports(robots, acc) {
  let new_robots =
    robots
    |> list.map(get_quadrant(_, acc, 101, 103))
    |> list.filter(option.is_some)
    |> list.map(fn(p) {
      let assert Some(#(_, postion)) = p
      postion
    })
  case list.length(list.unique(new_robots)) == list.length(new_robots) {
    True -> acc
    False -> get_first_unique_reports(robots, acc + 1)
  }
}

pub fn part2(input: String) -> Int {
  input
  |> parse
  |> get_first_unique_reports(1)
}
