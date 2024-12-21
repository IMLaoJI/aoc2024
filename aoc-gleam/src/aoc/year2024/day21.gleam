import aoc/util/array2d.{type Direction, type Posn, Down, Left, Posn, Right, Top}
import aoc/util/fun
import aoc/util/to
import gleam/bool
import gleam/deque
import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/set
import gleam/string
import gleamy/pairing_heap
import gleamy/priority_queue as pq
import rememo/memo

type Config {
  Config(
    input_dict: Dict(Posn, String),
    start: #(Posn, String),
    end: #(Posn, String),
    direction_map_config: Dict(Direction, String),
  )
}

fn get_config() {
  let number_config =
    dict.new()
    |> dict.insert(Posn(0, 0), "7")
    |> dict.insert(Posn(0, 1), "8")
    |> dict.insert(Posn(0, 2), "9")
    |> dict.insert(Posn(1, 0), "4")
    |> dict.insert(Posn(1, 1), "5")
    |> dict.insert(Posn(1, 2), "6")
    |> dict.insert(Posn(2, 0), "1")
    |> dict.insert(Posn(2, 1), "2")
    |> dict.insert(Posn(2, 2), "3")
    |> dict.insert(Posn(3, 1), "0")
    |> dict.insert(Posn(3, 2), "A")

  let number_map_config =
    dict.to_list(number_config)
    |> list.map(fn(p) { #(p.1, p.0) })
    |> dict.from_list

  let direction_config =
    dict.new()
    |> dict.insert(Posn(0, 1), "^")
    |> dict.insert(Posn(0, 2), "A")
    |> dict.insert(Posn(1, 0), "<")
    |> dict.insert(Posn(1, 1), "v")
    |> dict.insert(Posn(1, 2), ">")

  let direction_string_config =
    dict.to_list(direction_config)
    |> list.map(fn(p) { #(p.1, p.0) })
    |> dict.from_list

  let direction_map_config =
    dict.new()
    |> dict.insert(Top, "^")
    |> dict.insert(Left, "<")
    |> dict.insert(Down, "v")
    |> dict.insert(Right, ">")
  #(
    number_config,
    number_map_config,
    direction_config,
    direction_map_config,
    direction_string_config,
  )
}

fn parse(input, config) {
  input
  |> string.split("\r\n")
  |> list.map(string.to_graphemes)
  |> list.map(fn(p) {
    list.map(p, fn(item) { #(to.unwrap(dict.get(config, item)), item) })
  })
}

fn get_path(prev_dict, current, path: List(String)) {
  case dict.has_key(prev_dict, current) {
    True -> {
      let #(prev, dir) = to.unwrap(dict.get(prev_dict, current))
      get_path(prev_dict, prev, list.append(path, [dir]))
    }
    False -> list.reverse(path)
  }
}

fn bfs(config: Config, queue, visited, prev_dict) {
  case deque.is_empty(queue) {
    True -> panic
    False -> {
      let assert Ok(#(#(#(Posn(cur_x, cur_y) as pos, char), dist), rest_queue)) =
        deque.pop_front(queue)
      use <- bool.lazy_guard(char == config.end.1, fn() {
        #(dist, get_path(prev_dict, pos, ["A"]))
      })
      let #(acc_prev_dict, acc_dst, acc_rest_queue) = {
        use #(acc_prev_dict, acc_dst, acc_rest_queue) as acc, item <- list.fold(
          array2d.get_dir_type(),
          #(prev_dict, visited, rest_queue),
        )

        let new_posotion = array2d.add_direction(pos, item)
        case
          dict.has_key(config.input_dict, new_posotion)
          && to.unwrap(dict.get(config.input_dict, new_posotion)) != "#"
          && !set.contains(acc_dst, new_posotion)
        {
          True -> {
            let dir_str = to.unwrap(dict.get(config.direction_map_config, item))
            #(
              dict.insert(acc_prev_dict, new_posotion, #(pos, dir_str)),
              set.insert(acc_dst, new_posotion),
              deque.push_back(acc_rest_queue, #(
                #(
                  new_posotion,
                  to.unwrap(dict.get(config.input_dict, new_posotion)),
                ),
                dist + 1,
              )),
            )
          }
          False -> acc
        }
      }
      bfs(config, acc_rest_queue, acc_dst, acc_prev_dict)
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

fn dijkstra_with_target(m, edges, start, heuristic, target) {
  todo
}

fn dijkstra_with_target_heuristic_round(
  queue: pairing_heap.Heap(#(Int, Int, Posn)),
  config: Config,
  cost,
  path,
  heuristic: option.Option(fn(Posn) -> Int),
  target: Option(Posn),
) {
  let first = pq.peek(queue)
  let deal = fn() {
    let assert Ok(#(#(_, k, cur), rest_queue)) = pq.pop(queue)
    use <- bool.lazy_guard(k != to.unwrap(dict.get(cost, cur)), fn() {
      dijkstra_with_target_heuristic_round(
        rest_queue,
        config,
        cost,
        path,
        heuristic,
        target,
      )
    })
    let #(acc_cost, acc_path, acc_rest_queue) =
      array2d.ortho_neighbors(cur)
      |> list.filter(fn(p) { dict.has_key(config.input_dict, p) })
      |> list.fold(#(cost, path, rest_queue), fn(acc, posn) {
        let #(acc_cost, acc_path, acc_rest_queue) = acc
        let current_cost = to.unwrap(dict.get(acc_cost, cur))
        let next_cost = result.unwrap(dict.get(acc_cost, posn), -1)
        let ncost = current_cost + 1
        use <- bool.lazy_guard(
          !dict.has_key(acc_cost, posn) || ncost < next_cost,
          fn() {
            let new_cost = dict.insert(acc_cost, posn, ncost)
            let new_path = dict.insert(acc_path, posn, [cur])
            let hcost = case heuristic {
              Some(func) -> ncost + func(posn)
              None -> ncost
            }
            let new_queue = pq.push(acc_rest_queue, #(hcost, ncost, posn))
            #(new_cost, new_path, new_queue)
          },
        )
        use <- bool.lazy_guard(ncost == next_cost, fn() {
          #(
            acc_cost,
            dict.upsert(acc_path, posn, fn(x) {
              case x {
                Some(i) -> list.append(i, [cur])
                None -> []
              }
            }),
            acc_rest_queue,
          )
        })
        acc
      })
    dijkstra_with_target_heuristic_round(
      acc_rest_queue,
      config,
      acc_cost,
      acc_path,
      heuristic,
      target,
    )
  }

  case first, target {
    Ok(#(_, _, pos)), Some(target) if pos != target -> {
      deal()
    }
    Ok(_), Some(_) -> {
      #(cost, path)
    }
    Ok(_), None -> {
      deal()
    }
    Error(_), _ -> #(cost, path)
  }
}

fn dijkstra_with_target_heuristic(
  config: Config,
  start,
  heuristic,
  target: option.Option(Posn),
) {
  let cost = dict.new() |> dict.insert(start, 0)
  let path = dict.new()
  let queue = pq.from_list([#(0, 0, start)], fn(a, b) { int.compare(a.0, b.0) })
  let explored = 0

  dijkstra_with_target_heuristic_round(
    queue,
    config,
    cost,
    path,
    heuristic,
    target,
  )
}

fn dijkstra(config: Config, start) {
  dijkstra_with_target_heuristic(config, start, option.None, option.None)
}

fn gets(
  m: Dict(Posn, #(Dict(Posn, Int), Dict(Posn, List(Posn)))),
  src,
  tgt,
  config,
) {
  use <- bool.guard(src == tgt, [""])
  let mp = to.unwrap(dict.get(m, src)).1
  list.fold(to.unwrap(dict.get(mp, tgt)), [], fn(acc, p) {
    let dir =
      array2d.offset_posns(p, tgt)
      |> array2d.get_direction_from_posn
    let dir_str = to.unwrap(dict.get(config, dir))
    // io.debug(dir)
    let next = gets(m, src, p, config)
    list.fold(next, acc, fn(sub_acc, item) {
      list.append(sub_acc, [item <> dir_str])
    })
  })
}

fn go(
  i,
  csrc,
  ctgt,
  maps: List(
    #(
      Dict(Posn, #(Dict(Posn, Int), Dict(Posn, List(Posn)))),
      Dict(String, Posn),
    ),
  ),
  config,
) {
  use <- bool.guard(i == 3, ctgt)
  let #(cost, rm) = to.unwrap(fun.get_at(maps, i))
  let src = to.unwrap(dict.get(rm, csrc))
  let tgt = to.unwrap(dict.get(rm, ctgt))
  let min_path = ""
  let min_path =
    list.fold(gets(cost, src, tgt, config), min_path, fn(acc, item) {
      // io.debug(item)
      let #(spath, _) =
        list.fold(
          string.to_graphemes(item <> "A"),
          #("", "A"),
          fn(sub_acc, item) {
            let #(spath, pos) = sub_acc
            let spath = spath <> go(i + 1, pos, item, maps, config)
            #(spath, item)
          },
        )
      case acc == "" || string.length(spath) < string.length(acc) {
        True -> spath
        False -> acc
      }
    })
  min_path
}

fn go2(
  i,
  csrc,
  ctgt,
  maps: List(
    #(
      Dict(Posn, #(Dict(Posn, Int), Dict(Posn, List(Posn)))),
      Dict(String, Posn),
    ),
  ),
  config,
  cache,
) {
  use <- memo.memoize(cache, #(i, csrc, ctgt))
  use <- bool.guard(i == list.length(maps), 1)
  let #(cost, rm) = to.unwrap(fun.get_at(maps, i))
  let src = to.unwrap(dict.get(rm, csrc))
  let tgt = to.unwrap(dict.get(rm, ctgt))
  let min_path = 99_999_999_999
  let min_path =
    list.fold(gets(cost, src, tgt, config), min_path, fn(acc, item) {
      // io.debug(item)
      let #(spath, _) =
        list.fold(
          string.to_graphemes(item <> "A"),
          #(0, "A"),
          fn(sub_acc, item) {
            let #(spath, pos) = sub_acc
            let spath = spath + go2(i + 1, pos, item, maps, config, cache)
            #(spath, item)
          },
        )
      int.min(spath, acc)
    })
  min_path
}

fn init_config_and_cost(input) {
  let #(
    number_config,
    number_map_config,
    direction_config,
    direction_map_config,
    direction_string_config,
  ) = get_config()
  let start_posn = Posn(3, 2)
  let input_data =
    input
    |> parse(number_map_config)
    |> list.map(fn(p) { list.prepend(p, #(start_posn, "A")) })
    |> io.debug

  let num_costs =
    dict.map_values(number_config, fn(key, value) {
      dijkstra(
        Config(
          number_config,
          #(start_posn, "A"),
          #(start_posn, "A"),
          direction_map_config,
        ),
        key,
      )
    })

  let dir_costs =
    dict.map_values(direction_config, fn(key, value) {
      dijkstra(
        Config(
          direction_config,
          #(start_posn, "A"),
          #(start_posn, "A"),
          direction_map_config,
        ),
        key,
      )
    })
  #(
    num_costs,
    dir_costs,
    input_data,
    number_map_config,
    direction_string_config,
    direction_map_config,
  )
}

pub fn part1(input: String) -> Int {
  let #(
    num_costs,
    dir_costs,
    input_data,
    number_map_config,
    direction_string_config,
    direction_map_config,
  ) = init_config_and_cost(input)
  let maps =
    [#(num_costs, number_map_config)]
    |> list.append(list.repeat(#(dir_costs, direction_string_config), 2))
  input_data
  |> list.map(fn(p) {
    let num =
      list.filter(p, fn(t) { int.parse(t.1) |> result.is_ok })
      |> list.map(fn(t) { t.1 })
      |> string.join("")
      |> to.int
    let min_path =
      list.window_by_2(p)
      |> list.fold("", fn(acc, pair) {
        let #(start, end) = pair

        acc <> go(0, start.1, end.1, maps, direction_map_config)
      })
    #(num, min_path)
  })
  |> list.fold(0, fn(acc, t) { acc + t.0 * string.length(t.1) })
}

pub fn part2(input: String) -> Int {
  let #(
    num_costs,
    dir_costs,
    input_data,
    number_map_config,
    direction_string_config,
    direction_map_config,
  ) = init_config_and_cost(input)
  let maps =
    [#(num_costs, number_map_config)]
    |> list.append(list.repeat(#(dir_costs, direction_string_config), 25))

  use cache <- memo.create()
  input_data
  |> list.map(fn(p) {
    let num =
      list.filter(p, fn(t) { int.parse(t.1) |> result.is_ok })
      |> list.map(fn(t) { t.1 })
      |> string.join("")
      |> to.int
    let min_path =
      list.window_by_2(p)
      |> list.fold(0, fn(acc, pair) {
        let #(start, end) = pair
        acc + go2(0, start.1, end.1, maps, direction_map_config, cache)
      })
    #(num, min_path)
  })
  |> list.fold(0, fn(acc, t) { acc + t.0 * t.1 })
}
