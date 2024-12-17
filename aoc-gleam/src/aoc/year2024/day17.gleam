import aoc/util/fun
import aoc/util/re
import aoc/util/to
import gleam/bool
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regexp.{type Match, Match}
import gleam/result
import gleam/string

type Config {
  Config(a: Int, b: Int, c: Int, propgram: List(Int))
}

fn get_number(str) {
  get_numbers(str)
  |> list.first
  |> to.unwrap
}

fn get_numbers(str) {
  let regex_str = re.from_string("(\\d+)")
  list.fold(regexp.scan(regex_str, str), [], fn(sumal, match) {
    let assert Match(submatches: [Some(left)], ..) = match
    list.append(sumal, [to.int(left)])
  })
}

fn parse(input) {
  let assert [first, second] =
    input
    |> string.split("\r\n\r\n")
  let assert [config_a, config_b, config_c] = string.split(first, "\r\n")
  let a = get_number(config_a)
  let b = get_number(config_b)
  let c = get_number(config_c)
  let program = get_numbers(second)
  Config(a, b, c, program)
}

fn get_operand_value(operand, config: Config) {
  case operand {
    _ if operand < 4 -> operand
    4 -> config.a
    5 -> config.b
    6 -> config.c
    _ -> panic
  }
}

fn mod(first, second) {
  { { first % second } + second } % second
}

fn do(
  directions: List(List(Int)),
  total_directions: List(List(Int)),
  config: Config,
  out: List(Int),
) {
  let next_do = fn(new_config) {
    do(
      result.unwrap(list.rest(directions), []),
      total_directions,
      new_config,
      out,
    )
  }
  case list.is_empty(directions) {
    True -> out
    False -> {
      // io.debug(#(directions, config, out))
      let assert Ok(direction) = list.first(directions)
      let assert Ok(opcode) = list.first(direction)
      let assert Ok(operand) = list.last(direction)
      case opcode {
        0 -> {
          let assert Ok(divisor) =
            int.power(2, int.to_float(get_operand_value(operand, config)))
          next_do(
            Config(
              ..config,
              a: to.unwrap(int.floor_divide(config.a, float.round(divisor))),
            ),
          )
        }
        1 -> {
          next_do(
            Config(..config, b: int.bitwise_exclusive_or(config.b, operand)),
          )
        }
        2 -> {
          next_do(
            Config(..config, b: mod(get_operand_value(operand, config), 8)),
          )
        }
        3 -> {
          case config.a == 0 {
            True -> {
              next_do(config)
            }
            False -> {
              do(total_directions, total_directions, config, out)
            }
          }
        }
        4 -> {
          next_do(
            Config(..config, b: int.bitwise_exclusive_or(config.b, config.c)),
          )
        }
        5 -> {
          do(
            result.unwrap(list.rest(directions), []),
            total_directions,
            config,
            list.append(out, [mod(get_operand_value(operand, config), 8)]),
          )
        }
        6 -> {
          let assert Ok(divisor) =
            int.power(2, int.to_float(get_operand_value(operand, config)))
          next_do(
            Config(
              ..config,
              b: to.unwrap(int.floor_divide(config.a, float.round(divisor))),
            ),
          )
        }
        7 -> {
          let assert Ok(divisor) =
            int.power(2, int.to_float(get_operand_value(operand, config)))
          next_do(
            Config(
              ..config,
              c: to.unwrap(int.floor_divide(config.a, float.round(divisor))),
            ),
          )
        }
        _ -> panic
      }
    }
  }
}

pub fn part1(input: String) -> Int {
  let config =
    input
    |> parse

  let dirs =
    config.propgram
    |> list.sized_chunk(2)

  do(dirs, dirs, config, [])
  // |> io.debug
  |> list.map(int.to_string)
  |> string.join(",")
  |> io.debug

  1
}

//   Based on the program:
//   B = A & 7
//   B = B ^ 7
//   C = A // 2**B
//   B = B ^ C
//   B = B ^ 4
//   A = A // 8
//   OUT(B & 7)
//   jnz A 0
fn encode(num, i, program, res) {
  use <- bool.guard(i < 0, res)
  let val = to.unwrap(fun.get_at(program, i))
  list.flat_map(list.range(0, 7), fn(p) {
    let new_num = 8 * num + p
    let b = int.bitwise_exclusive_or(p, 7)
    let assert Ok(divisor) = int.power(2, int.to_float(b))
    let c = to.unwrap(int.floor_divide(new_num, float.round(divisor)))
    let b = int.bitwise_exclusive_or(b, c)
    let b = int.bitwise_exclusive_or(b, 4)
    case mod(b, 8) == val {
      True -> {
        case i == 0 {
          True -> {
            list.append(res, [new_num])
          }
          False -> {
            encode(new_num, i - 1, program, res)
          }
        }
      }
      False -> res
    }
  })
}

pub fn part2(input: String) -> Int {
  let config =
    input
    |> parse

  encode(0, list.length(config.propgram) - 1, config.propgram, [])
  |> list.first
  |> to.unwrap
}
