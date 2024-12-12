import aoc/util/array2d.{type Posn}
import aoc/util/fun
import aoc/util/to
import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/set.{type Set}
import pocket_watch

fn parse(input) {
  let input_position_array =
    input |> array2d.to_list_of_lists |> array2d.to_2d_stringlist
  #(input_position_array, dict.from_list(input_position_array))
}

fn find_connect(
  cureent_spot: List(#(Posn, String)),
  input_dict,
  connect_dict,
  visited,
  current_trace_spot,
  current_trace_list,
) {
  case cureent_spot {
    [] -> #(
      visited,
      dict.insert(connect_dict, current_trace_list, current_trace_spot),
    )
    [spot, ..rest] -> {
      let #(posn, char) = spot
      let next_point =
        array2d.ortho_neighbors(posn)
        |> list.filter(fn(p) {
          fun.dict_get_unwrap(input_dict, p, "") == char
          && !set.contains(visited, p)
        })
      let next_queue =
        next_point
        |> list.map(fn(p) { #(p, to.unwrap(dict.get(input_dict, p))) })
      find_connect(
        list.append(rest, next_queue),
        input_dict,
        connect_dict,
        set.union(visited, set.from_list(next_point)),
        current_trace_spot,
        set.union(current_trace_list, set.from_list(next_queue)),
      )
    }
  }
}

pub fn find_all_connect(input_array, input_dict) {
  let #(_, connect_dict) =
    list.fold(input_array, #(set.new(), dict.new()), fn(acc, spot) {
      let #(visited, connect_dict) = acc
      let #(posn, char) = spot
      use <- bool.guard(set.contains(visited, posn), acc)
      let current_connect = set.new()
      find_connect(
        [spot],
        input_dict,
        connect_dict,
        visited,
        char,
        set.insert(current_connect, spot),
      )
    })
  connect_dict
}

pub fn get_perim_eages(posintions: Set(#(Posn, String))) {
  set.fold(posintions, [], fn(eages, p) {
    let posintion_list = set.map(posintions, fn(posintion) { posintion.0 })
    array2d.ortho_neighbors_with_direction(p.0)
    |> list.filter(fn(p) { !set.contains(posintion_list, p.0) })
    |> list.append(eages, _)
  })
}

pub fn exist_egdes(egde, next_dir, edges: Set(#(Posn, Posn))) {
  case set.contains(edges, egde) {
    True -> {
      exist_egdes(
        #(array2d.add_posns(egde.0, next_dir), egde.1),
        next_dir,
        set.delete(edges, egde),
      )
    }
    False -> edges
  }
}

pub fn get_edge_count(edges: List(#(Posn, Posn)), collect: List(Posn)) {
  case edges {
    [] -> collect
    [edge, ..rest] -> {
      let #(space, dir) = edge
      let rest =
        list.fold(
          [array2d.Left, array2d.Right],
          set.from_list(rest),
          fn(rest, p) {
            let next_dir = array2d.get_other_dir(dir, p)
            exist_egdes(
              #(array2d.add_posns(space, next_dir), dir),
              next_dir,
              rest,
            )
          },
        )
      get_edge_count(set.to_list(rest), list.append(collect, [space]))
    }
  }
}

pub fn part1(input: String) -> Int {
  use <- pocket_watch.simple("part 1")
  let #(input_array, input_dict) =
    input
    |> parse
  find_all_connect(input_array, input_dict)
  |> dict.fold(0, fn(acc, posintions, _) {
    let area = set.size(posintions)
    let perim = get_perim_eages(posintions) |> list.length
    acc + area * perim
  })
}

pub fn part2(input: String) -> Int {
  use <- pocket_watch.simple("part 2")
  let #(input_array, input_dict) =
    input
    |> parse
  find_all_connect(input_array, input_dict)
  |> dict.fold(0, fn(acc, posintions, _) {
    let area = set.size(posintions)
    let edges = get_perim_eages(posintions)
    let perim =
      get_edge_count(edges, list.new())
      |> list.length
    acc + area * perim
  })
}
