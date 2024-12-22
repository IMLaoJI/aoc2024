import aoc/util/array2d.{type Direction, type Posn, Down, Left, Posn, Right, Top}
import gleam/deque
import gleam/set

import aoc/util/to
import gleam/bool

import gleam/dict.{type Dict}

import gleam/int

import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result

import gleamy/pairing_heap
import gleamy/priority_queue as pq

pub type Config {
  Config(
    input_dict: Dict(Posn, String),
    start: #(Posn, String),
    end: #(Posn, String),
  )
}

fn dijkstra_with_target_heuristic_round(
  queue: pairing_heap.Heap(#(Int, Int, Posn)),
  config: Config,
  cost,
  path,
  heuristic: option.Option(fn(Posn) -> Int),
  target: Option(Posn),
  edges: fn(Posn, Dict(Posn, String)) -> List(Posn),
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
        edges,
      )
    })
    let #(acc_cost, acc_path, acc_rest_queue) =
      edges(cur, config.input_dict)
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
      edges,
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

pub fn dijkstra_with_target_heuristic(
  config: Config,
  start,
  heuristic,
  target: option.Option(Posn),
  edges: fn(Posn, Dict(Posn, String)) -> List(Posn),
) {
  let cost = dict.new() |> dict.insert(start, 0)
  let path = dict.new()
  let queue = pq.from_list([#(0, 0, start)], fn(a, b) { int.compare(a.0, b.0) })

  dijkstra_with_target_heuristic_round(
    queue,
    config,
    cost,
    path,
    heuristic,
    target,
    edges,
  )
}

pub fn dijkstra(config, start, edges) {
  dijkstra_with_target_heuristic(config, start, None, None, edges)
}

fn get_path(prev_dict, current, path) {
  case dict.has_key(prev_dict, current) {
    True -> {
      let prev = to.unwrap(dict.get(prev_dict, current))
      get_path(prev_dict, prev, list.append(path, [prev]))
    }
    False -> list.reverse(path)
  }
}

fn bfs_round(config: Config, queue, visited, prev_dict) {
  case deque.is_empty(queue) {
    True -> panic
    False -> {
      let assert Ok(#(#(#(pos, char), dist), rest_queue)) =
        deque.pop_front(queue)
      use <- bool.lazy_guard(char == config.end.1, fn() {
        #(dist, get_path(prev_dict, pos, [pos]))
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
            #(
              dict.insert(acc_prev_dict, new_posotion, pos),
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
      bfs_round(config, acc_rest_queue, acc_dst, acc_prev_dict)
    }
  }
}

pub fn bfs(config: Config) {
  let queue =
    deque.new()
    |> deque.push_back(#(config.start, 0))
  let visited = set.new() |> set.insert(config.start.0)
  bfs_round(config, queue, visited, dict.new())
}
