import gleam/int
import gleam/io
import gleam/list
import gleam/string

pub type Chunk {
  File(offset: Int, size: Int, file_id: Int)
  Free(offset: Int, size: Int)
}

pub fn parse(input: String) {
  // let input = "2333133121414131402"
  input
  |> string.trim
  |> string.to_graphemes
  |> parse_loop(0, 0, [])
}

fn parse_loop(input, file_id, offset, chunks: List(Chunk)) {
  case input {
    [file_blocks, free_blocks, ..input] -> {
      let assert Ok(file_blocks) = int.parse(file_blocks)
      let assert Ok(free_blocks) = int.parse(free_blocks)
      let chunks = [
        Free(offset: offset + file_blocks, size: free_blocks),
        File(offset:, size: file_blocks, file_id:),
        ..chunks
      ]
      let offset = offset + file_blocks + free_blocks
      parse_loop(input, file_id + 1, offset, chunks)
    }

    [file_blocks, ..input] -> {
      io.debug(#("asdas", input))
      let assert Ok(file_blocks) = int.parse(file_blocks)
      let chunks = [File(offset:, size: file_blocks, file_id:), ..chunks]
      parse_loop(input, file_id + 1, offset + file_blocks, chunks)
    }

    [] -> list.reverse(chunks)
  }
}

fn defragment_blocks(forward, backward, result) {
  case forward, backward {
    // special case: we reached the same file from both sides
    // backwards wins because this is where we modify the files
    [File(..) as file1, ..forward], [File(..) as file2, ..backward]
      if file1.offset == file2.offset
    -> defragment_blocks(forward, backward, [file2, ..result])
    // any file gets written
    [File(..) as file, ..forward], _ ->
      defragment_blocks(forward, backward, [file, ..result])
    // we skip free blocks from the backwards list
    _, [Free(..), ..backward] -> defragment_blocks(forward, backward, result)
    // we can skip empty chunks that we produce during looping
    _, [File(size:, ..), ..backward] if size == 0 ->
      defragment_blocks(forward, backward, result)
    [Free(size:, ..), ..forward], _ if size == 0 ->
      defragment_blocks(forward, backward, result)
    // move blocks to the front if possible.
    [Free(..) as free, ..forward], [File(..) as file, ..backward]
      if free.offset < file.offset
    -> {
      let size = int.min(free.size, file.size)
      let forward = [
        Free(size: free.size - size, offset: free.offset + size),
        ..forward
      ]
      let backward = [File(..file, size: file.size - size), ..backward]
      let result = [
        File(offset: free.offset, size:, file_id: file.file_id),
        ..result
      ]
      defragment_blocks(forward, backward, result)
    }

    _, _ -> result
  }
}

pub fn part1(input: String) -> Int {
  input
  |> parse
  |> io.debug

  1
}

pub fn part2(input: String) -> Int {
  input
  |> parse
  |> io.debug
  1
}
