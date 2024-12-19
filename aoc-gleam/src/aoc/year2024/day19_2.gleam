import aoc/util/to
import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/result

import gleam/list
import gleam/string

fn parse(input) {
  let assert [first, second] = input |> string.split("\r\n\r\n")
  let towels = string.split(first, ", ")
  let designs = string.split(second, "\r\n")
  #(towels, designs)
}

fn can_make(
  design,
  towels,
  start,
  cache,
) -> #(Int, dict.Dict(#(String, Int), Int)) {
  let has_cache = dict.get(cache, #(design, start))
  use <- bool.lazy_guard(result.is_ok(has_cache), fn() {
    #(to.unwrap(has_cache), cache)
  })
  let current = string.drop_start(design, start)
  use <- bool.guard(current == "", #(1, dict.insert(cache, #(design, start), 1)))
  let valid = list.filter(towels, fn(p) { string.starts_with(current, p) })
  case valid {
    [] -> #(0, dict.insert(cache, #(design, start), 0))
    _ -> {
      let a = {
        list.fold(valid, 0, fn(acc, item) {
          acc + can_make(design, towels, start + string.length(item), cache).0
        })
      }
      #(a, dict.insert(cache, #(design, start), a))
    }
  }
}

fn count_made_designs(towels, designs) {
  list.map(designs, fn(design) { can_make(design, towels, 0, dict.new()) })
}

pub fn part1(input: String) -> Int {
  let #(towels, designs) = input |> parse
  count_made_designs(towels, designs)
  |> list.count(fn(p) { p.0 != 0 })
}

pub fn part2(input: String) -> Int {
  let #(towels, designs) = input |> parse
  count_made_designs(towels, designs)
  |> list.fold(0, fn(acc, p) { int.add(acc, p.0) })
}
