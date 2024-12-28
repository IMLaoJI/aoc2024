import aoc/year2015/day01
import aoc/year2015/day02
import aoc/year2015/day03
import aoc/year2015/day04
import gleam/string

pub fn run(input: String, day: Int, part: Int) {
  case day, part {
    1, 1 -> input |> day01.part1 |> string.inspect
    1, 2 -> input |> day01.part2 |> string.inspect
    2, 1 -> input |> day02.part1 |> string.inspect
    2, 2 -> input |> day02.part2 |> string.inspect
    3, 1 -> input |> day03.part1 |> string.inspect
    3, 2 -> input |> day03.part2 |> string.inspect
    4, 1 -> input |> day04.part1 |> string.inspect
    4, 2 -> input |> day04.part2 |> string.inspect
    _, _ ->
      "Unknown day and part for 2023: day "
      <> string.inspect(day)
      <> ", part "
      <> string.inspect(part)
  }
}