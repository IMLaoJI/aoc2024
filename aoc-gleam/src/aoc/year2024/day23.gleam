import aoc/util/to
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string

fn parse(input: String) {
  input
  |> string.split("\r\n")
  |> list.fold(dict.new(), fn(acc, p) {
    let assert Ok(#(first, second)) = string.split_once(p, "-")
    dict.insert(acc, first <> second, first)
    |> dict.insert(second <> first, second)
  })
}

pub fn part1(input: String) -> Int {
  let input_dict =
    input
    |> parse
  dict.values(input_dict)
  |> list.unique
  |> list.combinations(3)
  |> list.filter(fn(p) {
    list.combinations(p, 2)
    |> list.all(fn(sub) {
      let assert [first, second] = sub
      dict.has_key(input_dict, first <> second)
    })
  })
  |> list.map(fn(p) { list.sort(p, string.compare) })
  |> list.unique
  |> list.filter(fn(p) { list.any(p, fn(sub) { string.starts_with(sub, "t") }) })
  |> io.debug
  |> list.length
}

fn max_clique(clique, rem, edges) {
  case rem {
    [] -> clique
    [h, ..rest] -> {
      case list.all(clique, fn(p) { list.contains(edges, p <> h) }) {
        True -> max_clique(list.prepend(clique, h), rest, edges)
        False -> max_clique(clique, rest, edges)
      }
    }
  }
}

pub fn part2(input: String) -> Int {
  let input_dict =
    input
    |> parse
  let vertices =
    dict.values(input_dict)
    |> list.unique

  vertices
  |> list.map(fn(v) { max_clique([v], vertices, dict.keys(input_dict)) })
  |> list.sort(fn(a, b) { int.compare(list.length(b), list.length(a)) })
  |> list.first
  |> to.unwrap
  |> list.sort(string.compare)
  |> string.join(",")
  1
}
