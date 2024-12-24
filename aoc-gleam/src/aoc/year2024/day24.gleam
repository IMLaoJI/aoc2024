import aoc/util/array2d.{type Posn, Posn}
import aoc/util/to
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/string

fn parse(input: String) {
  let assert Ok(#(first, second)) = string.split_once(input, "\r\n\r\n")
  let config =
    first
    |> string.split("\r\n")
    |> list.fold(dict.new(), fn(acc, line) {
      let assert Ok(#(first, second)) = string.split_once(line, ":")
      dict.insert(acc, first, to.int(second |> string.trim))
    })
  let moves =
    second
    |> string.split("\r\n")
    |> list.map(fn(line) {
      let assert Ok(#(first, second)) = string.split_once(line, " -> ")
      first
      |> string.split(" ")
      |> list.map(string.trim)
      |> list.append([second |> string.trim])
    })
  #(config, moves)
}

fn execute(todo_moves, config) {
  case todo_moves {
    [] -> {
      config
    }
    _ -> {
      let new_do =
        todo_moves
        |> list.group(by: fn(item) {
          let assert [first, op, second, out] as a = item
          case dict.get(config, first), dict.get(config, second) {
            _, Error(_) | Error(_), _ -> {
              "false"
            }
            _, _ -> {
              "true"
            }
          }
        })
      let todo_d = new_do |> dict.get("false")
      let todo_ok = new_do |> dict.get("true") |> to.unwrap
      case todo_d {
        Ok([]) -> config
        Ok(rest) -> {
          let #(new_config, _) = excute_one(todo_ok, config)
          execute(rest, new_config)
        }
        _ -> {
          let #(new_config, _) = excute_one(todo_ok, config)
          new_config
        }
      }
    }
  }
}

fn excute_one(moves, config) {
  moves
  |> list.fold(#(config, []), fn(c_acc, item) {
    let #(acc, todo_move) = c_acc
    let assert [first, op, second, out] as a = item
    case dict.get(acc, first), dict.get(acc, second) {
      _, Error(_) | Error(_), _ -> {
        #(acc, list.append(todo_move, [item]))
      }
      _, _ -> {
        let first_value = dict.get(acc, first) |> to.unwrap
        let second_value = dict.get(acc, second) |> to.unwrap
        let out_value = case op {
          "AND" -> {
            case first_value, second_value {
              1, 1 -> 1
              _, _ -> 0
            }
          }
          "XOR" -> {
            case first_value, second_value {
              1, 1 -> 0
              0, 0 -> 0
              _, _ -> 1
            }
          }
          "OR" -> {
            case first_value, second_value {
              0, 0 -> 0
              _, _ -> 1
            }
          }
          _ -> panic
        }
        #(dict.insert(acc, out, out_value), todo_move)
      }
    }
  })
}

fn get_num(moves, config, num) {
  execute(moves, config)
  |> dict.filter(fn(key, _) { string.starts_with(key, num) })
  |> dict.to_list
  |> list.sort(fn(a, b) { string.compare(b.0, a.0) })
  |> list.map(fn(a) { a.1 |> int.to_string })
  |> string.join("")
  |> io.debug
  |> int.base_parse(2)
  |> to.unwrap
}

pub fn part1(input: String) -> Int {
  let #(config, moves) =
    input
    |> parse
  moves
  |> list.sort(fn(a, b) {
    string.compare(to.unwrap(list.first(b)), to.unwrap(list.first(a)))
  })
  |> get_num(config, "z")
}

pub fn part2(input: String) -> Int {
  let #(config, moves) =
    input
    |> parse
  let moves =
    moves
    |> list.sort(fn(a, b) {
      string.compare(to.unwrap(list.first(b)), to.unwrap(list.first(a)))
    })
  let x = get_num(moves, config, "x")
  let y = get_num(moves, config, "y")
  let z = get_num(moves, config, "z")
  io.debug(#(x, y, z))
  1
}
