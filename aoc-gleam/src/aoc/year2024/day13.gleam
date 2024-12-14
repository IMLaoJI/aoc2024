import aoc/util/fun
import aoc/util/re
import aoc/util/to
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/regexp.{type Match, Match}

import gleam/string

import gleam/dict.{type Dict}

type ButtonConfig {
  ButtonConfig(x: Int, y: Int, cost: Int)
}

type MachineConfig {
  MachineConfig(
    button_a: ButtonConfig,
    button_b: ButtonConfig,
    prize_x: Int,
    prize_y: Int,
  )
}

fn get_number(str) {
  let regex_str = re.from_string("(\\d+)")
  list.fold(regexp.scan(regex_str, str), [], fn(sumal, match) {
    let assert Match(submatches: [Some(left)], ..) = match
    list.append(sumal, [to.int(left)])
  })
}

fn parse(input) {
  input
  |> string.split("\r\n\r\n")
  |> list.map(fn(st) {
    let assert [config_a, config_b, prize, ..] = string.split(st, "\r\n")
    let res1 = get_number(config_a)
    let res2 = get_number(config_b)
    let res3 = get_number(prize)

    MachineConfig(
      button_a: ButtonConfig(
        x: to.unwrap(fun.get_at(res1, 0)),
        y: to.unwrap(fun.get_at(res1, 1)),
        cost: 3,
      ),
      button_b: ButtonConfig(
        x: to.unwrap(fun.get_at(res2, 0)),
        y: to.unwrap(fun.get_at(res2, 1)),
        cost: 1,
      ),
      prize_x: to.unwrap(fun.get_at(res3, 0)),
      prize_y: to.unwrap(fun.get_at(res3, 1)),
    )
  })
  |> io.debug
}

// Function to find the minimum number of tokens needed for a single machine
fn min_tokens_for_machine(config: MachineConfig) {
  let ButtonConfig(ax, ay, acost) = config.button_a
  let ButtonConfig(bx, by, bcost) = config.button_b
  let d = { ay * config.prize_x - ax * config.prize_y } / { bx * ay - by * ax }
  let c = { config.prize_x - d * bx } / ax
  case
    #(c * ax + d * bx, c * ay + d * by) == #(config.prize_x, config.prize_y)
  {
    True -> Ok(acost * c + bcost * d)
    False -> Error(Nil)
  }
}

pub fn part1(input: String) -> Int {
  input
  |> parse
  |> list.filter_map(min_tokens_for_machine)
  |> int.sum
}

pub fn part2(input: String) -> Int {
  let offset = 10_000_000_000_000
  input
  |> parse
  |> list.map(fn(machine) {
    MachineConfig(
      ..machine,
      prize_x: machine.prize_x + offset,
      prize_y: machine.prize_y + offset,
    )
  })
  |> list.filter_map(min_tokens_for_machine)
  |> int.sum
}
