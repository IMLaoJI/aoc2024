import aoc/year2024/day01
import aoc/year2024/day01_2
import aoc/year2024/day02
import aoc/year2024/day03
import aoc/year2024/day03_2
import aoc/year2024/day03_3
import gleam/string

pub fn run(input: String, day: Int, part: Int) {
  case day, part {
    1, 1 -> input |> day01.part1 |> string.inspect
    1, 2 -> input |> day01.part2 |> string.inspect
    1, 11 -> input |> day01_2.part1 |> string.inspect
    1, 22 -> input |> day01_2.part2 |> string.inspect
    2, 1 -> input |> day02.part1 |> string.inspect
    2, 2 -> input |> day02.part2 |> string.inspect
    3, 1 -> input |> day03.part1 |> string.inspect
    3, 2 -> input |> day03.part2 |> string.inspect
    3, 11 -> input |> day03_2.part1 |> string.inspect
    3, 22 -> input |> day03_2.part2 |> string.inspect
    3, 111 -> input |> day03_3.part1 |> string.inspect
    3, 222 -> input |> day03_3.part2 |> string.inspect
    _, _ ->
      "Unknown day and part for 2024: day "
      <> string.inspect(day)
      <> ", part "
      <> string.inspect(part)
  }
}
