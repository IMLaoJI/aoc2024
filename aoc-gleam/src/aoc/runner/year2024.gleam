import aoc/year2024/day01
import aoc/year2024/day01_2
import aoc/year2024/day02
import aoc/year2024/day02_2
import aoc/year2024/day03
import aoc/year2024/day03_2
import aoc/year2024/day03_3
import aoc/year2024/day04
import aoc/year2024/day04_2
import aoc/year2024/day04_3
import aoc/year2024/day05
import aoc/year2024/day05_2
import aoc/year2024/day06
import aoc/year2024/day06_2
import aoc/year2024/day07
import aoc/year2024/day07_2
import aoc/year2024/day07_3
import aoc/year2024/day08
import aoc/year2024/day08_2
import aoc/year2024/day08_3
import aoc/year2024/day09
import aoc/year2024/day09_2
import aoc/year2024/day09_3
import aoc/year2024/day10
import aoc/year2024/day11
import aoc/year2024/day11_2
import aoc/year2024/day12
import aoc/year2024/day13
import aoc/year2024/day14
import aoc/year2024/day15
import aoc/year2024/day16
import aoc/year2024/day17
import aoc/year2024/day18
import aoc/year2024/day19
import aoc/year2024/day19_2
import gleam/string

pub fn run(input: String, day: Int, part: Int) {
  case day, part {
    1, 1 -> input |> day01.part1 |> string.inspect
    1, 2 -> input |> day01.part2 |> string.inspect
    1, 11 -> input |> day01_2.part1 |> string.inspect
    1, 22 -> input |> day01_2.part2 |> string.inspect
    2, 1 -> input |> day02.part1 |> string.inspect
    2, 2 -> input |> day02.part2 |> string.inspect
    2, 11 -> input |> day02_2.part1 |> string.inspect
    2, 22 -> input |> day02_2.part2 |> string.inspect
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
    5, 11 -> input |> day05_2.part1 |> string.inspect
    5, 22 -> input |> day05_2.part2 |> string.inspect
    6, 1 -> input |> day06.part1 |> string.inspect
    6, 2 -> input |> day06.part2 |> string.inspect
    6, 11 -> input |> day06_2.part1 |> string.inspect
    6, 22 -> input |> day06_2.part2 |> string.inspect
    7, 1 -> input |> day07.part1 |> string.inspect
    7, 2 -> input |> day07.part2 |> string.inspect
    7, 11 -> input |> day07_2.part1 |> string.inspect
    7, 22 -> input |> day07_2.part2 |> string.inspect
    7, 111 -> input |> day07_3.part1 |> string.inspect
    7, 222 -> input |> day07_3.part2 |> string.inspect
    8, 1 -> input |> day08.part1 |> string.inspect
    8, 2 -> input |> day08.part2 |> string.inspect
    8, 11 -> input |> day08_2.part1 |> string.inspect
    8, 22 -> input |> day08_2.part2 |> string.inspect
    8, 111 -> input |> day08_3.part1 |> string.inspect
    8, 222 -> input |> day08_3.part2 |> string.inspect
    9, 1 -> input |> day09.part1 |> string.inspect
    9, 2 -> input |> day09.part2 |> string.inspect
    9, 11 -> input |> day09_2.part1 |> string.inspect
    9, 22 -> input |> day09_2.part2 |> string.inspect
    9, 111 -> input |> day09_3.part1 |> string.inspect
    9, 222 -> input |> day09_3.part2 |> string.inspect
    10, 1 -> input |> day10.part1 |> string.inspect
    10, 2 -> input |> day10.part2 |> string.inspect
    11, 1 -> input |> day11.part1 |> string.inspect
    11, 2 -> input |> day11.part2 |> string.inspect
    11, 11 -> input |> day11_2.part1 |> string.inspect
    11, 22 -> input |> day11_2.part2 |> string.inspect
    12, 1 -> input |> day12.part1 |> string.inspect
    12, 2 -> input |> day12.part2 |> string.inspect
    13, 1 -> input |> day13.part1 |> string.inspect
    13, 2 -> input |> day13.part2 |> string.inspect
    14, 1 -> input |> day14.part1 |> string.inspect
    14, 2 -> input |> day14.part2 |> string.inspect
    15, 1 -> input |> day15.part1 |> string.inspect
    15, 2 -> input |> day15.part2 |> string.inspect
    16, 1 -> input |> day16.part1 |> string.inspect
    16, 2 -> input |> day16.part2 |> string.inspect
    17, 1 -> input |> day17.part1 |> string.inspect
    17, 2 -> input |> day17.part2 |> string.inspect
    18, 1 -> input |> day18.part1 |> string.inspect
    18, 2 -> input |> day18.part2 |> string.inspect
    19, 1 -> input |> day19.part1 |> string.inspect
    19, 2 -> input |> day19.part2 |> string.inspect
    19, 11 -> input |> day19_2.part1 |> string.inspect
    19, 22 -> input |> day19_2.part2 |> string.inspect
    _, _ ->
      "Unknown day and part for 2024: day "
      <> string.inspect(day)
      <> ", part "
      <> string.inspect(part)
  }
}
