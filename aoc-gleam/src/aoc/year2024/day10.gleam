import aoc/util/array2d.{type Posn}

import aoc/util/to

import gleam/dict.{type Dict}
import gleam/int

import gleam/list

import gleam/result

fn parse(input: String) {
  let find_array =
    input
    |> array2d.parse_grid_list
    |> list.map(fn(p) { #(p.0, to.int(p.1)) })
    |> list.filter(fn(p) { p.1 == 0 })
  let find_dict = input |> array2d.parse_grid_using(fn(p) { int.parse(p) })
  #(find_array, find_dict)
}

fn count(current: #(Posn, Int), find_dict: Dict(Posn, Int), visisted) {
  let #(current_po, _) = current
  let current_value = dict.get(find_dict, current_po)
  case current_value {
    Ok(nu) if nu == 9 -> {
      list.append(visisted, [current_po])
    }
    Ok(nu) -> {
      array2d.ortho_neighbors(current_po)
      |> list.filter(fn(p) {
        result.is_ok(dict.get(find_dict, p))
        && to.unwrap(dict.get(find_dict, p)) - nu == 1
      })
      |> list.fold(visisted, fn(accc, p) {
        count(#(p, to.unwrap(dict.get(find_dict, p))), find_dict, accc)
      })
    }
    _ -> visisted
  }
}

pub fn part1(input: String) -> Int {
  let #(find_array, find_dict) =
    input
    |> parse

  find_array
  |> list.map(count(_, find_dict, []))
  |> list.map(list.unique)
  |> list.map(list.length)
  |> int.sum
}

pub fn part2(input: String) -> Int {
  let #(find_array, find_dict) =
    input
    |> parse

  find_array
  |> list.map(count(_, find_dict, []))
  |> list.map(list.length)
  |> int.sum
}
