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
    Ok(#(test_val, list.reverse(vals)))
  }

  data
}

fn do(input, acc, test_val, ops) -> Bool {
  case input {
    [] -> acc == test_val
    [x, ..xs] -> {
      list.any(ops, fn(op) { do(xs, op(acc, x), test_val, ops) })
    }
  }
}

fn is_solvable1(result: Int, numbers) {
  case numbers {
    [] -> {
      result == 0
    }
    [first, ..numbers] -> {
      let fraction = result / first
      { result >= first && is_solvable1(result - first, numbers) }
      || { fraction * first == result && is_solvable1(fraction, numbers) }
    }
  }
}

pub fn part1(input: String) -> Int {
  use acc, #(test_val, args) <- list.fold(input |> parse, 0)
  case is_solvable1(test_val, args) {
    True -> {
      acc + test_val
    }
    False -> acc
  }
}

pub fn part2(input: String) -> Int {
  use acc, #(test_val, args) <- list.fold(input |> parse, 0)
  case is_solvable2(test_val, args) {
    True -> {
      acc + test_val
    }
    False -> acc
  }
}

fn is_solvable2(result: Int, numbers) {
  case numbers {
    [] -> result == 0
    [first, ..numbers] if result >= first -> {
      { result >= first && is_solvable2(result - first, numbers) }
      || {
        let fraction = result / first
        fraction * first == result && is_solvable2(fraction, numbers)
      }
      || {
        let pow10 = to_pow10(first)
        let next = { result - first } / pow10
        next * pow10 + first == result && is_solvable2(next, numbers)
      }
    }
    _ -> False
  }
}

fn to_pow10(number) {
  case number >= 10 {
    True -> 10 * to_pow10(number / 10)
    False -> 10
  }
}
