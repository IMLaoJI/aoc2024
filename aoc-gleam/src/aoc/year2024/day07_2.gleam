import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn parse(input: String) -> List(#(Int, List(Int))) {
  let assert Ok(data) = {
    use line <- list.try_map(string.split(input, "\r\n"))
    use #(test_val, args) <- result.try(string.split_once(line, ": "))
    use test_val <- result.try(int.parse(test_val))
    use vals <- result.try(list.try_map(string.split(args, " "), int.parse))
    Ok(#(test_val, vals))
  }

  data
}

fn concat(front: Int, back: Int) -> Int {
  let assert Ok(front) = int.digits(front, 10)
  let assert Ok(back) = int.digits(back, 10)
  let assert Ok(smushed) = list.flatten([front, back]) |> int.undigits(10)
  smushed
}

fn do(input, acc, test_val, ops) -> Bool {
  case input {
    [] -> acc == test_val
    [x, ..xs] -> {
      list.any(ops, fn(op) { do(xs, op(acc, x), test_val, ops) })
    }
  }
}

pub fn part1(input: String) -> Int {
  use acc, #(test_val, args) <- list.fold(input |> parse, 0)
  let assert [first, ..rest] = args

  case do(rest, first, test_val, [int.add, int.multiply]) {
    True -> acc + test_val
    False -> acc
  }
}

pub fn part2(input: String) -> Int {
  use acc, #(test_val, args) <- list.fold(input |> parse, 0)
  let assert [first, ..rest] = args
  case do(rest, first, test_val, [int.add, int.multiply, concat]) {
    True -> acc + test_val
    False -> acc
  }
}
