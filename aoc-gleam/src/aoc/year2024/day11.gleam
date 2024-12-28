import aoc/util/to
import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/string

fn parse(input) {
  let parse =
    input
    |> string.trim
    |> string.split(" ")
    |> list.map(string.split(_, ""))
  dict.map_values(list.group(parse, fn(n) { n }), fn(_, b) { list.length(b) })
}

fn split(num) {
  #(
    list.take(num, list.length(num) / 2),
    list.drop_while(list.drop(num, list.length(num) / 2), fn(n) { n == "0" }),
  )
}

fn blick(cache_dict) {
  dict.fold(cache_dict, dict.new(), fn(acc_dict, item, value) {
    let is_odd = int.is_odd(list.length(item))
    let first = to.unwrap(list.first(item))
    case is_odd {
      True if first == "0" -> {
        dict.upsert(acc_dict, ["1"], fn(x) {
          case x {
            Some(i) -> i + value
            None -> value
          }
        })
      }
      True -> {
        dict.upsert(
          acc_dict,
          string.split(int.to_string(to.int(string.join(item, "")) * 2024), ""),
          fn(x) {
            case x {
              Some(i) -> i + value
              None -> value
            }
          },
        )
      }
      False -> {
        let #(pre, la) = split(item)
        let la = case la {
          [] -> ["0"]
          _ -> la
        }
        let di =
          dict.upsert(acc_dict, pre, fn(x) {
            case x {
              Some(i) -> i + value
              None -> value
            }
          })
        dict.upsert(di, la, fn(x) {
          case x {
            Some(i) -> i + value
            None -> value
          }
        })
      }
    }
  })
}

pub fn part1(input: String) -> Int {
  let cache_dict =
    input
    |> parse
  list.fold(list.range(0, 24), cache_dict, fn(acc, _) { { blick(acc) } })
  |> dict.values
  |> int.sum
}

pub fn part2(input: String) -> Int {
  let cache_dict =
    input
    |> parse
  list.fold(list.range(0, 74), cache_dict, fn(acc, _) { { blick(acc) } })
  |> dict.values
  |> int.sum
}
