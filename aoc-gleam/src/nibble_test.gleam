import gleam/io
import gleam/option.{None, Some}
import nibble.{do, return}
import nibble/lexer

type Point {
  Point(x: Int, y: Int)
}

type Token {
  Num(Int)
  LParen
  RParen
  Comma
}

pub fn main() {
  // Your lexer knows how to take an input string and
  // turn it into a flat list of tokens. You define the
  // type of token you want to use, but nibble will wrap
  // that up in its own `Token` type that includes the
  // source span and original lexeme for each token.
  let lexer =
    lexer.simple([
      lexer.int(Num),
      lexer.token("(", LParen),
      lexer.token(")", RParen),
      lexer.token(",", Comma),
      // Skip over whitespace, we don't care about it!
      lexer.whitespace(Nil)
        |> lexer.ignore,
    ])

  // Your parser(s!) know how to transform a list of
  // tokens into whatever you want. You have the full
  // power of Gleam here, so you can go wild!
  let int_parser = {
    // Use `take_map` to only consume certain kinds of tokens and transform the
    // result.
    use tok <- nibble.take_map("expected number")
    case tok {
      Num(n) -> Some(n)
      _ -> None
    }
  }

  let parser = {
    use _ <- do(nibble.token(LParen))
    use x <- do(int_parser)
    use _ <- do(nibble.token(Comma))
    use y <- do(int_parser)
    use _ <- do(nibble.token(RParen))

    return(Point(x, y))
  }

  let assert Ok(tokens) = lexer.run("(1, 2)", lexer)
  let assert Ok(point) = nibble.run(tokens, parser)

  io.debug(point)
  //=> 1
  //=> 2
  1
}
