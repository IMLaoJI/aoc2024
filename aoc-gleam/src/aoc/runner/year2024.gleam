import aoc/year2024/day01
import aoc/year2024/day01_2
import aoc/year2024/day02
import aoc/year2024/day03
import aoc/year2024/day03_2
import aoc/year2024/day03_3
import aoc/year2024/day04
import aoc/year2024/day04_2
import aoc/year2024/day04_3
import aoc/year2024/day05
import aoc/year2024/day06
import aoc/year2024/day06_2
import aoc/year2024/day07
import aoc/year2024/day07_2
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
    4, 1 -> input |> day04.part1 |> string.inspect
    4, 2 -> input |> day04.part2 |> string.inspect
    4, 11 -> input |> day04_2.part1 |> string.inspect
    4, 22 -> input |> day04_2.part2 |> string.inspect
    4, 111 -> input |> day04_3.part1 |> string.inspect
    4, 222 -> input |> day04_3.part2 |> string.inspect
    5, 1 -> input |> day05.part1 |> string.inspect
    5, 2 -> input |> day05.part2 |> string.inspect
    6, 1 -> input |> day06.part1 |> string.inspect
    6, 2 -> input |> day06.part2 |> string.inspect
    6, 11 -> input |> day06_2.part1 |> string.inspect
    6, 22 -> input |> day06_2.part2 |> string.inspect
    7, 1 -> input |> day07.part1 |> string.inspect
    7, 2 -> input |> day07.part2 |> string.inspect
    7, 11 -> input |> day07_2.part1 |> string.inspect
    7, 22 -> input |> day07_2.part2 |> string.inspect
    _, _ ->
      "Unknown day and part for 2024: day "
      <> string.inspect(day)
      <> ", part "
      <> string.inspect(part)
  }
}
