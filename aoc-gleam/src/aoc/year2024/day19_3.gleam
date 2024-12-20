import gleam/int
import gleam/io
import gleam/list
import gleam/string

fn parse(input) {
  let assert [first, second] = input |> string.split("\r\n\r\n")
  let towels = string.split(first, ", ")
  let designs = string.split(second, "\r\n")
  #(towels, designs)
}

pub fn part1(input: String) -> Int {
  let #(towels, designs) = parse(input)
  {
    use design <- list.flat_map(designs)
    list.fold(list.range(1, string.length(design)), [], fn(acc, item) {
      list.append(acc, [string.slice(design, 0, item)])
    })
  }
  |> list.sort(fn(a, b) { int.compare(string.length(a), string.length(b)) })
  |> io.debug
  1
}

pub fn part2(input: String) -> Int {
  1
}
