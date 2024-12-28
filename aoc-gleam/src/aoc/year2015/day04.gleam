import aoc/util/array2d.{type Posn, Posn}
import aoc/util/fun
import aoc/util/to
import gleam/bit_array
import gleam/bool
import gleam/crypto
import gleam/deque
import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/set
import gleam/string

fn parse(input: String) {
  todo
}

fn md5_hash(input: String) -> String {
  crypto.hash(crypto.Md5, bit_array.from_string(input))
  |> bit_array.base16_encode
}

fn solve(input, number, prefix) {
  case md5_hash(input <> int.to_string(number)) |> string.starts_with(prefix) {
    True -> number
    False -> solve(input, number + 1, prefix)
  }
}

pub fn part1(_: String) -> Int {
  let input = "ckczppom"
  solve(input, 1, "00000")
}

pub fn part2(_: String) -> Int {
  let input = "ckczppom"
  solve(input, 1, "000000")
}
