import aoc/util/array2d.{type Direction, type Posn, Down, Left, Right, Top}
import aoc/util/to
import gleam/io
import gleam/list
import gleam/string

import gleam/dict.{type Dict}

fn parse(input) {
  let maps =
    dict.new()
    |> dict.insert("<", Left)
    |> dict.insert(">", Right)
    |> dict.insert("^", Top)
    |> dict.insert("v", Down)

  let assert Ok(#(first, second)) = string.split_once(input, "\r\n\r\n")
  let input_position_array =
    first |> array2d.to_list_of_lists |> array2d.to_2d_stringlist
  let list_string = array2d.to_list_of_lists(first)
  let moves =
    list.flat_map(string.split(second, "\r\n"), fn(line) {
      string.to_graphemes(line)
    })
    |> list.map(fn(p) { to.unwrap(dict.get(maps, p)) })
  #(
    input_position_array,
    dict.from_list(input_position_array),
    moves,
    list.length(to.unwrap(list.first(list_string))),
  )
}

pub fn find_start(input_position_array: List(#(Posn, String))) {
  to.unwrap(list.find(input_position_array, fn(p) { p.1 == "@" }))
}

pub fn find_next_postion(
  current: Posn,
  direction: Direction,
  change_list,
  input_dict: Dict(Posn, String),
) {
  let next_position =
    array2d.add_posns(current, array2d.get_direction_dir(direction))
  case dict.get(input_dict, next_position) {
    Ok(po) if po == "." -> Ok(change_list)
    Ok(po) if po == "#" -> Error(Nil)
    Ok(po) -> {
      let change_list =
        list.append(change_list, [
          #(
            next_position,
            array2d.add_posns(
              next_position,
              array2d.get_direction_dir(direction),
            ),
          ),
        ])
      find_next_postion(next_position, direction, change_list, input_dict)
    }
    Error(_) -> Error(Nil)
  }
}

pub fn move(current: Posn, direction: Direction, input_dict: Dict(Posn, String)) {
  let next_position =
    array2d.add_posns(current, array2d.get_direction_dir(direction))
  case dict.get(input_dict, next_position) {
    Ok(po) if po == "." -> {
      #(
        next_position,
        dict.insert(input_dict, current, ".")
          |> dict.insert(next_position, "@"),
      )
    }
    Ok(po) if po == "O" -> {
      // find next dot position in same direction
      case find_next_postion(current, direction, [], input_dict) {
        Ok(change_list) -> {
          let new_dict =
            list.fold(change_list, input_dict, fn(acc, n) {
              case list.find(change_list, fn(a) { a.1 == n.0 }) {
                Ok(_) -> {
                  dict.insert(acc, n.1, "O")
                }
                Error(_) -> {
                  dict.insert(acc, n.0, ".")
                  |> dict.insert(n.1, "O")
                }
              }
            })
          #(
            next_position,
            dict.insert(new_dict, current, ".")
              |> dict.insert(next_position, "@"),
          )
        }
        Error(_) -> #(current, input_dict)
      }
    }
    Ok(_) -> #(current, input_dict)
    Error(_) -> #(current, input_dict)
  }
}

pub fn find_box(dict) {
  dict.filter(dict, fn(_, value) { value == "O" })
}

pub fn part1(input: String) {
  let #(input_position_array, input_dict, moves, width) = input |> parse
  let start = find_start(input_position_array)
  let res =
    moves
    |> list.fold(#(start.0, input_dict), fn(acc, dir) {
      let #(start_p, acc_dict) = acc
      let acc = move(start_p, dir, acc_dict)
      acc
    })

  input_position_array
  |> list.sized_chunk(width)
  |> list.map(fn(a) {
    io.debug(string.join(
      list.map(a, fn(b) { to.unwrap(dict.get(res.1, b.0)) }),
      "",
    ))
  })

  find_box(res.1)
  |> dict.keys
  |> list.fold(0, fn(acc, p) { acc + p.r * 100 + p.c })
}

pub fn part2(input: String) -> Int {
  input
  |> parse
  1
}
