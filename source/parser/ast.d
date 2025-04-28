module parser.ast;

import std.variant;

enum LispExprKind { Atom, List }

struct LispExpr {
    LispExprKind kind;
    union {
        struct {
            Variant atom;
        }
        struct {
            LispExpr[] list;
        }
    }

    static LispExpr makeAtom(Variant atom) {
        LispExpr expr;
        expr.kind = LispExprKind.Atom;
        expr.atom = atom;
        return expr;
    }
    static LispExpr makeList(LispExpr[] list) {
        LispExpr expr;
        expr.kind = LispExprKind.List;
        expr.list = list;
        return expr;
    }
}