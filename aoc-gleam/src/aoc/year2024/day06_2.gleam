import aoc/util/array2d.{type Array2D, type Posn, Posn}
import aoc/util/to.{int, unwrap}
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/set

pub type Direction {
  Up
  Down
  Left
  Right
}

fn find_start(dict) {
  dict
  |> dict.filter(fn(_, value) { value == "^" })
}

fn patrol(
  find_array: List(List(String)),
  map: Array2D(String),
  pos: Posn,
  direction: Direction,
  visited: Dict(#(Posn, Direction), Direction),
) -> #(Bool, Dict(#(Posn, Direction), Direction)) {
  case
    dict.has_key(visited, #(pos, direction))
    && result.unwrap(dict.get(visited, #(pos, direction)), Up) == direction
  {
    True -> #(False, dict.new())
    False -> {
      let visited = dict.insert(visited, #(pos, direction), direction)
      let assert Ok(first) = list.first(find_array)
      case
        pos.r <= 0
        || pos.r >= int.subtract(list.length(find_array), 1)
        || pos.c <= 0
        || pos.c >= int.subtract(list.length(first), 1)
      {
        True -> #(True, visited)
        False ->
          case is_obstacle(map, pos, direction) {
            True -> patrol(find_array, map, pos, turn_right(direction), visited)
            False ->
              patrol(
                find_array,
                map,
                step_forward(pos, direction),
                direction,
                visited,
              )
          }
      }
    }
  }
}

fn is_obstacle(map: Array2D(String), pos: Posn, direction: Direction) -> Bool {
  let new_pos = step_forward(pos, direction)
  case dict.get(map, new_pos) {
    Ok("#") -> True
    _ -> False
  }
}

fn step_forward(pos: Posn, direction: Direction) -> Posn {
  case direction {
    Up -> Posn(pos.r - 1, pos.c)
    Down -> Posn(pos.r + 1, pos.c)
    Left -> Posn(pos.r, pos.c - 1)
    Right -> Posn(pos.r, pos.c + 1)
  }
}

fn turn_right(direction: Direction) -> Direction {
  case direction {
    Up -> Right
    Right -> Down
    Down -> Left
    Left -> Up
  }
}

fn parse(input) {
  let find_array = input |> array2d.to_list_of_lists
  let find_dict = find_array |> array2d.to_2d_array
  let assert Ok(start_point) =
    find_dict |> find_start |> dict.keys |> list.first

  #(find_array, find_dict, start_point)
}

fn build_jump_map(find_array: List(List(String)), map: Array2D(String)) {
  let j = dict.new()

  let w = list.length(find_array)
  let h = list.length(unwrap(list.first(find_array)))
  let j =
    list.fold(list.range(0, h - 1), j, fn(jump_dict, x) {
      let l = #(Posn(x, -1), Up)

      let #(jump_dict, _) =
        list.fold(list.range(0, h - 1), #(jump_dict, l), fn(t, y) {
          let #(jump_dict, l) = t
          let new_l = case unwrap(dict.get(map, Posn(x, y))) == "#" {
            True -> #(Posn(x, y + 1), Up)
            False -> l
          }
          #(dict.insert(jump_dict, #(x, y, Left), new_l), new_l)
        })
      let l = #(Posn(x, w), Down)
      let #(jump_dict, _) =
        list.fold(list.reverse(list.range(0, h - 1)), #(jump_dict, l), fn(t, y) {
          let #(jump_dict, l) = t
          let new_l = case unwrap(dict.get(map, Posn(x, y))) == "#" {
            True -> #(Posn(x, y - 1), Down)
            False -> l
          }
          #(dict.insert(jump_dict, #(x, y, Right), new_l), new_l)
        })
      jump_dict
    })

  let jump_dict =
    list.fold(list.range(0, w - 1), j, fn(jump_dict, y) {
      let l = #(Posn(-1, y), Right)
      let #(jump_dict, _) =
        list.fold(list.range(0, h - 1), #(jump_dict, l), fn(t, x) {
          let #(jump_dict, l) = t
          let new_l = case unwrap(dict.get(map, Posn(x, y))) == "#" {
            True -> #(Posn(x + 1, y), Right)
            False -> l
          }
          #(dict.insert(jump_dict, #(x, y, Up), new_l), new_l)
        })
      let l = #(Posn(h, y), Left)

      let #(jump_dict, _) =
        list.fold(list.reverse(list.range(0, h - 1)), #(jump_dict, l), fn(t, x) {
          let #(jump_dict, l) = t
          let new_l = case unwrap(dict.get(map, Posn(x, y))) == "#" {
            True -> #(Posn(x - 1, y), Left)
            False -> l
          }
          #(dict.insert(jump_dict, #(x, y, Down), new_l), new_l)
        })
      jump_dict
    })
  jump_dict
}

pub fn count(
  candidate: Posn,
  find_dict,
  jump_dict,
  current_point: Posn,
  current_direction,
  visisted,
) {
  case
    dict.has_key(find_dict, current_point)
    && !set.contains(visisted, #(current_point, current_direction))
  {
    True -> {
      let visisted = set.insert(visisted, #(current_point, current_direction))
      case current_point.r != candidate.r && current_point.c != candidate.c {
        True -> {
          let #(new_current, new_direction) =
            unwrap(
              dict.get(jump_dict, #(
                current_point.r,
                current_point.c,
                current_direction,
              )),
            )

          count(
            candidate,
            find_dict,
            jump_dict,
            new_current,
            new_direction,
            visisted,
          )
        }
        False -> {
          let next_point = step_forward(current_point, current_direction)
          let #(new_current, new_direction) = case
            result.unwrap(dict.get(find_dict, next_point), "") == "#"
            || next_point == candidate
          {
            True -> #(current_point, turn_right(current_direction))
            False -> #(next_point, current_direction)
          }
          count(
            candidate,
            find_dict,
            jump_dict,
            new_current,
            new_direction,
            visisted,
          )
        }
      }
    }
    False -> {
      case set.contains(visisted, #(current_point, current_direction)) {
        True -> 1
        False -> 0
      }
    }
  }
}

pub fn part2(input: String) -> Int {
  let #(find_array, find_dict, start_point) = parse(input)
  let #(_, paths) = patrol(find_array, find_dict, start_point, Up, dict.new())

  let jump_dict = build_jump_map(find_array, find_dict)
  let candidates =
    paths
    |> dict.keys
    |> list.map(fn(t) { t.0 })
    |> list.unique

  list.fold(candidates, 0, fn(acc, candidata) {
    acc + count(candidata, find_dict, jump_dict, start_point, Up, set.new())
  })
}

pub fn part1(input: String) -> Int {
  let #(find_array, find_dict, start_point) = parse(input)
  let #(_, paths) = patrol(find_array, find_dict, start_point, Up, dict.new())
  paths |> dict.keys |> list.group(fn(t) { t.0 }) |> dict.size
}
