import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import nibble.{do, return}
import nibble/lexer

pub type Token {
  M
  U
  L
  LParen
  RParen
  Comma
  Number(Int)
  Other
}

pub type Operation {
  Mul(first: Int, second: Int)
}

pub type ParseError {
  LexerError(String)
  NibbleError(String)
}

pub type ParseResult =
  Result(List(Operation), ParseError)

pub fn sum_operations(operations: List(Operation)) -> Int {
  list.fold(operations, 0, fn(acc, op) {
    case op {
      Mul(x, y) -> acc + x * y
    }
  })
}

pub fn parse_operations(input: String) -> ParseResult {
  let lexer =
    lexer.simple([
      lexer.token("m", M),
      lexer.token("u", U),
      lexer.token("l", L),
      lexer.token("(", LParen),
      lexer.token(")", RParen),
      lexer.token(",", Comma),
      lexer.int(Number),
      lexer.keep(fn(the_string, _) {
        let is_known =
          the_string
          |> string.split("")
          |> list.map(fn(char) { string.contains("mul(),0123456789", char) })
          |> list.all(fn(x) { x })

        case is_known {
          True -> Error(Nil)
          False -> Ok(Other)
        }
      }),
    ])

  let number_parser = {
    use tok <- nibble.take_map("expected number")
    case tok {
      Number(n) -> Some(n)
      _ -> None
    }
  }

  let mul_parser = {
    use acc <- nibble.loop([])
    nibble.one_of([
      {
        use _ <- do(nibble.token(M))
        use _ <- do(nibble.token(U))
        use _ <- do(nibble.token(L))
        use _ <- do(nibble.token(LParen))
        use x <- do(number_parser)
        use _ <- do(nibble.token(Comma))
        use y <- do(number_parser)
        use _ <- do(nibble.token(RParen))
        return(Mul(x, y))
      }
        |> nibble.backtrackable
        |> nibble.map(list.prepend(acc, _))
        |> nibble.map(nibble.Continue),
      // if that fails take everything until we find another `m`
      nibble.take_until1("m", fn(tok) { tok == M })
        |> nibble.replace(acc)
        |> nibble.map(nibble.Continue),
      // // we need to explicitly handle the case where we have an `m`
      // // but `mul_parser` failed
      nibble.token(M)
        |> nibble.replace(acc)
        |> nibble.map(nibble.Continue),
      // // we reached the end, return our list
      nibble.eof()
        |> nibble.map(fn(_) { list.reverse(acc) })
        |> nibble.map(nibble.Break),
    ])
  }
  case lexer.run(input, lexer) {
    Ok(tokens) -> {
      case nibble.run(tokens, mul_parser) {
        Ok(operations) -> {
          Ok(operations)
        }
        Error(err) -> {
          io.debug(err)
          Error(NibbleError("Nibble error"))
        }
      }
    }
    Error(_) -> {
      io.debug("aaa")
      Error(LexerError("Lexer error"))
    }
  }
}

pub fn part1(input: String) -> Int {
  input
  |> parse_operations()
  |> result.map(sum_operations)
  |> result.unwrap(0)
}

pub fn part2(input: String) -> Int {
  input
  |> parse_operations()
  |> result.map(sum_operations)
  |> result.unwrap(0)
  |> io.debug
  1
}
