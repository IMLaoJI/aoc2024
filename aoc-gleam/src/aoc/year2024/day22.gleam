import aoc/util/to
import gleam/bool
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/string

import gleam/dict

fn parse(input) {
  input
  |> string.split("\r\n")
  |> list.try_map(int.parse)
  |> to.unwrap
}

fn create_secrect_num(num, time, acc, changes, maps) {
  use <- bool.guard(time == 0, #(acc, maps))
  let first =
    int.bitwise_exclusive_or(num * 64, num)
    |> fn(n) { n % 16_777_216 }
  let second =
    float.divide(int.to_float(first), 32.0)
    |> to.unwrap
    |> float.truncate
    |> int.bitwise_exclusive_or(first)
    |> fn(n) { n % 16_777_216 }
  let third =
    int.multiply(second, 2048)
    |> int.bitwise_exclusive_or(second)
    |> fn(n) { n % 16_777_216 }
  let new_changes =
    list.rest(changes)
    |> to.unwrap
    |> list.append([
      Some(to.unwrap(int.modulo(third, 10)) - to.unwrap(int.modulo(num, 10))),
    ])
  let new_maps = case !dict.has_key(maps, new_changes) {
    False -> maps
    True -> dict.insert(maps, new_changes, to.unwrap(int.modulo(third, 10)))
  }
  create_secrect_num(
    third,
    time - 1,
    list.append(acc, [third]),
    new_changes,
    new_maps,
  )
}

pub fn part1(input: String) -> Int {
  input
  |> parse
  |> list.map(fn(num) {
    create_secrect_num(num, 2000, [], [None, None, None, None], dict.new()).0
  })
  |> list.map(list.last)
  |> list.map(to.unwrap)
  |> io.debug
  |> list.fold(0, int.add)
}

pub fn part2(input: String) -> Int {
  let change =
    input
    |> parse
    |> list.index_fold(dict.new(), fn(acc, num, index) {
      create_secrect_num(num, 2000, [], [None, None, None, None], dict.new()).1
      |> dict.insert(acc, index, _)
    })

  use trueans, x1 <- list.fold(list.range(-9, 9), 0)
  use a1, x2 <- list.fold(list.range(-9, 9), trueans)
  use a2, x3 <- list.fold(list.range(-9, 9), a1)
  use a3, x4 <- list.fold(list.range(-9, 9), a2)
  let ans =
    dict.fold(change, 0, fn(accumulator, _, value) {
      case dict.get(value, [Some(x1), Some(x2), Some(x3), Some(x4)]) {
        Ok(an) -> accumulator + an
        Error(_) -> accumulator
      }
    })
  io.debug(#(x1, x2, x3, x4))
  int.max(a3, ans)
}
