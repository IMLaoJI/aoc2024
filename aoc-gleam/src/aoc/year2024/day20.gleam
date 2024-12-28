import aoc/util/array2d.{type Posn, Posn}
import aoc/util/to
import gleam/bool
import gleam/deque
import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/set
import pocket_watch

type Config {
  Config(
    input_dict: Dict(Posn, String),
    input_array: List(#(Posn, String)),
    width: Int,
    height: Int,
    start: #(Posn, String),
    end: #(Posn, String),
  )
}

fn parse(input) {
  let input_position_array =
    input |> array2d.to_list_of_lists_with_po |> list.flatten
  let list_string = array2d.to_list_of_lists(input)
  let width = to.unwrap(list.first(list_string)) |> list.length
  let height = list.length(list_string)
  let input_dict = dict.from_list(input_position_array)
  let start = list.find(input_position_array, fn(p) { p.1 == "S" }) |> to.unwrap
  let end = list.find(input_position_array, fn(p) { p.1 == "E" }) |> to.unwrap
  Config(input_dict, input_position_array, width, height, start, end)
}

fn push_path(prev, current, res) {
  case dict.has_key(prev, current) {
    True -> {
      let cu = to.unwrap(dict.get(prev, current))
      push_path(prev, cu, list.append(res, [cu]))
    }
    False -> list.reverse(res)
  }
}

fn bfs(config: Config, queue, visited, prev) {
  case deque.is_empty(queue) {
    True -> panic
    False -> {
      let assert Ok(#(#(#(pos, char), dist), rest_queue)) =
        deque.pop_front(queue)
      use <- bool.lazy_guard(char == config.end.1, fn() {
        #(dist, push_path(prev, pos, [pos]))
      })
      let #(acc_dst, acc_rest_queue, prev) = {
        use #(acc_dst, acc_rest_queue, prev) as acc, item <- list.fold(
          array2d.get_dir_type(),
          #(visited, rest_queue, prev),
        )

        let new_posotion = array2d.add_direction(pos, item)
        case
          dict.has_key(config.input_dict, new_posotion)
          && to.unwrap(dict.get(config.input_dict, new_posotion)) != "#"
          && !set.contains(acc_dst, new_posotion)
        {
          True -> {
            #(
              set.insert(acc_dst, new_posotion),
              deque.push_back(acc_rest_queue, #(
                #(
                  new_posotion,
                  to.unwrap(dict.get(config.input_dict, new_posotion)),
                ),
                dist + 1,
              )),
              dict.insert(prev, new_posotion, pos),
            )
          }
          False -> acc
        }
      }
      bfs(config, acc_rest_queue, acc_dst, prev)
    }
  }
}

fn count_saving_cheats(config: Config) {
  let queue =
    deque.new()
    |> deque.push_back(#(config.start, 0))
  let visited = set.new() |> set.insert(config.start.0)
  bfs(config, queue, visited, dict.new())
}

pub fn part1(input: String) -> Int {
  use <- pocket_watch.simple("part 1")
  let config =
    input
    |> parse
  let #(origin_cost, path) = count_saving_cheats(config)

  io.debug(#(path, origin_cost))
  list.filter(config.input_array, fn(p) { p.1 == "#" })
  |> list.map(fn(p) {
    let new_dict = dict.insert(config.input_dict, p.0, ".")
    let new_config = Config(..config, input_dict: new_dict)
    origin_cost - count_saving_cheats(new_config).0
  })
  |> list.group(function.identity)
  |> dict.map_values(fn(_, value) { list.length(value) })
  |> dict.filter(fn(key, _) { key >= 100 })
  |> dict.values
  |> list.fold(0, int.add)
  |> io.debug

  1
}

pub fn part2(input: String) -> Int {
  use <- pocket_watch.simple("part 2")
  let config =
    input
    |> parse
  let #(_, path) = count_saving_cheats(config)
  let path_dict =
    path |> list.index_map(fn(p, index) { #(index, p) }) |> dict.from_list
  let path_length = list.length(path)
  use acc, i <- list.fold(list.range(0, path_length - 1), 0)
  use acc2, j <- list.fold(list.range(i + 1, path_length - 1), acc)
  use <- bool.guard(j == path_length, acc2)
  let first = to.unwrap(dict.get(path_dict, i))
  let second = to.unwrap(dict.get(path_dict, j))
  let dst =
    int.absolute_value(first.r - second.r)
    + int.absolute_value(first.c - second.c)

  use <- bool.guard(dst > 20, acc2)
  let new_path = i + dst + path_length - j - 1
  case new_path <= path_length - 1 - 100 {
    True -> acc2 + 1
    False -> acc2
  }
}
