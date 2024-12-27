import aoc/runner/year2015
import aoc/runner/year2023
import aoc/runner/year2024
import aoc/util/fun.{measure_time}
import gleam/result
import gleam/string
import simplifile

pub fn run(year: Int, day: Int, part: Int) {
  let year_str = string.inspect(year)
  let day_str = day |> string.inspect |> string.pad_start(2, "0")
  let path = "./data/" <> year_str <> "/day" <> day_str <> ".txt"
  use content <- result.try(
    path
    |> simplifile.read
    |> result.replace_error("Could not read file: " <> path),
  )

  case year {
    2015 -> measure_time(fn() { year2015.run(content, day, part) })
    2023 -> measure_time(fn() { year2023.run(content, day, part) })
    2024 -> measure_time(fn() { year2024.run(content, day, part) })
    _ -> "Unkown year: " <> year_str
  }
  |> Ok
}
