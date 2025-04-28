module parser.lispparser;

import std.stdio;

import std.conv: to;
import std.variant: Variant;
import parser.lexer, parser.token, parser.ast;

class Parser
{
  Lexer lexer;
  Token current;

  this(Lexer lexer)
  {
    this.lexer = lexer;
    this.current = lexer.advanceToken();
  }

  void consume()
  {
    current = lexer.advanceToken();
  }

  bool match(TokenType type)
  {
    if (current.type == type)
    {
      consume();
      return true;
    }

    return false;
  }

  void error(string msg)
  {
    throw new Exception("Parser error: " ~ msg);
  }

  LispExpr parseExpr()
  {
    switch (current.type)
    {
      case TokenType.LPAREN:
        return parseList();

      case TokenType.NUMBER:
        auto val = to!int(current.value);
        consume();
        return LispExpr.makeAtom(Variant(val));

      case TokenType.STRING:
        auto strVal = current.value[1 .. $ - 1];
        consume();
        return LispExpr.makeAtom(Variant(strVal));

      case TokenType.IDENTIFIER:
        auto sym = current.value;
        consume();
        return LispExpr.makeAtom(Variant(sym));
      
      case TokenType.EOF:
        error("Unexpected end of input");
        break;

      default:
        error("Unexpected token " ~ current.value);
        break;
    }

    assert(0, "Unreachable code in parseExpr");
  }

  LispExpr parseList()
  {
    if (!match(TokenType.LPAREN))
      error("Expected '('");

    LispExpr[] elements;

    while (current.type != TokenType.RPAREN)
    {
      if (current.type == TokenType.EOF)
        error("Unclosed '('");
      
      auto expr = parseExpr();
      elements ~= expr;
    }

    match(TokenType.RPAREN);

    return LispExpr.makeList(elements);
  }
}

