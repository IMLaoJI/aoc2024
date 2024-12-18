import aoc/util/array2d.{type Posn, Posn}
import aoc/util/to
import gleam/bool
import gleam/deque
import gleam/dict
import gleam/io
import gleam/list.{Continue, Stop}
import gleam/string

fn parse(input) {
  let bytes =
    input
    |> string.split("\r\n")
    |> list.map(fn(p) {
      let assert Ok(#(first, second)) = string.split_once(p, ",")
      #(to.int(first), to.int(second))
    })

  let find_array =
    list.map(list.range(0, width), fn(n) {
      list.fold(list.range(0, width), [], fn(acc2, p) {
        let find_res =
          list.find(bytes |> list.take(1024), fn(byte) {
            byte.0 == p && byte.1 == n
          })
        let char = case find_res {
          Ok(_) -> "#"
          Error(_) -> "."
        }
        list.append(acc2, [char])
      })
    })
  #(find_array, bytes)
}

fn bfs(queue, min_path, find_dict, dst, size) {
  use <- bool.guard(deque.is_empty(queue), min_path)
  let assert Ok(#(Posn(cur_x, cur_y) as pos, rest_queue)) =
    deque.pop_front(queue)
  case cur_x == size && cur_y == size {
    True -> {
      bfs(deque.new(), to.unwrap(dict.get(dst, pos)), find_dict, dst, size)
    }
    False -> {
      let #(acc_dst, acc_rest_queue) = {
        use #(acc_dst, acc_rest_queue) as acc, item <- list.fold(
          array2d.get_dir_type(),
          #(dst, rest_queue),
        )

        let new_posotion = array2d.add_direction(pos, item)
        case
          dict.has_key(find_dict, new_posotion)
          && to.unwrap(dict.get(find_dict, new_posotion)) != "#"
          && !dict.has_key(dst, new_posotion)
        {
          True -> #(
            dict.insert(
              acc_dst,
              new_posotion,
              to.unwrap(dict.get(dst, pos)) + 1,
            ),
            deque.push_back(acc_rest_queue, new_posotion),
          )
          False -> acc
        }
      }
      bfs(acc_rest_queue, min_path, find_dict, acc_dst, size)
    }
  }
}

const width = 70

pub fn part1(input: String) -> Int {
  let #(find_array, _) = parse(input)
  let find_dict = array2d.to_2d_stringarray(find_array)
  let queue = deque.new() |> deque.push_back(Posn(0, 0))
  let dst = dict.new() |> dict.insert(Posn(0, 0), 0)
  bfs(queue, 0, find_dict, dst, width)
}

pub fn find_min_byte(byte: #(Int, Int), find_dict) {
  let new_find_dict = dict.insert(find_dict, Posn(byte.1, byte.0), "#")
  let queue = deque.new() |> deque.push_back(Posn(0, 0))
  let dst = dict.new() |> dict.insert(Posn(0, 0), 0)
  #(new_find_dict, bfs(queue, 0, new_find_dict, dst, width) == 0)
}

pub fn part2(input: String) -> Int {
  let #(find_array, bytes) = parse(input)
  let remind = bytes |> list.drop(1024)
  let find_dict = array2d.to_2d_stringarray(find_array)
  let #(find_byte, _) =
    list.fold_until(remind, #(#(0, 0), find_dict), fn(acc, byte) {
      let #(_, current_find_dict) = acc
      let #(new_find_dict, find_flag) = find_min_byte(byte, current_find_dict)
      case !find_flag {
        True -> Continue(#(byte, new_find_dict))
        False -> Stop(#(byte, new_find_dict))
      }
    })
  io.debug(find_byte)
  1
}
