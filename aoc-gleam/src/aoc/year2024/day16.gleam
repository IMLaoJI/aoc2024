import aoc/util/array2d.{type Direction, type Posn}
import aoc/util/to
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleamy/pairing_heap
import gleamy/priority_queue as pq

fn parse(input) {
  let input_position_array =
    input |> array2d.to_list_of_lists |> array2d.to_2d_stringlist
  #(input_position_array, dict.from_list(input_position_array))
}

fn move(
  dijk_q: pairing_heap.Heap(#(Int, #(#(Posn, String), Direction))),
  input_position_array,
  input_position_dict,
  visisted_dict,
  current_cost,
) {
  case pq.is_empty(dijk_q) {
    True -> current_cost
    False -> {
      let assert Ok(#(current, queue)) = pq.pop(dijk_q)
      let #(current_cost, current_position) = current
      case dict.get(visisted_dict, current_position) {
        Ok(a) if a < current_cost -> {
          move(
            queue,
            input_position_array,
            input_position_dict,
            visisted_dict,
            current_cost,
          )
        }
        _ -> {
          case current_position.0.1 == "E" {
            True -> current_cost
            False -> {
              let #(#(position, _), dir) = current_position
              array2d.add_posns(position, dir)
              current_cost
            }
          }
        }
      }
    }
  }
}

fn find_start(input_position_array: List(#(Posn, String))) {
  input_position_array
  |> list.find(fn(p) { p.1 == "S" })
  |> to.unwrap
}

pub fn part1(input: String) -> Int {
  let #(input_position_array, input_position_dict) =
    input
    |> parse
  let start = find_start(input_position_array)
  let dijk_q =
    pq.from_list([#(0, #(start, array2d.Right))], fn(a, b) {
      int.compare(a.0, b.0)
    })
  let visited_dict =
    dict.new()
    |> dict.insert(#(start, array2d.Right), 0)
  move(dijk_q, input_position_array, input_position_dict, visited_dict, 1)
  1
}

pub fn part2(input: String) -> Int {
  input
  |> parse
  1
}
