// bad solution  can't fix part2
import aoc/util/array2d.{type Direction, type Posn, Down, Left, Right, Top}
import aoc/util/to
import gleam/io
import gleam/list
import gleam/result
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
  let input_position_array = first |> array2d.to_list_of_lists_with_po
  let list_string = array2d.to_list_of_lists(first)
  let moves =
    list.flat_map(string.split(second, "\r\n"), fn(line) {
      string.to_graphemes(line)
    })
    |> list.map(fn(p) { to.unwrap(dict.get(maps, p)) })
  #(
    input_position_array |> list.flatten,
    dict.from_list(input_position_array |> list.flatten),
    moves,
    list.length(to.unwrap(list.first(list_string))),
    input_position_array,
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

pub fn find_next_postion2(
  current: List(Posn),
  direction: Direction,
  change_list,
  input_dict: Dict(Posn, String),
) {
  list.fold(current, [], fn(acc, p) {
    let next_position =
      array2d.add_posns(p, array2d.get_direction_dir(direction))
    io.debug(#(
      current,
      dict.get(input_dict, next_position),
      dict.get(input_dict, p),
      next_position,
      change_list,
    ))
    let a = case dict.get(input_dict, next_position), dict.get(input_dict, p) {
      Ok(po), Ok(po1) if po1 == "[" || po1 == "]" || po == "[" || po == "]" -> {
        io.debug(#(current, direction))
        let new_change = case po == "[" || po1 == "[" {
          True -> {
            let right =
              array2d.add_posns(
                next_position,
                array2d.get_direction_dir(array2d.Right),
              )
            list.append(change_list, [
              #(
                next_position,
                array2d.add_posns(
                  next_position,
                  array2d.get_direction_dir(direction),
                ),
              ),
              #(
                right,
                array2d.add_posns(right, array2d.get_direction_dir(direction)),
              ),
            ])
          }
          False -> {
            let left =
              array2d.add_posns(
                next_position,
                array2d.get_direction_dir(array2d.Left),
              )
            list.append(change_list, [
              #(
                next_position,
                array2d.add_posns(
                  next_position,
                  array2d.get_direction_dir(direction),
                ),
              ),
              #(
                left,
                array2d.add_posns(left, array2d.get_direction_dir(direction)),
              ),
            ])
          }
        }
        Ok(find_next_postion2(
          new_change |> list.map(fn(n) { n.1 }),
          direction,
          new_change,
          input_dict,
        ))
      }
      Ok(po), Ok(po1) if po == "." -> Ok(change_list)
      Ok(po), Ok(po1) if po == "#" -> Error([])

      Ok(_), Ok(_) -> {
        io.debug("--------")
        Error([])
      }
      _, _ -> Error([])
    }
    io.debug(#(a, result.unwrap(a, [])))
    result.unwrap(a, [])
  })
}

pub fn move2(
  current: Posn,
  direction: Direction,
  input_dict: Dict(Posn, String),
) {
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
    Ok(po) if po == "[" || po == "]" -> {
      // find next dot position in same direction
      let change_list = find_next_postion2([current], direction, [], input_dict)
      case list.length(change_list) > 0 {
        True -> {
          io.debug(#(current, change_list))

          let new_dict =
            list.fold(change_list, input_dict, fn(acc, n) {
              case list.find(change_list, fn(a) { a.1 == n.0 }) {
                Ok(_) -> {
                  dict.insert(acc, n.1, to.unwrap(dict.get(input_dict, n.0)))
                }
                Error(_) -> {
                  dict.insert(acc, n.0, ".")
                  dict.insert(acc, n.1, to.unwrap(dict.get(input_dict, n.0)))
                }
              }
            })
          #(
            next_position,
            dict.insert(new_dict, current, ".")
              |> dict.insert(next_position, "@"),
          )
        }
        False -> #(current, input_dict)
      }
    }
    Ok(_) -> #(current, input_dict)
    Error(_) -> #(current, input_dict)
  }
}

pub fn find_box(dict) {
  dict.filter(dict, fn(_, value) { value == "O" })
}

fn print(input_position_array: List(#(Posn, String)), res_dict, width) {
  input_position_array
  |> list.sized_chunk(width)
  |> list.map(fn(a) {
    io.debug(string.join(
      list.map(a, fn(b) { to.unwrap(dict.get(res_dict, b.0)) }),
      "",
    ))
  })
}

pub fn part1(input: String) {
  let #(input_position_array, input_dict, moves, width, _) = input |> parse
  let start = find_start(input_position_array)
  let res =
    moves
    |> list.fold(#(start.0, input_dict), fn(acc, dir) {
      let #(start_p, acc_dict) = acc
      let acc = move(start_p, dir, acc_dict)
      acc
    })
  print(input_position_array, res.1, width)
  find_box(res.1)
  |> dict.keys
  |> list.fold(0, fn(acc, p) { acc + p.r * 100 + p.c })
}

fn change_map(input_position_array_level: List(List(#(Posn, String)))) {
  list.map(input_position_array_level, fn(p) {
    list.fold(p, [], fn(acc, item) {
      let #(position, char) = item
      let new_item = case char {
        "#" -> ["#", "#"]
        "O" -> ["[", "]"]
        "." -> [".", "."]
        "@" -> ["@", "."]
        _ -> panic
      }
      list.append(acc, new_item)
    })
  })
  |> io.debug
}

pub fn part2(input: String) -> Int {
  let #(
    input_position_array,
    input_dict,
    moves,
    width,
    input_position_array_level,
  ) =
    input
    |> parse

  let new_array =
    change_map(input_position_array_level)
    |> array2d.to_2d_stringlist
  let new_dict = dict.from_list(new_array)
  print(new_array, new_dict, width * 2)
  let start = find_start(new_array)
  let res =
    moves
    |> list.fold(#(start.0, new_dict), fn(acc, dir) {
      let #(start_p, acc_dict) = acc
      io.debug(#(start_p, dir))

      let acc = move2(start_p, dir, acc_dict)
      acc
    })

  print(new_array, res.1, width * 2)
  1
}
