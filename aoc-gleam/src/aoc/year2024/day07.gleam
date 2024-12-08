import aoc/util/str
import aoc/util/to
import gleam/int
import gleam/list
import gleam/string

fn parse_line(line: String) {
  let assert [first, num] =
    line
    |> string.trim
    |> string.split(":")
  to.int(first)
  let rules =
    num
    |> string.trim
    |> to.ints(" ")
  #(to.int(first), rules)
}

fn concatenate(a: Int, b: Int) -> Int {
  let assert Ok(a_digits) = int.digits(a, 10)
  let assert Ok(b_digits) = int.digits(b, 10)
  let assert Ok(result) = list.append(a_digits, b_digits) |> int.undigits(10)
  result
}

pub type Op {
  Add
  Multiply
  Concatenate
}

fn do_op(op, a, b) {
  case op {
    Add -> a + b
    Multiply -> a * b
    Concatenate -> concatenate(a, b)
  }
}

fn check_problem(problem, ops: List(Op)) -> Result(Int, Nil) {
  case problem {
    #(answer, [a]) if a == answer -> Ok(a)
    #(answer, [a, b, ..rest]) -> {
      list.find_map(ops, fn(op) {
        let parts = [do_op(op, a, b), ..rest]
        check_problem(#(answer, parts), ops)
      })
    }
    _ -> Error(Nil)
  }
}

fn add_up_true_equations(input, operators) {
  use acc, problem <- list.fold(input, 0)
  case check_problem(problem, operators) {
    Ok(n) -> n + acc
    _ -> acc
  }
}

pub fn part1(input: String) -> Int {
  let problems =
    input
    |> str.lines
    |> list.map(parse_line)
  add_up_true_equations(problems, [Add, Multiply])
}

pub fn part2(input: String) -> Int {
  let problems =
    input
    |> str.lines
    |> list.map(parse_line)
  add_up_true_equations(problems, [Add, Multiply, Concatenate])
}
