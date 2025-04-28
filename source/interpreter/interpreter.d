module interpreter.interpreter;

import std.variant : Variant;
import std.stdio, std.conv;
import interpreter.env: LispEnv;
import interpreter.lispfunction;
import parser.ast;

class Interpreter
{
  LispEnv globalEnv;

  this()
  {
    globalEnv = new LispEnv(null);
  }

  Variant eval(LispExpr expr, LispEnv env = null)
  {
    if (env is null)
      env = globalEnv;

    final switch (expr.kind)
    {
      case LispExprKind.Atom:
        if (expr.atom.type == typeid(int)) 
        {
          return Variant(expr.atom.get!int);
        }
        else if (expr.atom.type == typeid(string)) 
        {
          string s = expr.atom.get!string;

          if (env.contains(s))
            return env.get(s);
        
          return Variant(s);
        }
        else 
        {
          string symbol = expr.atom.get!string;
          return env.get(symbol);
        }

      case LispExprKind.List:
        if (expr.list.length == 0)
          return Variant();

        auto first = expr.list[0];
        if (first.kind != LispExprKind.Atom)
          throw new Exception("Invalid function call");

        auto op = first.atom.get!string;

        if (op == "defun")
        {
          auto name = expr.list[1].atom.get!string;
          auto paramsList = expr.list[2];
          if (paramsList.kind != LispExprKind.List)
            throw new Exception("Function parameters must be a list.");

          string[] params;
          foreach (p; paramsList.list)
          { 
            if (p.kind != LispExprKind.Atom || p.atom.type != typeid(string))
              throw new Exception("Parameter names must be symbols.");
            
            params ~= p.atom.get!string;
          }

          auto body = expr.list[3];
          auto func = Function(params, body, env);
          env.set(name, Variant(func));

          return Variant();
        }

        if (op == "defvar") 
        {
          auto nameExpr = expr.list[1];
          if (nameExpr.kind != LispExprKind.Atom || nameExpr.atom.type != typeid(string))
            throw new Exception("Variable name must be a symbol.");
          
          string name = nameExpr.atom.get!string;
          auto value = expr.list[2];

          auto evaluatedValue = eval(value, env);

          env.set(name, evaluatedValue);

          return Variant();
        }

        if (op == "printf")
        {
          foreach (arg; expr.list[1 .. $])
          {
            auto val = eval(arg, env);
            write(val, " ");
          }
          writeln();
          return Variant();
        }

        if (op == "+")
        {
          auto arg1 = expr.list[1];
          auto arg2 = expr.list[2];

          auto val1 = eval(arg1, env);
          auto val2 = eval(arg2, env);

          if (val1.peek!int && val2.peek!int)
          {
            return Variant(val1.get!int + val2.get!int);
          }
          else if (val1.peek!double && val2.peek!double)
          {
            return Variant(val1.get!double + val2.get!double);
          }
          else if ((val1.peek!int || val1.peek!double) &&
                  (val2.peek!int || val2.peek!double))
          {
            double a = val1.type == typeid(int) ? val1.get!int : val1.get!double;
            double b = val2.type == typeid(int) ? val2.get!int : val2.get!double;

            return Variant(a + b);
          }
          else {
            throw new Exception("Not a numeric value");
          }
        }

        if (env.contains(op))
        {
          auto val = env.get(op);

          if (val.type == typeid(Function))
          {
            auto func = val.get!Function;

            if (expr.list.length - 1 != func.parameters.length)
              throw new Exception("Function '" ~ op ~ "' expectes " ~ to!string(func.parameters.length) ~ " arguments");
            
            LispEnv localEnv = new LispEnv(func.closureEnv);

            foreach (i, param; func.parameters)
            {
              auto argVal = eval(expr.list[i+1], env);
              localEnv.set(param, Variant(argVal));
            }

            return eval(func.body, localEnv);
          } else 
          {
            throw new Exception("Invalid function value for " ~ op);
          }
        }

        throw new Exception("Unknown function: " ~ op);
    }

    return Variant();
  }


    bool isSymbol(string s) {
        import std.conv : to;
        try {
            to!int(s);
            return false;
        } catch (Exception) {
            return true;
        }
    }
}
