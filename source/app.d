import std.stdio;

import parser.lexer, parser.token, parser.lispparser, parser.ast;
import std.variant : Variant;
import std.conv : to;
import std.array : appender, join;
import std.string : format;

import interpreter.interpreter : Interpreter;

void main()
{
    try
    {
    auto input = `
        (defvar *a* 2)
        (printf (+ *a* 2))
        (defun hello-world ()
            (printf "Hello, world"))
        (hello-world)
    `;

	auto lex = new Lexer(input);

    auto parser = new Parser(lex);

    auto interp = new Interpreter();
    while (lex.lookUp().type != TokenType.EOF)
    {
        auto expr = parser.parseExpr();
        interp.eval(expr);
    }
    }
    catch(Exception error)
    {
        writeln(error);
    }
}