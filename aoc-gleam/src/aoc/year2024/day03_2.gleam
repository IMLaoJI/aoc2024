import aoc/util/fun
import aoc/util/re
import aoc/util/str
import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/pair
import gleam/regex.{type Match, Match}
import gleam/result
import gleam/string

pub fn try_parse_mul(expr: String) -> Result(#(Int, Int), Nil) {
  let parsed = expr |> string.split(",")
  use <- bool.guard(list.length(parsed) != 2, return: Error(Nil))
  use left <- result.try(int.parse(list.first(parsed) |> result.unwrap("0")))
  use right <- result.try(int.parse(list.last(parsed) |> result.unwrap("0")))
  Ok(#(left, right))
}

pub type ComputerState {
  Do
  Dont
}

pub fn parse_part(
  input: String,
  accum: List(#(Int, Int)),
  state: ComputerState,
  need_filter: Bool,
) -> List(#(Int, Int)) {
  case input {
    "" -> accum
    "mul(" <> rest ->
      case state == Do || need_filter {
        True -> {
          let #(muls, after) =
            rest |> string.split_once(")") |> result.unwrap(#("", ""))

          case try_parse_mul(muls) {
            Error(_) -> parse_part(rest, accum, state, need_filter)
            Ok(t) ->
              parse_part(after, list.append(accum, [t]), state, need_filter)
          }
        }
        False -> parse_part(rest, accum, state, need_filter)
      }
    "don't()" <> rest -> parse_part(rest, accum, Dont, need_filter)
    "do()" <> rest -> parse_part(rest, accum, Do, need_filter)
    _ ->
      input
      |> string.pop_grapheme
      |> result.map(pair.second)
      |> result.unwrap("")
      |> parse_part(accum, state, need_filter)
  }
}

pub fn parse_part_one(input: String) -> List(#(Int, Int)) {
  parse_part(input, [], Do, True)
}

pub fn parse_part_two(input: String) -> List(#(Int, Int)) {
  parse_part(input, [], Do, False)
}

pub fn part1(input: String) -> Int {
  input
  |> parse_part_one
  |> fun.product_tuple
}

pub fn part2(input: String) -> Int {
  input
  |> parse_part_two
  |> fun.product_tuple
}
