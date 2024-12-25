import aoc/util/to
import gleam/bool
import gleam/dict
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

fn find(op1, op2, op, moves) {
  let find =
    moves
    |> list.find(fn(item) {
      case item {
        [o1, operate, o2, o4]
          if operate == op
          && { o1 == op1 && o2 == op2 || o1 == op2 && o2 == op1 }
        -> {
          True
        }
        _ -> False
      }
    })
  case find {
    Ok(li) -> list.last(li) |> to.unwrap
    Error(_) -> ""
  }
}

// half adder
// X1 XOR Y1 => M1
// X1 AND Y1 => N1
// C0 AND M1 => R1
// C0 XOR M1 -> Z1
// R1 OR N1 -> C1
fn swap(acc, item, moves) {
  let #(current_c, swap_list) = acc
  let xn = "x" <> string.pad_start(item |> int.to_string, 2, "0")
  let yn = "y" <> string.pad_start(item |> int.to_string, 2, "0")
  let m1 = find(xn, yn, "XOR", moves)
  let n1 = find(xn, yn, "AND", moves)
  use <- bool.guard(current_c == "", #(n1, swap_list))
  let r1 = find(current_c, m1, "AND", moves)
  let #(swap_list, n1, m1, r1) = case r1 {
    "" -> {
      #(
        list.append(swap_list, [[m1, n1]]),
        m1,
        n1,
        find(current_c, n1, "AND", moves),
      )
    }
    _ -> #(swap_list, n1, m1, r1)
  }
  let z1 = find(current_c, m1, "XOR", moves)
  let #(swap_list, m1, z1) = case m1 {
    "z" <> _ -> {
      #(list.append(swap_list, [[m1, z1]]), z1, m1)
    }
    _ -> #(swap_list, m1, z1)
  }

  let #(swap_list, n1, z1) = case n1 {
    "z" <> _ -> {
      #(list.append(swap_list, [[n1, z1]]), z1, n1)
    }
    _ -> #(swap_list, n1, z1)
  }

  let #(swap_list, r1, z1) = case r1 {
    "z" <> _ -> #(list.append(swap_list, [[r1, z1]]), z1, r1)
    _ -> #(swap_list, r1, z1)
  }

  let c1 = find(r1, n1, "OR", moves)
  let #(swap_list, c1, z1) = case c1 {
    "z" <> _ if c1 != "z45" -> #(list.append(swap_list, [[c1, z1]]), z1, c1)
    _ -> #(swap_list, c1, z1)
  }
  #(c1, swap_list)
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
  let #(_, swaps_list) =
    list.fold(list.range(0, 44), #("", []), fn(acc, item) {
      swap(acc, item, moves)
    })

  swaps_list
  |> io.debug
  |> list.flatten
  |> list.sort(string.compare)
  |> string.join(",")
  |> io.debug

  1
}
