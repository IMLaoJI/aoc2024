import aoc/util/array2d.{type Posn, Posn}
import aoc/util/to
import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/list
import gleam/result
import gleam/string

type Op {
  AND(left: String, right: String, fun: fn(Int, Int) -> Int)
  OR(left: String, right: String, fun: fn(Int, Int) -> Int)
  LSHIFT(left: String, right: Int, fun: fn(Int, Int) -> Int)
  RSHIFT(left: String, right: Int, fun: fn(Int, Int) -> Int)
  NOT(left: String, fun: fn(Int) -> Int)
  NOTHING(left: String)
}

fn get_dict_value(keys: List(String), current_dict) {
  list.map(keys, fn(key) {
    case int.parse(key) {
      Ok(num) -> num
      Error(_) -> {
        let assert Ok(value) = dict.get(current_dict, key)
        value
      }
    }
  })
}

fn get_dict_value_check(keys: List(String), current_dict) {
  list.try_map(keys, fn(key) {
    case int.parse(key) {
      Ok(num) -> Ok(num)
      Error(_) -> {
        dict.get(current_dict, key)
      }
    }
  })
}

fn operator(current_dict, operator: Operator) {
  case operator.op {
    AND(left, right, fun) | OR(left, right, fun) -> {
      let assert [l, r] = get_dict_value([left, right], current_dict)
      dict.insert(current_dict, operator.end, fun(l, r))
    }
    LSHIFT(left, right, fun) | RSHIFT(left, right, fun) -> {
      let assert [l] = get_dict_value([left], current_dict)
      dict.insert(current_dict, operator.end, fun(l, right))
    }
    NOT(left, fun) -> {
      let assert [l] = get_dict_value([left], current_dict)
      dict.insert(
        current_dict,
        operator.end,
        { result.unwrap(int.power(2, 16.0), 0.0) |> float.truncate } + fun(l),
      )
    }
    NOTHING(left) -> {
      let assert [l] = get_dict_value([left], current_dict)
      dict.insert(current_dict, operator.end, l)
    }
  }
}

type Operator {
  Operator(op: Op, end: String)
}

type Config {
  Config(ops: List(Operator), map: Dict(String, Int))
}

fn parse(input: String) {
  let #(ops, dict) =
    input
    |> string.split("\r\n")
    |> list.fold(#([], dict.new()), fn(acc, line) {
      let #(ops, current_dict) = acc
      let assert Ok(#(first, second)) = line |> string.split_once(" -> ")
      case first |> string.split(" ") {
        [number] -> {
          case int.parse(number) {
            Ok(num) -> #(ops, dict.insert(current_dict, second, num))
            Error(_) -> #(
              [Operator(NOTHING(number), end: second), ..ops],
              current_dict,
            )
          }
        }
        [left, op, right] if op == "AND" -> #(
          [Operator(AND(left, right, int.bitwise_and), end: second), ..ops],
          current_dict,
        )
        [left, op, right] if op == "OR" -> #(
          [Operator(OR(left, right, int.bitwise_or), end: second), ..ops],
          current_dict,
        )
        [left, op, right] if op == "LSHIFT" -> #(
          [
            Operator(
              LSHIFT(left, right |> to.int, int.bitwise_shift_left),
              end: second,
            ),
            ..ops
          ],
          current_dict,
        )
        [left, op, right] if op == "RSHIFT" -> #(
          [
            Operator(
              RSHIFT(left, right |> to.int, int.bitwise_shift_right),
              end: second,
            ),
            ..ops
          ],
          current_dict,
        )
        [op, left] if op == "NOT" -> #(
          [Operator(NOT(left, int.bitwise_not), end: second), ..ops],
          current_dict,
        )
        _ -> panic
      }
    })
  Config(ops, dict)
}

fn execute(todo_moves: List(Operator), current_dict) {
  case todo_moves {
    [] -> {
      current_dict
    }
    _ -> {
      let new_do =
        todo_moves
        |> list.group(by: fn(operator) {
          let is_exist = case operator.op {
            AND(left, right, _) | OR(left, right, _) -> {
              get_dict_value_check([left, right], current_dict)
            }
            LSHIFT(left, _, _) | RSHIFT(left, _, _) -> {
              get_dict_value_check([left], current_dict)
            }
            NOT(left, _) -> {
              get_dict_value_check([left], current_dict)
            }
            NOTHING(left) -> {
              get_dict_value_check([left], current_dict)
            }
          }
          case is_exist {
            Error(_) -> {
              "false"
            }
            _ -> {
              "true"
            }
          }
        })
      let todo_d = new_do |> dict.get("false")
      let todo_ok = new_do |> dict.get("true") |> result.unwrap([])
      case todo_d {
        Ok([]) -> current_dict
        Ok(rest) -> {
          let new_config = excute_one(todo_ok, current_dict)
          execute(rest, new_config)
        }
        _ -> {
          let new_config = excute_one(todo_ok, current_dict)
          new_config
        }
      }
    }
  }
}

fn excute_one(ops, map) {
  list.fold(ops, map, operator)
}

pub fn part1(input: String) -> Int {
  let Config(ops, map) =
    input
    |> parse
  execute(ops, map)
  |> dict.get("a")
  |> result.unwrap(0)
}

pub fn part2(input: String) -> Int {
  let Config(ops, map) =
    input
    |> parse
  let new_map =
    execute(ops, map)
    |> dict.get("a")
    |> result.unwrap(0)
    |> dict.insert(map, "b", _)
  let new_map =
    dict.map_values(new_map, fn(key, value) {
      case key {
        "b" -> value
        _ -> 0
      }
    })
  execute(ops, new_map)
  |> dict.get("a")
  |> result.unwrap(0)
}
