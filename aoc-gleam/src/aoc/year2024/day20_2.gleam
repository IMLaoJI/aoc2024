import aoc/util/from
import aoc/util/xy.{type XY, XY}
import gleam/int
import gleam/io
import gleam/list

import gleam/set.{type Set}

import gleam/dict.{type Dict}

pub type Tile {
  Start
  End
  Wall
  Path
}

pub fn parse(input: String) -> Dict(XY, Tile) {
  from.grid(input, xy.from_input, fn(c) {
    case c {
      "S" -> Start
      "E" -> End
      "#" -> Wall
      "." -> Path
      _ -> panic
    }
  })
}

fn enumerate_path(input: Dict(XY, Tile)) -> Dict(XY, Int) {
  let assert [start] =
    input |> dict.filter(fn(_, v) { v == Start }) |> dict.keys
  let path = dict.new() |> dict.insert(start, 0)
  do_enumerate(start, path, input, 0, set.new() |> set.insert(start))
}

fn do_enumerate(
  position: XY,
  acc: Dict(XY, Int),
  grid: Dict(XY, Tile),
  i: Int,
  seen: Set(XY),
) -> Dict(XY, Int) {
  let assert Ok(next) =
    position
    |> xy.neighbors(xy.cardinal_directions)
    |> list.find(fn(n) {
      !set.contains(seen, n) && dict.get(grid, n) != Ok(Wall)
    })
  let acc = dict.insert(acc, next, i)
  case dict.get(grid, next) {
    Ok(End) -> acc
    Ok(Path) -> do_enumerate(next, acc, grid, i + 1, set.insert(seen, next))
    _ -> panic
  }
}

fn reachable_nodes(p: XY, distance: Int) -> List(XY) {
  io.debug(p)
  {
    use dy <- list.flat_map(list.range(-distance, distance))
    let span_size = distance - int.absolute_value(dy)

    use dx <- list.map(list.range(-span_size, span_size))
    XY(dx + p.x, dy + p.y)
  }
  |> io.debug
}

fn search_for_shortcuts(numbered_path: Dict(XY, Int), reach: Int) -> Int {
  //   parallel_map.list_pmap(
  //     dict.keys(numbered_path),
  //     fn(a) {
  //       use acc, b <- list.fold(reachable_nodes(a, reach), 0)
  //       let dist = xy.manhattan_dist(a, b)
  //       case dict.get(numbered_path, a), dict.get(numbered_path, b) {
  //         Ok(n), Ok(m) if m - n - dist >= 100 -> acc + 1
  //         _, _ -> acc
  //       }
  //     },
  //     parallel_map.MatchSchedulersOnline,
  //     1000,
  //   )
  //   |> result.values
  //   |> int.sum

  list.map(dict.keys(numbered_path), fn(a) {
    use acc, b <- list.fold(reachable_nodes(a, reach), 0)
    let dist = xy.manhattan_dist(a, b)
    case dict.get(numbered_path, a), dict.get(numbered_path, b) {
      Ok(n), Ok(m) if m - n - dist >= 100 -> acc + 1
      _, _ -> acc
    }
  })
  |> int.sum
}

pub fn part1(input: String) -> Int {
  input
  |> parse
  |> enumerate_path()
  |> search_for_shortcuts(2)
}

pub fn part2(input: String) -> Int {
  input
  |> parse
  |> enumerate_path()
  |> search_for_shortcuts(20)
}
