import aoc/util/array2d.{type Posn, Posn}
import aoc/util/fun
import gleam/io

import gleam/dict.{type Dict}

import gleam/list

import gleam/string

const vowels = ["a", "e", "i", "o", "u"]

const excludes = ["ab", "cd", "pq", "xy"]

fn is_nice(input: String) {
  let letter =
    input
    |> string.to_graphemes

  let case_one = letter |> list.count(list.contains(vowels, _)) >= 3
  let case_two =
    letter |> list.window_by_2 |> list.count(fn(t) { t.0 == t.1 }) >= 1
  let case_three = list.all(excludes, fn(i) { !string.contains(input, i) })
  case_one && case_two && case_three
}

fn is_repeat(line) {
  case line {
    [c1, c2, ..rest] -> rest |> string.join("") |> string.contains(c1 <> c2)
    _ -> False
  }
}

fn is_sandwich(line) {
  case line {
    [c1, _, c2, ..] -> c1 == c2
    _ -> False
  }
}

pub fn good(s: String) -> Bool {
  let letters = s |> string.to_graphemes
  let tails = fun.tails(letters)
  list.any(tails, is_repeat) && list.any(tails, is_sandwich)
}

fn is_nice_another(input: String) {
  let letter =
    input
    |> string.to_graphemes

  let mid =
    letter
    |> list.index_map(fn(i, idx) { #(idx, i) })
    |> list.window_by_2
  let case_one =
    list.any(mid, fn(i) {
      let #(#(first_idx, first), #(_, second)) = i
      list.any(list.drop(mid, first_idx + 2), fn(t) {
        let #(#(_, next_first), #(_, next_second)) = t
        first <> second == next_first <> next_second
      })
    })
  let case_two =
    letter
    |> list.window(3)
    |> list.any(fn(i) {
      let assert [first, _, third] = i
      first == third
    })
  case_one && case_two
}

pub fn part1(input: String) -> Int {
  input
  |> string.split("\r\n")
  |> list.filter(is_nice)
  |> list.length
}

pub fn part2_another(input: String) -> Int {
  input
  |> string.split("\r\n")
  |> list.filter(is_nice_another)
  |> list.length
}

pub fn part2(input: String) -> Int {
  input
  |> string.split("\r\n")
  |> list.filter(good)
  |> list.length
}
