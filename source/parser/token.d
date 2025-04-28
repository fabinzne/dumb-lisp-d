module parser.token;

struct Token
{ 
  TokenType type;
  string value;
}

enum TokenType {
  LPAREN,
  RPAREN,
  NUMBER,
  STRING,
  BOOLEAN,
  CHAR,
  IDENTIFIER,
  EOF
}