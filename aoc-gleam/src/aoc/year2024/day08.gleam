import aoc/util/array2d.{type Posn, Posn, add_posns, offset_posns}
import gleam/bool
import gleam/dict
import gleam/list
import gleam/set

fn parse(input: String) {
  let find_array =
    input
    |> array2d.parse_grid_list
    |> list.filter(fn(p) { p.1 != "." })
  let find_dict = input |> array2d.parse_grid
  #(find_array, find_dict)
}

pub fn find_antiantenas(find_array, find_dict, need_much) {
  {
    use find, #(item, item_char), idx <- list.index_fold(find_array, set.new())
    use antennas, #(next_item, next_item_char) <- list.fold(
      list.drop(find_array, idx + 1),
      find,
    )
    use <- bool.guard(item_char != next_item_char, antennas)
    case need_much {
      True -> {
        find_antiantenas_many(
          next_item,
          offset_posns(item, next_item),
          find_dict,
          [],
        )
        |> list.append(
          find_antiantenas_many(
            item,
            offset_posns(next_item, item),
            find_dict,
            [],
          ),
        )
        |> list.append(set.to_list(antennas))
        |> set.from_list
      }
      False -> {
        set.insert(
          antennas,
          add_posns(next_item, offset_posns(item, next_item)),
        )
        |> set.insert(add_posns(item, offset_posns(next_item, item)))
      }
    }
  }
  |> set.filter(fn(p) { dict.has_key(find_dict, p) })
  |> set.size()
}

fn find_antiantenas_many(point: Posn, offset: Posn, find_dict, antiantenas) {
  let new_point = add_posns(point, offset)
  case dict.has_key(find_dict, point) {
    True ->
      find_antiantenas_many(new_point, offset, find_dict, [point, ..antiantenas])
    False -> antiantenas
  }
}

pub fn part1(input: String) -> Int {
  let #(find_array, find_dict) = parse(input)
  find_antiantenas(find_array, find_dict, False)
}

pub fn part2(input: String) -> Int {
  let #(find_array, find_dict) = parse(input)
  find_antiantenas(find_array, find_dict, True)
}
