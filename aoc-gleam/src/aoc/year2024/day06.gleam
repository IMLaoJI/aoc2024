import aoc/util/array2d.{type Array2D, type Posn, Posn}
import aoc/util/to.{int, unwrap}
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result

type Direction {
  Up
  Down
  Left
  Right
}

fn find_start(dict) {
  dict
  |> dict.filter(fn(key, value) { value == "^" })
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

pub fn part1(input: String) -> Int {
  let #(find_array, find_dict, start_point) = parse(input)
  let #(_, paths) = patrol(find_array, find_dict, start_point, Up, dict.new())
  paths |> dict.keys |> list.group(fn(t) { t.0 }) |> dict.size
}

pub fn part2(input: String) -> Int {
  let #(find_array, find_dict, start_point) = parse(input)
  let #(_, paths) = patrol(find_array, find_dict, start_point, Up, dict.new())
  paths
  |> dict.keys
  |> list.map(fn(t) { t.0 })
  |> list.unique
  |> list.filter(fn(p) {
    let new_dict = dict.insert(find_dict, p, "#")
    !patrol(find_array, new_dict, start_point, Up, dict.new()).0
  })
  |> list.length
}
