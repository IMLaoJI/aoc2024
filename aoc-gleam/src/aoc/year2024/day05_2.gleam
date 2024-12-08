import aoc/util/to
import gleam/bool
import gleam/dict
import gleam/list
import gleam/order
import gleam/string

pub fn parse(input: String) {
  let assert Ok(#(rules, lines)) = string.split_once(input, "\r\n\r\n")

  let rules =
    string.split(rules, "\r\n")
    |> list.fold(dict.new(), fn(rules, line) {
      let assert Ok(#(x, y)) = string.split_once(line, "|")

      let y = to.int(y)
      let x = to.int(x)

      case dict.get(rules, x) {
        Error(_) -> dict.insert(rules, x, [y])
        Ok(rest) -> dict.insert(rules, x, [y, ..rest])
      }
    })

  let lines =
    list.map(string.split(lines, "\r\n"), fn(line) {
      line
      |> string.split(",")
      |> list.map(to.int)
    })

  #(rules, lines)
}

fn get_middle(xs: List(a)) -> a {
  to.unwrap(do_middle(xs, xs))
}

fn do_middle(one_step: List(a), two_step: List(a)) -> Result(a, Nil) {
  case one_step, two_step {
    [middle, ..], [] | [middle, ..], [_] -> Ok(middle)
    [_, ..one_rest], [_, _, ..two_rest] -> do_middle(one_rest, two_rest)
    _, _ -> Error(Nil)
  }
}

pub type Parsed =
  #(dict.Dict(Int, List(Int)), List(List(Int)))

pub fn part1(input: String) -> Int {
  let #(rules, lines) = parse(input)
  use count, line <- list.fold(lines, 0)

  use <- bool.guard(!is_sorted(line, rules), count)
  count + get_middle(line)
}

pub fn part2(input: String) -> Int {
  let #(rules, lines) = parse(input)
  use count, line <- list.fold(lines, 0)

  use <- bool.guard(is_sorted(line, rules), count)
  let line = to_sorted(line, rules)
  count + get_middle(line)
}

fn is_sorted(line: List(Int), rules: dict.Dict(Int, List(Int))) {
  use pair <- list.all(list.window_by_2(line))
  case dict.get(rules, pair.0) {
    Error(_) -> False
    Ok(first_rules) -> list.contains(first_rules, pair.1)
  }
}

fn to_sorted(line: List(Int), rules: dict.Dict(Int, List(Int))) {
  use a, b <- list.sort(line)
  case dict.get(rules, b) {
    Error(_) -> order.Lt
    Ok(first_rules) -> {
      case list.contains(first_rules, a) {
        False -> order.Lt
        True -> order.Gt
      }
    }
  }
}
