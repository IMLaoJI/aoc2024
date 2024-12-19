import gleam/bool
import gleam/int

import gleam/list
import gleam/string
import rememo/memo

fn parse(input) {
  let assert [first, second] = input |> string.split("\r\n\r\n")
  let towels = string.split(first, ", ")
  let designs = string.split(second, "\r\n")
  #(towels, designs)
}

fn can_make(design, towels, start, cache) {
  use <- memo.memoize(cache, #(design, start))
  let current = string.drop_start(design, start)
  use <- bool.guard(current == "", 1)
  let valid = list.filter(towels, fn(p) { string.starts_with(current, p) })
  case valid {
    [] -> 0
    _ -> {
      list.fold(valid, 0, fn(acc, item) {
        acc + can_make(design, towels, start + string.length(item), cache)
      })
    }
  }
}

fn count_made_designs(towels, designs) {
  use cache <- memo.create()
  list.map(designs, fn(design) { can_make(design, towels, 0, cache) })
}

pub fn part1(input: String) -> Int {
  let #(towels, designs) = input |> parse
  count_made_designs(towels, designs)
  |> list.count(fn(p) { p != 0 })
}

pub fn part2(input: String) -> Int {
  let #(towels, designs) = input |> parse
  count_made_designs(towels, designs)
  |> list.fold(0, int.add)
}
