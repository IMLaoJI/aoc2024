import aoc/util/re
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp.{type Match, Match}
import gleam/result

fn parse_line(input, need_filter) {
  let regex_str = re.from_string("(do\\(\\)|don't\\(\\))")
  let res = regexp.split(regex_str, input)
  let #(_, result) =
    list.fold(res, #(True, 0), fn(acc, item) {
      let #(acc, sum) = acc
      case item {
        "do()" -> #(True, sum)
        "don't()" -> #(False, sum)
        _ -> {
          let regex_str = re.from_string("mul\\((\\d{1,3}),\\s*(\\d{1,3})\\)")
          let fold_v =
            list.fold(regexp.scan(regex_str, item), sum, fn(sumal, match) {
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
