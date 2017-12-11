export Setq

const setq <- class Setq (Tree) [xxinner : Tree, xxparam : Tree, xxouter : Tree]
  class export operation build[out : Symbol, t : Any] -> [r : Symbol]
    const id <- out$myident
    const outer <- sym.create[0, id]
    const it <- Environment.getEnv.getITable
    const param <- sym.create[0, it.Lookup[id$name||"_p", 999]]
    const inner <- sym.create[0, id]
    const thetree <- view t as typeobject aRealTree
      function  getxsetq -> [Tree]
      operation setxsetq[Tree]
      function  getST -> [SymbolTable]
    end aRealTree
    const st <- thetree$st
    const sq <- self.create[0, inner, param, outer]
    var s : Symbol

    if thetree$xsetq == nil then
      thetree$xsetq <- seq.create[0]
    end if
    thetree$xsetq.rcons[sq]

    r <- Symbol.create[SImport, id, st]
    st.Insert[r]
    inner$mysym <- r
    outer$mysym <- out
    s <- Symbol.create[SParam, param$id, st]
    st.Insert[s]
    param$mySym <- s
  end build

  class export operation display [po : Tree]
    if po == nil then return end if
    for i : Integer <- 0 while i <= po.upperbound by i <- i + 1
      const sq : Setq <- view po[i] as Setq
      const sy <- view sq$outer as Sym
      const name <- sy$id$name
      const value <- sy$mysym$value
      const stdout <- (locate self)$stdout
%     sq.print[stdout, 2]
      stdout.putstring["  "]
      stdout.putstring[name]
      stdout.putstring[" -> "]
      if value !== nil then
	stdout.putstring[value.asString]
	stdout.putchar[' ']
	if value.asString = "oblit" or value.asString.getelement[0, 5] = "atlit" then
	  (view value as otree).printFlags[stdout]
	end if
      end if
      stdout.putchar['\n']
    end for
  end display

    field inner : Tree <- xxinner
    field param : Tree <- xxparam
    field outer  : Tree <- xxouter
    export function upperbound -> [r : Integer]
      r <- 2
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- inner
      elseif i = 1 then
	r <- param
      elseif i = 2 then
	r <- outer
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	inner <- r
      elseif i = 1 then
	param <- r
      elseif i = 2 then
	outer <- r
      end if
    end setElement

    export operation getIsNotManifest -> [r : Boolean]
      r <- true
      if (view inner as Sym)$mysym$isNotManifest then
	const outervalue : Tree <- view (view outer as Sym)$mysym$value as Tree
	if outervalue !== nil and nameof outervalue = "anoblit" then
	  const outerobject <- view outervalue as typeobject t 
	    function getIsExported -> [Boolean]
	  end t
	  if outerobject$isExported then
	    r <- false
	  end if
	end if
      else
	r <- false
      end if
    end getIsNotManifest

    export operation findManifests -> [changed : Boolean]
      changed <- false
      if ! inner$isNotManifest then
	if outer$isNotManifest then
	  inner$isNotManifest <- true
	  param$isNotManifest <- true
	  changed <- true
	else
	  const t <- view inner as Sym
	  const u <- view outer as Sym
	  if t$mysym$value == nil then
	    t$mysym$value <- u$mysym$value
	  end if
	end if
      end if
    end findManifests

    export operation evaluateManifests
      if ! inner$isNotManifest then
	const t <- view inner as Sym
	const u <- view outer as Sym
	if t$mysym$value == nil then
	  t$mysym$value <- u$mysym$value
	  if t$mysym$value == nil then
	    const env <- Environment.getEnv
	    env.pass["\"%s\", line %d: Need another pass for setq \"%S\"\n", 
	      {env$fn, t$ln, t$id}]
	    env$needMoreEvaluateManifest <- true
	  end if
	end if
      elseif ! self$isNotManifest then
	% We have an import of an exported not really manifest symbol.
	% We need to treat it as manifest.
	const ins <- view inner as Sym
	const ous <- view outer as Sym
	const pas <- view param as Sym
	ins$isNotManifest <- false
	ous$isNotManifest <- false
	pas$isNotManifest <- false
      end if
    end evaluateManifests

    export operation assignTypes
      const i <- view inner as Sym
      const o <- view outer as Sym
      i$mysym$ATinfo <- o$mysym$ATinfo
    end assignTypes

    export operation copy [i : Integer] -> [r : Tree]
      var ninner, nparam, nouter : Tree
      if inner !== nil then ninner <- inner.copy[i] end if
      if param !== nil then nparam <- param.copy[i] end if
      if outer !== nil then nouter <- outer.copy[i] end if
      r <- setq.create[ln, ninner, nparam, nouter]
    end copy

  export operation generate [ct : Printable]
  end generate

  export function asString -> [r : String]
    r <- "setq"
    if self$inner !== nil and self$inner$isNotManifest then
      r <- r || " (nonManifest)"
    end if
  end asString
end Setq
