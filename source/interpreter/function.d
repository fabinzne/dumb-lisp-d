module interpreter.lispfunction;

import parser.ast;
import interpreter.env;


struct Function
{
    string[] parameters;
    LispExpr body;
    LispEnv closureEnv;
}
