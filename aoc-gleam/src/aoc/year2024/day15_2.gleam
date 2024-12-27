import aoc/util/array2d.{type Direction, type Posn, Down, Left, Right, Top}
import aoc/util/coord.{type Coord, Coord}
import aoc/util/from
import aoc/util/to
import gleam/bool
import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/result
import gleam/string

pub type Tile {
  Nothing
  Box
  Wall
  LeftBox
  RightBox
  Robot
}

fn update_coordinate_sum(acc: Int, k: Coord, v: Tile) -> Int {
  case v {
    Box | LeftBox -> k.c + 100 * k.r + acc
    _ -> acc
  }
}

fn parse_map(map) {
  from.grid(map, array2d.Posn, fn(c) {
    case c {
      "." -> Nothing
      "O" -> Box
      "#" -> Wall
      "[" -> LeftBox
      "]" -> RightBox
      "@" -> Robot
      _ -> panic
    }
  })
}

fn parse_step(steps) {
  steps
  |> string.split("\r\n")
  |> list.flat_map(fn(line) {
    line
    |> string.split("")
    |> list.map(fn(c) {
      case c {
        "^" -> Top
        "v" -> Down
        "<" -> Left
        ">" -> Right
        _ -> panic
      }
    })
  })
}

pub fn parse(input) {
  let assert [map, steps] = string.split(input, "\r\n\r\n")
  let map_config = parse_map(map)
  let steps_config = parse_step(steps)
  #(map_config, steps_config)
}

fn find_robot(map_config) {
  map_config
  |> dict.filter(fn(_, v) { v == Robot })
  |> dict.keys
  |> list.first
  |> to.unwrap
}

fn move_box(items: List(#(Posn, Tile)), map, dir) {
  items
  |> list.fold(map, fn(acc, t) { dict.insert(acc, t.0, Nothing) })
  |> list.fold(
    items,
    _,
    fn(acc, t) { dict.insert(acc, array2d.add_posns(t.0, dir), t.1) },
  )
}

fn next_step(robot: Posn, map: Dict(Posn, Tile), steps: List(Direction)) {
  use <- bool.guard(list.is_empty(steps), map)
  let assert [next, ..rest] = steps
  let delta = array2d.get_direction_dir(next)
  let next = array2d.add_posns(robot, delta)
  case dict.get(map, next) {
    Ok(Nothing) -> {
      move_box([#(robot, Robot)], map, delta)
      |> next_step(next, _, rest)
    }
    Ok(LeftBox) | Ok(RightBox) | Ok(Box) -> {
      todo
    }
    _ -> next_step(robot, map, rest)
  }
  todo
}

pub fn part1(input: String) -> Int {
  let #(map_config, steps_config) = parse(input)
  let robot = find_robot(map_config) |> io.debug
  next_step(robot, map_config, steps_config)
  1
}

pub fn part2(input: String) -> Int {
  // let assert [map, steps] = string.split(input, "\r\n\r\n")
  // let map = map |> preprocess |> parse_map
  // let steps = parse_steps(steps)
  // let assert [robot] = map |> dict.filter(fn(_, v) { v == Robot }) |> dict.keys

  // dict.fold(next_step(robot, map, steps), 0, update_coordinate_sum)
  1
}
