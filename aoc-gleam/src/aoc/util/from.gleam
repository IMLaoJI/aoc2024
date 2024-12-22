import aoc/util/to
import gleam/dict.{type Dict}
import gleam/list
import gleam/string

pub fn list_of_list_of_ints(input: String, delimiter: String) -> List(List(Int)) {
  input
  |> string.split("\n")
  |> list.map(to.ints(_, delimiter))
}

pub fn grid(
  input: String,
  constructor: fn(Int, Int) -> a,
  parser: fn(String) -> b,
) -> Dict(a, b) {
  {
    use row, r <- list.index_map(string.split(input, "\r\n"))
    use col, c <- list.index_map(string.to_graphemes(row))
    #(constructor(r, c), parser(col))
  }
  |> list.flatten
  |> dict.from_list
}
