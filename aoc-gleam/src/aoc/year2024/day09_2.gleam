import aoc/util/to
import gleam/bool
import gleam/io
import gleam/list
import gleam/string

type State {
  Filled
  Empty
}

pub type Block {
  Block(n: Int)
  FreeSpace
}

pub type File {
  File(size: Int, id: Int)
  FreeSpan(size: Int)
}

pub fn parse(input: String) {
  do_parse(input, Filled, 0, [])
}

fn do_parse(input: String, state: State, file_index: Int, acc: List(Block)) {
  case state, string.pop_grapheme(input) {
    _, Error(_) -> list.reverse(acc)
    Filled, Ok(#(first, rest)) -> {
      let blocks = list.repeat(Block(file_index), to.int(first))
      do_parse(rest, Empty, file_index + 1, list.append(blocks, acc))
    }
    Empty, Ok(#(first, rest)) -> {
      let blocks = list.repeat(FreeSpace, to.int(first))
      do_parse(rest, Filled, file_index, list.append(blocks, acc))
    }
  }
}

fn replace(current: List(Block), movable: List(Block), acc: List(Block)) {
  case current, movable {
    remaining, [] -> list.append(list.reverse(acc), remaining)
    [FreeSpace, ..rest], [move, ..rest_to_move] ->
      replace(rest, rest_to_move, [move, ..acc])
    [b, ..rest], _ -> replace(rest, movable, [b, ..acc])
    _, _ -> panic
  }
}

pub fn pt_1(input: List(Block)) {
  let free_spaces = list.count(input, fn(b) { b == FreeSpace })
  let filled_spaces = list.length(input) - free_spaces
  let steps =
    filled_spaces
    |> list.take(input, _)
    |> list.count(fn(b) { b == FreeSpace })

  let to_keep = list.take(input, filled_spaces)
  let to_move =
    input
    |> list.reverse
    |> list.filter(fn(b) { b != FreeSpace })
    |> list.take(steps)

  replace(to_keep, to_move, [])
  |> list.index_fold(0, fn(acc, block, index) {
    case block {
      Block(n) -> acc + n * index
      FreeSpace -> acc
    }
  })
}

fn find_free_space(drive, files) {
  use <- bool.guard(list.is_empty(files), drive)
  let assert [File(size, id) as next, ..rest_files] = files
  // look for the first free span that's big enough to accommodate the next file to be moved
  // and split the list to expose that free span to match on
  // or split once the next file encounters itself on the disk
  // (which will be used to signal that the file shouldn't move rightwards instead)
  let drive_parts =
    list.split_while(drive, fn(f) {
      case f {
        File(_, other_id) if id == other_id -> False
        FreeSpan(free_size) if free_size >= size -> False
        _ -> True
      }
    })

  case drive_parts {
    // the second list will be empty if there's no valid spans to split on;
    // if the same file is found in the list
    // leave the file where it is and move on to the next one
    #(_, [File(_, _), ..]) | #(_no_split, []) ->
      find_free_space(drive, rest_files)
    // if the file fits exactly, just replace the free span,
    // then merge all the free spans around the moved file 
    #(first, [FreeSpan(free_size), ..rest]) if free_size == size -> {
      let after_move = collapse_free_space(rest, next, [])
      find_free_space(list.append(first, [next, ..after_move]), rest_files)
    }
    // if it's a loose fit, add an extra span for the remaining space
    #(first, [FreeSpan(free_size), ..rest]) -> {
      let after_move = collapse_free_space(rest, next, [])
      find_free_space(
        list.append(first, [next, FreeSpan(free_size - size), ..after_move]),
        rest_files,
      )
    }
  }
}

fn collapse_free_space(drive: List(File), moved: File, acc) {
  case drive {
    // various ways a moved file could be surrounded by free space
    // just merge them all together and put the drive back together
    [FreeSpan(a), f, FreeSpan(b), ..rest] if moved == f ->
      list.append(list.reverse(acc), [FreeSpan(a + f.size + b), ..rest])
    [FreeSpan(a), f, ..rest] if moved == f ->
      list.append(list.reverse(acc), [FreeSpan(a + f.size), ..rest])
    [f, FreeSpan(b), ..rest] if moved == f ->
      list.append(list.reverse(acc), [FreeSpan(f.size + b), ..rest])
    [f, ..rest] if moved == f ->
      list.append(list.reverse(acc), [FreeSpan(f.size), ..rest])
    // until the file is found, just keep track of everything to the left of it
    [other, ..rest] -> collapse_free_space(rest, moved, [other, ..acc])
    // if for some reason the file's not found, just return the original drive
    [] -> list.reverse(acc)
  }
}

pub fn pt_2(input: List(Block)) {
  let drive =
    input
    |> list.chunk(fn(n) { n })
    |> list.map(fn(blocks) {
      case blocks {
        [Block(n), ..] -> File(size: list.length(blocks), id: n)
        [FreeSpace, ..] -> FreeSpan(size: list.length(blocks))
        _ -> panic
      }
    })

  let files =
    drive
    |> list.reverse
    |> list.filter(fn(f) {
      case f {
        File(_, _) -> True
        _ -> False
      }
    })
  let a =
    find_free_space(drive, files)
    |> list.flat_map(fn(f) {
      case f {
        File(size, id) -> list.repeat(id, size)
        FreeSpan(size) -> list.repeat(0, size)
      }
    })

  io.debug(#(list.length(a)))
  a
  |> list.take(100)
  |> list.index_fold(0, fn(acc, block, index) {
    case block != 0 {
      True -> {
        acc + block * index
      }
      False -> {
        acc
      }
    }
  })
}

pub fn part1(input: String) -> Int {
  input
  |> parse
  |> pt_1
}

pub fn part2(input: String) -> Int {
  input
  |> parse
  |> pt_2
}
