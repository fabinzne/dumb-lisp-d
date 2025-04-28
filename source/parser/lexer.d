module parser.lexer;

import parser.token, parser.validator;

class Lexer
{
  string input;
  ulong pos;
  Token current;
  Token next;

  this(string input) 
  {
    this.input = input;
    this.pos = 0;
    this.current = Token(TokenType.EOF, "EOF");
    this.next = this.nextToken();
  }

  Token lookUp() 
  {
    return this.next;
  }

  Token advanceToken() 
  {
    this.current = this.next;
    this.next = this.nextToken();

    return this.current;
  }

  private Token nextToken() {
    if (this.input.length == this.pos) 
    {
      return Token(TokenType.EOF, "EOF");
    }

    if (isUseless(this.input[this.pos])) 
    {
      while (this.pos != this.input.length && isUseless(this.input[this.pos])) 
      {
        this.pos += 1;
      }

      return this.nextToken();
    }

    switch (this.input[this.pos])
    {


      case '(':
        this.pos += 1;
        return Token(TokenType.LPAREN, "(");
      case ')':
        this.pos += 1;
        return Token(TokenType.RPAREN, ")");
      case '"':
        auto start = this.pos;
        this.pos += 1;
        while (this.pos < this.input.length)
        {
          if (this.input[this.pos] == '\\') 
          {
            this.pos += 2;
          } 
          else if (this.input[this.pos] == '"')
          {
            this.pos += 1;
            break;
          }
          else
          {
            this.pos += 1;
          }
        }

        return Token(TokenType.STRING, this.input[start  .. this.pos]);
      default:
        break;
    }

    if (isDigit(this.input[this.pos])) 
    {
      auto start = this.pos;
      while (this.pos != this.input.length && isDigit(this.input[this.pos]))
      {
        this.pos += 1;
      }

      return Token(TokenType.NUMBER, this.input[start .. this.pos]);
    }

    if (isValidStart(this.input[this.pos]))
    {
      const start = this.pos;
      while (this.pos != this.input.length && isValid(this.input[this.pos]))
      {
        this.pos += 1;
      }

      return Token(TokenType.IDENTIFIER, this.input[start .. this.pos]);
    }

    throw new Error("Unrecognized token.");
  }
}

