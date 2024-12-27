import aoc/util/to
import gleam/list
import gleam/string

fn parse(input: String) {
  input
  |> string.split("\r\n\r\n")
  |> list.fold([[], []], fn(acc, line) {
    let assert [locks, keys] = acc
    let origin =
      line
      |> string.trim
      |> string.split("\n")
      |> list.map(string.trim)
      |> list.map(string.to_graphemes)
    let is_lock =
      origin
      |> list.first
      |> to.unwrap
      |> list.all(fn(c) { c == "#" })
    let pins =
      origin
      |> list.transpose
      |> list.map(fn(item) { list.count(item, fn(c) { c == "#" }) - 1 })
    case is_lock {
      True -> {
        [list.append(locks, [#(list.length(origin), pins)]), keys]
      }
      False -> [locks, list.append(keys, [#(list.length(origin), pins)])]
    }
  })
}

pub fn part1(input: String) -> Int {
  let assert [locks, keys] =
    input
    |> parse

  list.fold(locks, 0, fn(acc, item) {
    list.fold(keys, acc, fn(sub_acc, sub) {
      let is_valid =
        list.zip(item.1, sub.1)
        |> list.map(fn(i) { i.0 + i.1 })
        |> list.all(fn(i) { i < item.0 - 1 })
      case is_valid {
        True -> sub_acc + 1
        False -> sub_acc
      }
    })
  })
}

pub fn part2(input: String) -> Int {
  input
  |> parse
  1
}
