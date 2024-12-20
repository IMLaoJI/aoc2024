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

fn bfs(config: Config, queue, visited) {
  case deque.is_empty(queue) {
    True -> panic
    False -> {
      let assert Ok(#(#(#(Posn(cur_x, cur_y) as pos, char), dist), rest_queue)) =
        deque.pop_front(queue)
      use <- bool.guard(char == config.end.1, dist)
      let #(acc_dst, acc_rest_queue) = {
        use #(acc_dst, acc_rest_queue) as acc, item <- list.fold(
          array2d.get_dir_type(),
          #(visited, rest_queue),
        )

        let new_posotion = array2d.add_direction(pos, item)
        case
          dict.has_key(config.input_dict, new_posotion)
          && to.unwrap(dict.get(config.input_dict, new_posotion)) != "#"
          && !set.contains(acc_dst, new_posotion)
        {
          True -> #(
            set.insert(acc_dst, new_posotion),
            deque.push_back(acc_rest_queue, #(
              #(
                new_posotion,
                to.unwrap(dict.get(config.input_dict, new_posotion)),
              ),
              dist + 1,
            )),
          )
          False -> acc
        }
      }
      bfs(config, acc_rest_queue, acc_dst)
    }
  }
}

fn count_saving_cheats(config: Config) {
  let queue =
    deque.new()
    |> deque.push_back(#(config.start, 0))
  let visited = set.new() |> set.insert(config.start.0)
  bfs(config, queue, visited)
}

pub fn part1(input: String) -> Int {
  let config =
    input
    |> parse
  let origin_cost = count_saving_cheats(config)
  io.debug(origin_cost)
  list.filter(config.input_array, fn(p) { p.1 == "#" })
  |> list.map(fn(p) {
    let new_dict = dict.insert(config.input_dict, p.0, ".")
    let new_config = Config(..config, input_dict: new_dict)
    origin_cost - count_saving_cheats(new_config)
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
  input
  |> parse
  1
}
