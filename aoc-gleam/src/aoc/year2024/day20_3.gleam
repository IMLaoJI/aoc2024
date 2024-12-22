import aoc/util/array2d.{type Posn, Posn}
import aoc/util/fun
import aoc/util/to
import gleam/bool
import gleam/deque
import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set

import aoc/util/search.{Config}

fn edges(cur, input_dict) {
  array2d.ortho_neighbors(cur)
  |> list.filter(fn(p) {
    list.contains([".", "S", "E"], result.unwrap(dict.get(input_dict, p), ""))
  })
}

fn parse(input) {
  let input_position_array =
    input |> array2d.to_list_of_lists_with_po |> list.flatten
  let input_dict = dict.from_list(input_position_array)
  let start = list.find(input_position_array, fn(p) { p.1 == "S" }) |> to.unwrap
  let end = list.find(input_position_array, fn(p) { p.1 == "E" }) |> to.unwrap
  Config(input_dict, start, end)
}

pub fn part1(input: String) -> Int {
  let config =
    input
    |> parse
  let #(from_start, _) = search.dijkstra(config, config.start.0, edges)
  let #(from_end, _) = search.dijkstra(config, config.end.0, edges)
  io.debug(#(from_start, config.end.0))
  dict.get(from_start, config.end.0) |> io.debug
  1
}

pub fn part2(input: String) -> Int {
  input
  |> parse
  1
}
