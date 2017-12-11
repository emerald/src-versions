import Tree, FTree, Printable from "Jekyll"
import Symbol, SymbolTable, STContext, STKind from "Jekyll"
import Environment from "Jekyll"
import Builtinlit from "Jekyll"
export builtins to "Jekyll"

const Builtins <- immutable object Builtins
  const names <- {
      "type",
      "any",
      "array",
      "boolean",
      "character",
      "condition",
      "integer",
      "none",
      "node",
      "signature",
      "real",
      "string",
      "vector",
      "time",
      "nodelistelement",
      "nodelist",
      "instream",
      "outstream",
      "immutablevector",
      "bitchunk",
      "sequenceofcharacter",
      "handler",
      "vectorofchar",
      "buffer",
      "concretetype",
      "copvector",
      "copvectore",
      "aopvector",
      "aopvectore",
      "aparamlist",
      "vectorofint" }

  export operation getName [index : Integer] -> [name : String]
    if 0 <= index and index <= names.upperbound then
      name <- names(index)
    end if
  end getName

  export operation init -> [r : SymbolTable]
    var ss : Symbol
    const it <- Environment.getEnv.getITable

    r <- SymbolTable.create[nil, STContext.COutside]
    for i : Integer <- 0 while i <= names.upperbound by i <- i + 1
      ss <- r.Define[ln, it.lookup[names(i), 999], STKind.SConst, false]
      ss$value <- builtinlit.create[0, i]
    end for
  end init
end Builtins
