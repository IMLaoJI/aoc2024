import aoc/util/grid.{type Grid, type Point, type Word, Point, directions}
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/set
import gleam/string
import gleam/yielder

pub fn parse(input: String) {
  let lines = string.split(input, "\r\n")
  let bound = list.length(lines)
  let antennas = {
    use acc, line, x <- list.index_fold(lines, dict.new())
    let nodes = string.to_graphemes(line)
    use acc2, c, y <- list.index_fold(nodes, acc)
    case c {
      "." -> acc2
      c -> {
        use d <- dict.upsert(acc2, c)
        let d = option.unwrap(d, [])
        [Point(x, y), ..d]
      }
    }
  }
  #(antennas, bound)
}

pub fn part1(input: String) -> Int {
  input
  |> parse
  |> pt_1
}

pub fn part2(input: String) -> Int {
  input
  |> parse
  |> pt_2
}

fn is_in_bounds(point: Point, bound: Int) -> Bool {
  point.x >= 0 && point.x < bound && point.y >= 0 && point.y < bound
}

fn antennas_to_heaven(antenna: Point, dist: Point) -> yielder.Yielder(Point) {
  yielder.iterate(antenna, fn(a) { grid.go(a, dist) })
}

pub fn pt_1(input: #(dict.Dict(String, List(Point)), Int)) {
  let #(antennas, bound) = input
  let antinodes =
    {
      use acc, _k, v <- dict.fold(antennas, set.new())
      let pairs = list.combination_pairs(v)
      {
        use #(antenna1, antenna2) <- list.flat_map(pairs)
        let dist = grid.dist(antenna2, antenna1)
        let antinode_1 = grid.go(antenna1, dist)
        let antinode_2 = grid.sub(antenna2, dist)
        [antinode_1, antinode_2]
      }
      |> set.from_list
      |> set.union(acc)
    }
    |> set.filter(is_in_bounds(_, bound))
  set.size(antinodes)
}

pub fn pt_2(input: #(dict.Dict(String, List(Point)), Int)) {
  let #(antennas, bound) = input
  let pairs = antennas |> dict.values |> list.flat_map(list.combination_pairs)
  io.debug(pairs)
  let antinodes = {
    use acc, #(antenna1, antenna2) <- list.fold(pairs, set.new())
    let dist = grid.dist(antenna1, antenna2)
    let antinodes_1 =
      antennas_to_heaven(antenna1, dist)
      |> yielder.take_while(is_in_bounds(_, bound))
      |> yielder.to_list
    let antinodes_2 =
      antennas_to_heaven(antenna1, grid.negate(dist))
      |> yielder.take_while(is_in_bounds(_, bound))
      |> yielder.to_list

    set.union(acc, list.append(antinodes_1, antinodes_2) |> set.from_list)
  }
  set.size(antinodes)
}
