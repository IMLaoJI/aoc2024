import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type Posn {
  Posn(r: Int, c: Int)
}

pub type Array2D(a) =
  Dict(Posn, a)

pub fn add_posns(p1: Posn, p2: Posn) -> Posn {
  case p1, p2 {
    Posn(r1, c1), Posn(r2, c2) -> Posn(r1 + r2, c1 + c2)
  }
}

pub fn add_direction(p1: Posn, dir: Direction) -> Posn {
  add_posns(p1, get_direction_dir(dir))
}

pub fn add_direction_normal(p1: Posn, dir: Direction) -> Posn {
  add_posns(p1, get_direction_dir_normal(dir))
}

pub fn offset_posns(p1: Posn, p2: Posn) -> Posn {
  case p1, p2 {
    Posn(r1, c1), Posn(r2, c2) -> Posn(r2 - r1, c2 - c1)
  }
}

pub fn get_dir() {
  [Posn(1, 0), Posn(-1, 0), Posn(0, 1), Posn(0, -1)]
}

pub fn get_dir_type() {
  [Left, Right, Top, Down]
}

pub fn get_direction_dir(direction) {
  case direction {
    Left -> Posn(0, -1)
    Right -> Posn(0, 1)
    Top -> Posn(-1, 0)
    Down -> Posn(1, 0)
  }
}

pub fn get_direction_dir_normal(direction) {
  case direction {
    Left -> Posn(0, -1)
    Right -> Posn(0, 1)
    Top -> Posn(1, 0)
    Down -> Posn(-1, 0)
  }
}

pub fn get_direction_from_posn(posn) {
  case posn {
    Posn(0, -1) -> Left
    Posn(0, 1) -> Right
    Posn(-1, 0) -> Top
    Posn(1, 0) -> Down
    Posn(_, _) -> panic
  }
}

pub fn ortho_neighbors(p: Posn) -> List(Posn) {
  let Posn(r, c) = p
  get_dir()
  |> list.map(fn(p) {
    let Posn(dr, dc) = p
    Posn(r + dr, c + dc)
  })
}

pub type Direction {
  Left
  Right
  Top
  Down
}

pub fn get_other_dir(old_position: Posn, direction: Direction) {
  case old_position, direction {
    Posn(-1, 0), Left -> Posn(0, -1)
    Posn(-1, 0), Right -> Posn(0, 1)

    Posn(0, 1), Left -> Posn(-1, 0)
    Posn(0, 1), Right -> Posn(1, 0)

    Posn(1, 0), Left -> Posn(0, 1)
    Posn(1, 0), Right -> Posn(0, -1)

    Posn(0, -1), Left -> Posn(1, 0)
    Posn(0, -1), Right -> Posn(-1, 0)
    _, _ -> old_position
  }
}

pub fn ortho_neighbors_with_direction(p: Posn) -> List(#(Posn, Posn)) {
  let Posn(r, c) = p
  get_dir()
  |> list.map(fn(p) {
    let Posn(dr, dc) = p
    #(Posn(r + dr, c + dc), p)
  })
}

pub fn to_2d_array(xss: List(List(a))) -> Array2D(a) {
  to_2d_array_using(xss, fn(x) { Ok(x) })
}

pub fn to_2d_array_using(
  xss: List(List(a)),
  f: fn(a) -> Result(b, Nil),
) -> Array2D(b) {
  {
    use row, r <- list.index_map(xss)
    use cell, c <- list.index_map(row)
    case f(cell) {
      Ok(contents) -> Ok(#(Posn(r, c), contents))
      Error(Nil) -> Error(Nil)
    }
  }
  |> list.flatten
  |> result.values
  |> dict.from_list
}

pub fn to_list_using(xss: List(List(a)), f: fn(a) -> Result(b, Nil)) {
  {
    use row, r <- list.index_map(xss)
    use cell, c <- list.index_map(row)
    case f(cell) {
      Ok(contents) -> Ok(#(Posn(r, c), contents))
      Error(Nil) -> Error(Nil)
    }
  }
  |> list.flatten
  |> result.values
}

pub fn to_2d_intarray(xss: List(List(String))) -> Array2D(Int) {
  {
    use row, r <- list.index_map(xss)
    use cell, c <- list.index_map(row)
    let assert Ok(n) = int.parse(cell)
    #(Posn(r, c), n)
  }
  |> list.flatten
  |> dict.from_list
}

pub fn to_2d_stringarray(xss: List(List(String))) -> Array2D(String) {
  {
    use row, r <- list.index_map(xss)
    use cell, c <- list.index_map(row)
    #(Posn(r, c), cell)
  }
  |> list.flatten
  |> dict.from_list
}

pub fn to_2d_stringlist(xss: List(List(String))) -> List(#(Posn, String)) {
  {
    use row, r <- list.index_map(xss)
    use cell, c <- list.index_map(row)
    #(Posn(r, c), cell)
  }
  |> list.flatten
}

pub fn to_2d_stringlist_with_po(
  xss: List(List(String)),
) -> List(List(#(Posn, String))) {
  {
    use row, r <- list.index_map(xss)
    use cell, c <- list.index_map(row)
    #(Posn(r, c), cell)
  }
}

pub fn to_list_of_lists_with_po(str: String) -> List(List(#(Posn, String))) {
  str
  |> string.trim
  |> string.split("\n")
  |> list.map(string.trim)
  |> list.map(string.to_graphemes)
  |> to_2d_stringlist_with_po
}

pub fn to_list_of_lists(str: String) -> List(List(String)) {
  str
  |> string.trim
  |> string.split("\n")
  |> list.map(string.trim)
  |> list.map(string.to_graphemes)
}

pub fn parse_grid(str: String) -> Array2D(String) {
  parse_grid_using(str, fn(x) { Ok(x) })
}

pub fn parse_grid_list(str: String) {
  parse_grid_using_list(str, fn(x) { Ok(x) })
}

pub fn parse_grid_using_list(str: String, f: fn(String) -> Result(a, Nil)) {
  str
  |> to_list_of_lists
  |> to_list_using(f)
}

pub fn parse_grid_using(
  str: String,
  f: fn(String) -> Result(a, Nil),
) -> Array2D(a) {
  str
  |> to_list_of_lists
  |> to_2d_array_using(f)
}
