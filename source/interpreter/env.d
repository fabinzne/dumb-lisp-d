module interpreter.env;

import std.variant : Variant;

class LispEnv
{
  LispEnv parent;
  Variant[string] vars;

  this(LispEnv parent = null)
  {
    this.parent = parent;
  }

  bool contains(string key)
  {
    if (key in vars)
      return true;
    else if (parent !is null)
      return parent.contains(key);
    else
      return false;
  }

  Variant get(string key)
  {
    if (key in vars)
      return vars[key];
    else if (parent !is null)
      return parent.get(key);
    else
      throw new Exception("Undefined symbol: " ~ key);
  }

  void set(string key, Variant value)
  {
    vars[key] = value;
  }
}
