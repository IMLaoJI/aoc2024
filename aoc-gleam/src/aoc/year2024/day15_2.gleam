import aoc/util/array2d.{type Direction, type Posn, Down, Left, Right, Top}
import aoc/util/coord.{type Coord, Coord}
import aoc/util/from
import aoc/util/to
import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/order
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

fn preprocess(input: String) -> String {
  input
  |> string.replace("#", "##")
  |> string.replace("O", "[]")
  |> string.replace(".", "..")
  |> string.replace("@", "@.")
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

fn get_horiz_boxs(current, map, delta, acc) {
  let next = array2d.add_posns(current, delta)
  let assert Ok(tile) = dict.get(map, current)
  let assert Ok(next_tile) = dict.get(map, next)
  case next_tile {
    Nothing -> Ok([#(current, tile), ..acc])
    LeftBox | RightBox | Box ->
      get_horiz_boxs(next, map, delta, [#(current, tile), ..acc])
    _ -> Error(Nil)
  }
}

fn get_vert_box(current, map, delta, acc) {
  let next = array2d.add_posns(current, delta)
  let assert Ok(next_tile) = dict.get(map, next)
  case next_tile {
    Nothing -> acc
    LeftBox | RightBox -> {
      let dir = case next_tile {
        LeftBox -> Right
        RightBox -> Left
        _ -> panic
      }
      list.try_map([next, array2d.add_direction(next, dir)], fn(n) {
        let assert Ok(t) = dict.get(map, n)
        acc
        |> result.map(list.prepend(_, #(n, t)))
        |> get_vert_box(n, map, delta, _)
      })
      |> result.map(list.flatten)
    }
    _ -> Error(Nil)
  }
}

fn next_step(robot: Posn, map: Dict(Posn, Tile), steps: List(Direction)) {
  use <- bool.guard(list.is_empty(steps), map)
  let assert [next, ..rest] = steps
  let delta = array2d.get_direction_dir(next)
  let next_position = array2d.add_posns(robot, delta)
  let next_destination = dict.get(map, next_position)
  case next_destination {
    Ok(Nothing) -> {
      move_box([#(robot, Robot)], map, delta)
      |> next_step(next_position, _, rest)
    }
    Ok(LeftBox) | Ok(RightBox) | Ok(Box) -> {
      let boxes = case next, next_destination {
        Left, _ | Right, _ | _, Ok(Box) -> get_horiz_boxs(robot, map, delta, [])
        Top, _ | Down, _ ->
          get_vert_box(robot, map, delta, Ok([#(robot, Robot)]))
      }
      case boxes {
        Ok(found_boxes) ->
          move_box(found_boxes, map, delta) |> next_step(next_position, _, rest)
        Error(_) -> next_step(robot, map, rest)
      }
    }
    _ -> next_step(robot, map, rest)
  }
}

pub fn part1(input: String) -> Int {
  let #(map_config, steps_config) = parse(input)
  let robot = find_robot(map_config)
  next_step(robot, map_config, steps_config)
  |> dict.fold(0, fn(acc, key, value) {
    case value {
      Box -> key.c + key.r * 100 + acc
      _ -> acc
    }
  })
}

fn print(res_dict: Dict(Posn, Tile), width) {
  res_dict
  |> dict.to_list
  |> list.sort(fn(a, b) {
    case int.compare({ a.0 }.r, { b.0 }.r) {
      order.Eq -> {
        int.compare({ a.0 }.c, { b.0 }.c)
      }
      _ -> int.compare({ a.0 }.r, { b.0 }.r)
    }
  })
  |> list.sized_chunk(width)
  |> list.map(fn(a) {
    io.debug(string.join(
      list.map(a, fn(b) {
        let c = to.unwrap(dict.get(res_dict, b.0))
        case c {
          Nothing -> "."
          Box -> "O"
          Wall -> "#"
          LeftBox -> "["
          RightBox -> "]"
          Robot -> "@"
        }
      }),
      "",
    ))
  })
}

pub fn part2(input: String) -> Int {
  let #(map_config, steps_config) = parse(input |> preprocess)
  let robot = find_robot(map_config)
  let width =
    {
      input
      |> string.split("\r\n")
      |> list.first
      |> to.unwrap
      |> string.length
    }
    * 2
  print(map_config, width)
  let new_map = next_step(robot, map_config, steps_config)
  print(new_map, width)
  dict.fold(new_map, 0, fn(acc, key, value) {
    case value {
      LeftBox -> key.c + key.r * 100 + acc
      _ -> acc
    }
  })
}
