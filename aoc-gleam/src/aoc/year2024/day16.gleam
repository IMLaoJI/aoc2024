import aoc/util/array2d.{type Direction, type Posn}
import aoc/util/to
import gleam/dict
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

fn add_node(new_posotion, new_cost, visited, queue) {
  let a = dict.get(visited, new_posotion)
  case result.is_error(a) || to.unwrap(a) > new_cost {
    True -> {
      #(
        dict.insert(visited, new_posotion, new_cost),
        pq.push(queue, #(new_cost, new_posotion)),
      )
    }
    False -> {
      #(visited, queue)
    }
  }
}

fn move(
  dijk_q: pairing_heap.Heap(#(Int, #(#(Posn, String), Direction))),
  input_position_array,
  input_position_dict,
  visisted_dict,
  op_sign,
) {
  case pq.is_empty(dijk_q) {
    True -> visisted_dict
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
            op_sign,
          )
        }
        _ -> {
          let #(#(position, char), dir) = current_position
          let dir_posn = array2d.get_direction_dir(dir)
          let next_position =
            array2d.add_posns(
              position,
              array2d.Posn(op_sign * dir_posn.r, op_sign * dir_posn.c),
            )
          let next = dict.get(input_position_dict, next_position)
          let update = case result.is_ok(next) && to.unwrap(next) != "#" {
            True -> {
              add_node(
                #(#(next_position, to.unwrap(next)), dir),
                current_cost + 1,
                visisted_dict,
                queue,
              )
            }
            False -> #(visisted_dict, queue)
          }
          let other_dirs = [array2d.Top, array2d.Down]
          let acc =
            case list.contains(other_dirs, dir) {
              True -> [array2d.Left, array2d.Right]
              False -> other_dirs
            }
            |> list.fold(update, fn(acc, item) {
              add_node(
                #(#(position, char), item),
                current_cost + 1000,
                acc.0,
                acc.1,
              )
            })
          move(acc.1, input_position_array, input_position_dict, acc.0, op_sign)
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

fn find_end(input_position_array: List(#(Posn, String))) {
  input_position_array
  |> list.find(fn(p) { p.1 == "E" })
  |> to.unwrap
}

fn get_min_cost(input) {
  let #(input_position_array, input_position_dict) =
    input
    |> parse
  let start = find_start(input_position_array)
  let end = find_end(input_position_array)
  let dijk_q =
    pq.from_list([#(0, #(start, array2d.Right))], fn(a, b) {
      int.compare(a.0, b.0)
    })
  let visited_dict =
    dict.new()
    |> dict.insert(#(start, array2d.Right), 0)
  let init_solve =
    move(dijk_q, input_position_array, input_position_dict, visited_dict, 1)
  let min_cost =
    array2d.get_dir_type()
    |> list.map(fn(p) { to.unwrap(dict.get(init_solve, #(end, p))) })
    |> list.sort(int.compare)
    |> list.first
    |> result.unwrap(0)
  #(init_solve, min_cost)
}

pub fn part1(input: String) -> Int {
  let #(_, min_cost) = get_min_cost(input)
  min_cost
}

pub fn part2(input: String) -> Int {
  let #(input_position_array, input_position_dict) =
    input
    |> parse
  let end = find_end(input_position_array)
  let #(init_solve, min_cost) = get_min_cost(input)
  let nd_solves =
    array2d.get_dir_type()
    |> list.map(fn(p) {
      let visited_dict =
        dict.new()
        |> dict.insert(#(end, p), 0)
      let dijk_q =
        pq.from_list([#(0, #(end, p))], fn(a, b) { int.compare(a.0, b.0) })
      move(dijk_q, input_position_array, input_position_dict, visited_dict, -1)
    })
  list.filter(input_position_array, fn(item) {
    array2d.get_dir_type()
    |> list.any(fn(p) {
      let current = #(item, p)
      list.any(nd_solves, fn(nd_solve) {
        case
          !dict.has_key(init_solve, current) || !dict.has_key(nd_solve, current)
        {
          True -> False
          False -> {
            let distance =
              to.unwrap(dict.get(init_solve, current))
              + to.unwrap(dict.get(nd_solve, current))
            distance == min_cost
          }
        }
      })
    })
  })
  |> list.length
}
