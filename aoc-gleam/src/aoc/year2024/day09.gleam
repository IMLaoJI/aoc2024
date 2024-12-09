import aoc/util/str
import aoc/util/to
import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/result
import gleam/set
import gleam/string

fn parse_line(line: String) {
  line
}

fn is_have_gap(row) {
  let li = list.drop_while(row, fn(p) { p != "." })
  list.length(li) != list.count(row, fn(p) { p == "." })
}

fn is_over(find_dict, row, visited) {
  set.size(visited) == dict.size(find_dict)
}

fn replace(row) {
  case is_have_gap(row) {
    True -> {
      let assert Ok(last) = list.last(row)
      let new_row = case last != "." {
        True -> {
          io.debug(last)
          let new_row =
            list.take_while(row, fn(p) { p != "." })
            |> list.append([last])
            |> list.append(
              to.unwrap(list.rest(list.drop_while(row, fn(p) { p != "." }))),
            )
          list.reverse(to.unwrap(list.rest(list.reverse(new_row))))
        }
        False -> list.reverse(to.unwrap(list.rest(list.reverse(row))))
      }
      replace(new_row)
    }
    False -> row
  }
}

fn replace_2(row, visited, valid_idx) {
  let #(find_dict, freq_list) = group(row)
  let assert Ok(last) = list.last(list.take(row, valid_idx + 3))
  case !is_over(find_dict, row, visited) && valid_idx > 0 {
    True -> {
      let assert Ok(last) = list.last(list.take(row, valid_idx + 1))
      let is_number = result.is_ok(int.parse(last))
      let #(new_row, new_valid_idx) = case
        last != "." && !set.contains(visited, last)
      {
        True -> {
          let number_size = list.length(to.unwrap(dict.get(find_dict, last)))
          let find_element =
            list.find(freq_list, fn(p) {
              valid_idx >= p.0 && p.1 >= number_size
            })
          case find_element {
            Ok(nu) -> {
              let new_row =
                list.take(row, nu.0)
                |> list.append(list.repeat(last, number_size))
                |> list.append(
                  to.unwrap(list.rest(list.drop(row, nu.0 + number_size - 1))),
                )
              let new_row =
                list.take(new_row, valid_idx - number_size + 1)
                |> list.append(list.repeat(".", number_size))
                |> list.append(list.drop(new_row, valid_idx + 1))
              #(new_row, valid_idx - number_size)
            }
            Error(_) -> {
              #(row, valid_idx - number_size)
            }
          }
        }
        False -> {
          io.debug(valid_idx - 1)
          // case list.find(freq_list, fn(p) { { p.0 + p.1 } > valid_idx }) {
          //   Ok(idx) -> {
          //     #(row, idx.0 - 1)
          //   }
          //   Error(_) -> {
          //     #(row, valid_idx - 1)
          //   }
          // }
          #(row, valid_idx - 1)
        }
      }
      case is_number {
        True -> {
          replace_2(new_row, set.insert(visited, last), new_valid_idx)
        }
        False -> {
          replace_2(new_row, visited, new_valid_idx)
        }
      }
    }
    False -> row
  }
}

fn group(input) {
  let find_dict =
    input
    |> list.filter(fn(p) { p != "." })
    |> list.group(fn(p) { p })

  let #(is_dot, deal_dict, dot_idx, dot_num) =
    list.index_fold(input, #(False, dict.new(), -1, 0), fn(acc, item, idx) {
      let #(is_dot, deal_dict, dot_idx, dot_num) = acc
      let is_number = result.is_ok(int.parse(item))
      case item, is_dot {
        ".", False -> {
          #(True, deal_dict, idx, dot_num + 1)
        }
        _, True if is_number -> {
          #(False, dict.insert(deal_dict, dot_idx, dot_num), idx, 0)
        }
        _, True -> {
          #(True, deal_dict, dot_idx, dot_num + 1)
        }
        _, _ -> {
          #(is_dot, deal_dict, idx, dot_num)
        }
      }
    })

  let freq_list =
    deal_dict
    |> dict.to_list
    |> list.sort(fn(a, b) { int.compare(a.0, b.0) })
  #(find_dict, freq_list)
}

fn parse(line: String) {
  let a =
    line
    |> string.to_graphemes
    |> list.filter_map(int.parse)
    |> list.index_fold([], fn(acc, item, idx) {
      case int.is_even(idx) || idx == 0 {
        True if idx == 0 -> {
          list.append(acc, list.repeat(int.to_string(idx), item))
        }
        True if idx != 0 -> {
          list.append(acc, list.repeat(int.to_string(idx / 2), item))
        }
        False -> {
          list.append(acc, list.repeat(".", item))
        }
        _ -> {
          acc
        }
      }
    })
  a
}

pub fn part1(input: String) -> Int {
  input
  |> parse
  |> replace
  |> list.filter(fn(p) { p != "." })
  |> list.index_fold(0, fn(acc, item, idx) { acc + { to.int(item) * idx } })
  1
}

pub fn part2(input: String) -> Int {
  let parse_input =
    input
    |> parse

  replace_2(parse_input, set.new(), list.length(parse_input) - 1)
  |> list.index_fold(0, fn(acc, item, idx) {
    case int.parse(item) {
      Ok(nu) -> acc + { nu * idx }
      _ -> acc
    }
  })
}
