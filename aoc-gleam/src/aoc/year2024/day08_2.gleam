import aoc/util/grid.{type Point}
import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/option.{None, Some}

import gleam/set

pub fn part1(input: String) -> Int {
  let map = parse(input)
  pt_1(map)
}

pub fn part2(input: String) -> Int {
  let map = parse(input)
  pt_2(map)
}

pub type Cell {
  Open
  Antenna(String)
}

pub type Map =
  Dict(grid.Point, Cell)

pub fn parse(input: String) -> Map {
  grid.grid(input, fn(c) {
    case c {
      "." -> Open
      chr -> Antenna(chr)
    }
  })
}

fn collect_antennas(input: Map) -> Dict(Cell, List(Point)) {
  use acc, k, v <- dict.fold(input, dict.new())
  use coords <- dict.upsert(acc, v)
  case coords {
    None -> [k]
    Some(_) if v == Open -> []
    Some(vs) -> [k, ..vs]
  }
}

fn find_antinodes(coords: List(Point), map) -> List(Point) {
  coords
  |> list.combinations(2)
  |> list.flat_map(fn(pair) {
    let assert [first, second] = pair
    [
      grid.go(second, grid.dist(first, second)),
      grid.go(first, grid.dist(second, first)),
    ]
    |> list.filter(dict.has_key(map, _))
  })
}

pub fn pt_1(input: Map) {
  input
  |> collect_antennas
  |> dict.values()
  |> list.flat_map(find_antinodes(_, input))
  |> set.from_list
  |> set.size
}

fn find_resonant_antinodes(coords: List(Point), map: Map) -> List(Point) {
  coords
  |> list.combinations(2)
  |> list.flat_map(fn(pair) {
    let assert [first, second] = pair
    list.flatten([
      next_antinode(second, grid.dist(first, second), map, []),
      next_antinode(first, grid.dist(second, first), map, []),
    ])
  })
}

fn next_antinode(grid, offset, map, acc) {
  case dict.has_key(map, grid) {
    True -> next_antinode(grid.go(grid, offset), offset, map, [grid, ..acc])
    False -> acc
  }
}

pub fn pt_2(input: Map) {
  input
  |> collect_antennas
  |> dict.values()
  |> list.flat_map(find_resonant_antinodes(_, input))
  |> set.from_list
  |> set.size()
}
