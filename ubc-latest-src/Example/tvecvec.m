const Builtins <- immutable object Builtins
  const x <- 1
  export operation init [out : OutStream]
    const names <- {
	"abstracttype",
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
	"risc",
	"handler",
	"vectorofchar",
	"buffer",
	"concretetype",
	"copvector",
	"copvectore",
	"aopvector",
	"aopvectore",
	"aparamlist" }
    var s : String

    for i : Integer <- 0 while i <= names.upperbound by i <- i + 1
      s <- names[i]
      out.putstring[s]
      out.putchar['\n']
    end for
  end init
end Builtins


const foo <- object foo
  initially
    builtins.init[stdout]
  end initially
end foo
