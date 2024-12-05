import gleam/int
import gleam/list
import gleam/string

pub fn unwrap(result: Result(a, b)) -> a {
  let assert Ok(x) = result
  x
}

pub fn int(str: String) -> Int {
  unwrap(int.parse(str))
}

pub fn delimited_list(
  str: String,
  split_on delimiter: String,
  using f: fn(String) -> a,
) -> List(a) {
  str |> string.split(delimiter) |> list.map(f)
}

pub fn ints(str: String, split_on delimiter: String) -> List(Int) {
  delimited_list(str, delimiter, int)
}
