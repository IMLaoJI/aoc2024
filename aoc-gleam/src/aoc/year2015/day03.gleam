import aoc/util/array2d.{type Direction, type Posn, Posn}
import gleam/list
import gleam/set
import gleam/string

fn parse_steps(input: String) -> List(Direction) {
  case input |> string.trim {
    "" -> []
    "^" <> rest -> [array2d.Top, ..parse_steps(rest)]
    "v" <> rest -> [array2d.Down, ..parse_steps(rest)]
    "<" <> rest -> [array2d.Left, ..parse_steps(rest)]
    ">" <> rest -> [array2d.Right, ..parse_steps(rest)]
    _ -> panic
  }
}

fn move(steps: List(Direction), current, points) {
  case steps {
    [] -> points
    [first, ..rest] -> {
      let next = array2d.add_direction_normal(current, first)
      move(
        rest,
        next,
        set.insert(points, next)
          |> set.insert(current),
      )
    }
  }
}

fn move_bi_dir(steps: List(List(Direction)), currents, points) {
  let #(origin_cur, rebot_cur) = currents
  case steps {
    [] -> points
    [first, ..rest] -> {
      case first {
        [origin, robot] -> {
          let next_origin = array2d.add_direction_normal(origin_cur, origin)
          let next_rebot = array2d.add_direction_normal(rebot_cur, robot)
          points
          |> set.insert(origin_cur)
          |> set.insert(next_origin)
          |> set.insert(rebot_cur)
          |> set.insert(next_rebot)
          |> move_bi_dir(rest, #(next_origin, next_rebot), _)
        }
        [origin] -> {
          let next_origin = array2d.add_direction_normal(origin_cur, origin)
          points
          |> set.insert(origin_cur)
          |> set.insert(rebot_cur)
          |> set.insert(next_origin)
          |> move_bi_dir(rest, #(next_origin, rebot_cur), _)
        }
        _ -> panic
      }
    }
  }
}

pub fn part1(input: String) -> Int {
  input
  |> parse_steps
  |> move(Posn(0, 0), set.new())
  |> set.size
}

// pub fn part2(input: String) -> Int {
//   input
//   |> parse_steps
//   |> list.sized_chunk(2)
//   |> move_bi_dir(#(Posn(0, 0), Posn(0, 0)), set.new())
//   |> set.size
// }

pub fn part2(input: String) -> Int {
  let assert [origin_route, roport_route] =
    input
    |> parse_steps
    |> list.sized_chunk(2)
    |> list.transpose

  move(origin_route, Posn(0, 0), set.new())
  |> set.union(move(roport_route, Posn(0, 0), set.new()))
  |> set.size
}
