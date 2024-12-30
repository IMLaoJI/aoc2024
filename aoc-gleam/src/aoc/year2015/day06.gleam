import aoc/util/array2d.{type Posn, Posn}
import aoc/util/to
import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/regexp
import gleam/string

type OpType {
  Toggle
  On
  Off
}

type Op {
  Op(op_type: OpType, begin: #(Int, Int), end: #(Int, Int))
}

fn parse(input: String) {
  input
  |> string.split("\r\n")
  |> list.map(fn(line) {
    let assert Ok(register_re) =
      regexp.from_string("(.+) (\\d+,\\d+) .* (\\d+,\\d+)")
    let assert [
      regexp.Match(
        submatches: [option.Some(op_type), option.Some(begin), option.Some(end)],
        ..,
      ),
    ] = regexp.scan(register_re, line)
    let op_type = case op_type {
      "toggle" -> Toggle
      "turn on" -> On
      "turn off" -> Off
      _ -> panic
    }
    Op(
      op_type,
      to.ints(begin, ",") |> to.list_tuple,
      to.ints(end, ",") |> to.list_tuple,
    )
  })
}

fn common_change_light(op: Op, dict, status, is_toggle) {
  let #(start_r, start_c) = op.begin
  let #(end_r, end_c) = op.end
  use acc_dict, i <- list.fold(list.range(start_r, end_r), dict)
  use sub_acc_dict, j <- list.fold(list.range(start_c, end_c), acc_dict)
  case is_toggle {
    True -> {
      dict.insert(
        sub_acc_dict,
        Posn(i, j),
        !to.unwrap(dict.get(sub_acc_dict, Posn(i, j))),
      )
    }
    False -> dict.insert(sub_acc_dict, Posn(i, j), status)
  }
}

fn toggle_light(op: Op, dict) {
  common_change_light(op, dict, False, True)
}

fn change_light(op: Op, dict, status) {
  common_change_light(op, dict, status, False)
}

fn common_change_light_part2(op: Op, current_dict, number) {
  let #(start_r, start_c) = op.begin
  let #(end_r, end_c) = op.end
  use acc_dict, i <- list.fold(list.range(start_r, end_r), current_dict)
  use sub_acc_dict, j <- list.fold(list.range(start_c, end_c), acc_dict)
  let assert Ok(current) = dict.get(sub_acc_dict, Posn(i, j))
  dict.insert(sub_acc_dict, Posn(i, j), case current, number {
    0, num if num < 0 -> 0
    _, _ -> current + number
  })
}

pub fn part1(input: String) -> Int {
  let ops =
    input
    |> parse

  let dict =
    list.fold(list.range(1, 1000), [], fn(acc, _) {
      list.append(acc, [list.repeat(False, 1000)])
    })
    |> array2d.to_2d_array
  list.fold(ops, dict, fn(acc, op) {
    case op.op_type {
      Toggle -> toggle_light(op, acc)
      On -> change_light(op, acc, True)
      Off -> change_light(op, acc, False)
    }
  })
  |> dict.filter(fn(_, value) { value == True })
  |> dict.size
}

pub fn part2(input: String) -> Int {
  let ops =
    input
    |> parse

  let dict =
    list.fold(list.range(1, 1000), [], fn(acc, _) {
      list.append(acc, [list.repeat(0, 1000)])
    })
    |> array2d.to_2d_array
  list.fold(ops, dict, fn(acc, op) {
    case op.op_type {
      Toggle -> common_change_light_part2(op, acc, 2)
      On -> common_change_light_part2(op, acc, 1)
      Off -> common_change_light_part2(op, acc, -1)
    }
  })
  |> dict.values
  |> list.fold(0, int.add)
}
