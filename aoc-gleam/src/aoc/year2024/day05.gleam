import aoc/util/re
import aoc/util/str
import aoc/util/to.{int}
import gleam/bool
import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/regexp
import gleam/result
import gleam/string

fn is_valid(
  rule: List(String),
  list_group: Dict(String, List(#(String, String))),
) {
  list.index_fold(rule, True, fn(acc, item, idx) {
    let sublist = list.drop(rule, idx + 1)
    acc
    && list.all(sublist, fn(sub) {
      let cur = result.unwrap(dict.get(list_group, sub), [])
      list.any(cur, fn(i) { i.1 == item })
    })
  })
}

fn sort_list(un_order_list, map_group: Dict(String, List(#(String, String)))) {
  un_order_list
  |> list.map(fn(li) {
    list.sort(li, fn(a, b) {
      let cur = result.unwrap(dict.get(map_group, b), [])
      case list.any(cur, fn(i) { i.1 == a }) {
        True -> order.Lt
        False -> order.Gt
      }
    })
  })
}

fn get_middle_value(list) {
  let len = list.length(list)
  let assert [x, ..] = list.drop(list, { len - 1 } / 2)
  int(x)
}

fn parse(line: String) {
  let assert [dirs, rules] = string.split(line, "\r\n\r\n")
  let dirs_str = string.split(dirs, "\r\n")
  let rules_str = string.split(rules, "\r\n")
  let dirs_revert =
    list.map(dirs_str, fn(dir) {
      let assert [from, to] = string.split(dir, "|")
      #(to, from)
    })
  let map_group = list.group(dirs_revert, fn(i) { i.0 })
  let rules = list.map(rules_str, fn(rule) { string.split(rule, ",") })
  #(map_group, rules)
}

pub fn part1(input: String) -> Int {
  let #(map_group, rules) = parse(input)
  rules
  |> list.filter(is_valid(_, map_group))
  |> list.map(get_middle_value)
  |> int.sum
}

pub fn part2(input: String) -> Int {
  let #(map_group, rules) = parse(input)
  rules
  |> list.filter(fn(rule) { !is_valid(rule, map_group) })
  |> sort_list(map_group)
  |> list.map(get_middle_value)
  |> int.sum
}
