import aoc/util/array2d

import gleam/dict

import gleam/list

import gleam/result
import gleam/string

fn vadd(v1: #(Int, Int), v2: #(Int, Int)) -> #(Int, Int) {
  #(v1.0 + v2.0, v1.1 + v2.1)
}

fn get_directions() {
  [#(0, 1), #(1, 0), #(1, 1), #(0, -1), #(-1, 0), #(-1, -1), #(-1, 1), #(1, -1)]
}

fn solution_part_one(array, dict) {
  list.fold(list.range(0, list.length(array)), 0, fn(acc, x) {
    list.fold(
      list.range(0, list.length(result.unwrap(list.first(array), []))),
      acc,
      fn(sum, y) {
        list.fold(get_directions(), sum, fn(sub_acc, dir) {
          let acc =
            list.fold(list.range(0, 2), [#(x, y)], fn(acc, _) {
              list.append(acc, [
                vadd(dir, result.unwrap(list.last(acc), #(0, 0))),
              ])
            })
          let str =
            list.map(acc, fn(s) { dict.get(dict, array2d.Posn(s.0, s.1)) })
            |> list.filter(result.is_ok)
            |> list.map(result.unwrap(_, ""))
            |> string.join("")
          case str == "XMAS" {
            True -> sub_acc + 1
            False -> sub_acc
          }
        })
      },
    )
  })
}

fn get_diagonal_char(dict, diagonal: List(#(Int, Int))) {
  diagonal
  |> list.map(fn(t) {
    result.unwrap(dict.get(dict, array2d.Posn(t.0, t.1)), "")
  })
}

fn solution_part_two(array, dict) {
  list.fold(list.range(0, list.length(array)), 0, fn(acc, x) {
    list.fold(
      list.range(0, list.length(result.unwrap(list.first(array), []))),
      acc,
      fn(sum, y) {
        let char = result.unwrap(dict.get(dict, array2d.Posn(x, y)), "")
        let assert [char_lt, char_rb, char_lb, char_rt] =
          get_diagonal_char(dict, [
            #(x - 1, y - 1),
            #(x + 1, y + 1),
            #(x - 1, y + 1),
            #(x + 1, y - 1),
          ])
        let is_diagonal_one =
          { char_lt == "M" && char_rb == "S" }
          || { char_lt == "S" && char_rb == "M" }
        let is_diagonal_two =
          { char_lb == "M" && char_rt == "S" }
          || { char_lb == "S" && char_rt == "M" }
        case char == "A" && is_diagonal_one && is_diagonal_two {
          True -> sum + 1
          False -> sum
        }
      },
    )
  })
}

pub fn part1(input: String) -> Int {
  let res = input |> array2d.to_list_of_lists
  let dict = res |> array2d.to_2d_array
  solution_part_one(res, dict)
}

pub fn part2(input: String) -> Int {
  let res = input |> array2d.to_list_of_lists
  let dict = res |> array2d.to_2d_array
  solution_part_two(res, dict)
}
