import aoc/util/array2d

import aoc/util/to
import gleam/bool

import gleam/dict

import gleam/int
import gleam/io
import gleam/list
import gleam/result

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

fn get_possible_cheats(input_dict) {
  dict.filter(input_dict, fn(_, value) { list.contains([".", "S", "E"], value) })
  |> dict.fold([], fn(acc, key, _) {
    array2d.ortho_neighbors_with_direction(key)
    |> list.fold(acc, fn(acc, p) {
      let #(pos, dir) = p
      case
        dict.get(input_dict, pos),
        dict.get(input_dict, array2d.add_posns(pos, dir))
      {
        Ok("#"), Ok(".") ->
          list.append(acc, [#(key, array2d.add_posns(pos, dir))])
        _, _ -> acc
      }
    })
  })
}

pub fn part1(input: String) -> Int {
  let config =
    input
    |> parse
  let #(from_start, _) = search.dijkstra(config, config.start.0, edges)
  let #(from_end, _) = search.dijkstra(config, config.end.0, edges)
  let honest = dict.get(from_start, config.end.0) |> io.debug |> to.unwrap
  get_possible_cheats(config.input_dict)
  |> list.fold(0, fn(acc, p) {
    case
      to.unwrap(dict.get(from_start, p.0))
      + to.unwrap(dict.get(from_end, p.1))
      + 2
      + 100
      <= honest
    {
      True -> acc + 1
      False -> acc
    }
  })
}

pub fn part2(input: String) -> Int {
  let config =
    input
    |> parse
  let #(from_start, _) = search.dijkstra(config, config.start.0, edges)
  let #(from_end, _) = search.dijkstra(config, config.end.0, edges)
  let honest = dict.get(from_start, config.end.0) |> io.debug |> to.unwrap
  let opens =
    dict.filter(config.input_dict, fn(_, value) {
      list.contains([".", "S", "E"], value)
    })
    |> dict.keys

  use acc, cs <- list.fold(opens, 0)
  use acc2, ce <- list.fold(opens, acc)
  let dst = int.absolute_value(cs.r - ce.r) + int.absolute_value(cs.c - ce.c)
  use <- bool.guard(dst > 20, acc2)
  case
    to.unwrap(dict.get(from_start, cs))
    + to.unwrap(dict.get(from_end, ce))
    + dst
    + 100
    <= honest
  {
    True -> acc2 + 1
    False -> acc2
  }
}
