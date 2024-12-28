import gleam/dict
import gleam/function
import gleam/list
import gleam/result
import gleam/string

fn parse(input: String) {
  input
  |> string.to_graphemes
  |> list.group(function.identity)
  |> dict.map_values(fn(key, value) {
    case key {
      "(" -> list.length(value) * 1
      ")" -> list.length(value) * -1
      _ -> panic
    }
  })
}

fn get_current_floor(input) {
  let parse_dict =
    input
    |> parse
  result.unwrap(dict.get(parse_dict, "("), 0)
  + result.unwrap(dict.get(parse_dict, ")"), 0)
}

pub fn part1(input: String) -> Int {
  get_current_floor(input)
}

pub fn part2(input: String) -> Int {
  let len = string.length(input)
  list.range(1, len)
  |> list.find(fn(i) {
    string.drop_end(input, len - i)
    |> get_current_floor
    == -1
  })
  |> result.unwrap(0)
}
