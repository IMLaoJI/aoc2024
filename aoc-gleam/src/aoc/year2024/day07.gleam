import aoc/util/array2d.{type Array2D, type Posn, Posn}
import aoc/util/str
import aoc/util/to
import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import parallel_map

fn parse_line(line: String) {
  let assert [first, num] =
    line
    |> string.trim
    |> string.split(":")
  to.int(first)
  let rules =
    num
    |> string.trim
    |> to.ints(" ")
  #(to.int(first), rules)
}

fn concatenate(a: Int, b: Int) -> Int {
  let assert Ok(a_digits) = int.digits(a, 10)
  let assert Ok(b_digits) = int.digits(b, 10)
  let assert Ok(result) = list.append(a_digits, b_digits) |> int.undigits(10)
  result
}

fn valid(frontier, numbers, answer, need_concat, visited) {
  let assert Ok(#(current, index)) = list.last(frontier)
  let pop_later =
    list.reverse(result.unwrap(list.rest(list.reverse(frontier)), []))

  case list.length(numbers) - 1 == index && current == answer {
    True -> {
      True
    }
    False -> {
      case list.length(numbers) - 1 > index {
        True -> {
          let next = to.unwrap(list.first(list.drop(numbers, index + 1)))
          let frontier =
            list.append(pop_later, [
              #(current + next, index + 1),
              #(current * next, index + 1),
            ])

          let concat = to.int(int.to_string(current) <> int.to_string(next))
          let frontier = case need_concat {
            True -> list.append(frontier, [#(concat, index + 1)])
            False -> frontier
          }
          let visited = list.append(visited, [concat])
          valid(frontier, numbers, answer, need_concat, visited)
        }
        False -> {
          use <- bool.guard(list.is_empty(pop_later), False)
          valid(pop_later, numbers, answer, need_concat, visited)
        }
      }
    }
  }
}

pub fn part1(input: String) -> Int {
  input
  |> str.lines
  |> list.map(parse_line)
  |> list.filter(fn(t) {
    let #(ans, numbers) = t
    let frontier = [#(to.unwrap(list.first(numbers)), 0)]
    valid(frontier, numbers, ans, False, [])
  })
  |> list.fold(0, fn(acc, t) { acc + t.0 })
}

pub fn part2(input: String) -> Int {
  input
  |> str.lines
  |> list.map(parse_line)
  |> list.filter(fn(t) {
    let #(ans, numbers) = t
    let frontier = [#(to.unwrap(list.first(numbers)), 0)]
    valid(frontier, numbers, ans, True, [])
  })
  |> list.fold(0, fn(acc, t) { acc + t.0 })
}
