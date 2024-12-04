import aoc/util/re
import aoc/util/str
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regex.{type Match, Match}
import gleam/result
import gleam/string

// fn parse_line(input) {
//   use a <- result.map(regex.compile(
//     "mul\\((\\d{1,3}),\\s*(\\d{1,3})\\)",
//     regex.Options(case_insensitive: True, multi_line: False),
//   ))
//   list.map(regex.scan(a, input), fn(match) {
//     let assert Match(submatches: [Some(name), Some(left)], ..) = match
//     #(result.unwrap(int.parse(name), 0), result.unwrap(int.parse(left), 0))
//   })
// }

fn parse_line(input, need_filter) {
  let assert Ok(re) = regex.from_string("(do\\(\\)|don't\\(\\))")
  let res = regex.split(re, input)
  let #(_, result) =
    list.fold(res, #(True, 0), fn(acc, item) {
      let #(acc, sum) = acc
      case item {
        "do()" -> #(True, sum)
        "don't()" -> #(False, sum)
        _ -> {
          let assert Ok(re) =
            regex.from_string("mul\\((\\d{1,3}),\\s*(\\d{1,3})\\)")
          let fold_v =
            list.fold(regex.scan(re, item), sum, fn(sumal, match) {
              let assert Match(submatches: [Some(left), Some(right)], ..) =
                match
              sumal
              + case acc || need_filter {
                True ->
                  result.unwrap(int.parse(left), 0)
                  * result.unwrap(int.parse(right), 0)
                False -> 0
              }
            })
          #(acc, fold_v)
        }
      }
    })
  result
}

pub fn part1(input: String) -> Int {
  input
  |> parse_line(False)
}

pub fn part2(input: String) -> Int {
  input
  |> parse_line(True)
}
