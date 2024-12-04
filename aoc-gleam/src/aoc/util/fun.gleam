import gleam/list

pub type FixFn1(a, b) =
  fn(fn(a) -> b, a) -> b

pub type Fn1(a, b) =
  fn(a) -> b

pub type FixFn2(a, b, c) =
  fn(fn(a, b) -> c, a, b) -> c

pub type Fn2(a, b, c) =
  fn(a, b) -> c

pub type FixFn3(a, b, c, d) =
  fn(fn(a, b, c) -> d, a, b, c) -> d

pub type Fn3(a, b, c, d) =
  fn(a, b, c) -> d

pub type FixFn4(a, b, c, d, e) =
  fn(fn(a, b, c, d) -> e, a, b, c, d) -> e

pub type Fn4(a, b, c, d, e) =
  fn(a, b, c, d) -> e

pub fn fix(f: FixFn1(a, b)) -> Fn1(a, b) {
  fn(a: a) -> b { f(fix(f), a) }
}

pub fn fix2(f: FixFn2(a, b, c)) -> Fn2(a, b, c) {
  fn(a: a, b: b) -> c { f(fix2(f), a, b) }
}

pub fn fix3(f: FixFn3(a, b, c, d)) -> Fn3(a, b, c, d) {
  fn(a: a, b: b, c: c) -> d { f(fix3(f), a, b, c) }
}

pub fn fix4(f: FixFn4(a, b, c, d, e)) -> Fn4(a, b, c, d, e) {
  fn(a: a, b: b, c: c, d: d) -> e { f(fix4(f), a, b, c, d) }
}

pub fn index_filter(list: List(a), with fun: fn(a, Int) -> Bool) -> List(a) {
  index_find_loop(list, fun, 0, [])
}

pub fn index_any(list: List(a), with fun: fn(a, Int) -> Bool) -> Bool {
  !list.is_empty(index_find_loop(list, fun, 0, []))
}

pub fn index_find_loop(
  list: List(a),
  fun: fn(a, Int) -> Bool,
  index: Int,
  acc: List(a),
) -> List(a) {
  case list {
    [] -> list.reverse(acc)
    [first, ..rest] -> {
      case fun(first, index) {
        True -> index_find_loop(rest, fun, index + 1, [first, ..acc])
        False -> index_find_loop(rest, fun, index + 1, acc)
      }
    }
  }
}