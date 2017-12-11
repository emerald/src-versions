export Primstat

const primstat <- class Primstat (Tree) [xxself : Tree, xxvar : Tree, xxnumber : Tree, xxvars : Tree, xxvals : Tree]
    field xself  : Tree <- xxself
    field xvar   : Tree <- xxvar
    field number : Tree <- xxnumber
    field vars   : Tree <- xxvars
    field vals   : Tree <- xxvals

    export function upperbound -> [r : Integer]
      r <- 4
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- xself
      elseif i = 1 then
	r <- xvar
      elseif i = 2 then
	r <- number
      elseif i = 3 then
	r <- vars
      elseif i = 4 then
	r <- vals
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	xself <- r
      elseif i = 1 then
	xvar <- r
      elseif i = 2 then
	number <- r
      elseif i = 3 then
	vars <- r
      elseif i = 4 then
	vals <- r
      end if
    end setElement
    export operation copy [i : Integer] -> [r : Tree]
      var nxself, nxvar, nnumber, nvars, nvals : Tree
      if xself !== nil then nxself <- xself.copy[i] end if
      if xvar !== nil then nxvar <- xvar.copy[i] end if
      if number !== nil then nnumber <- number.copy[i] end if
      if vars !== nil then nvars <- vars.copy[i] end if
      if vals !== nil then nvals <- vals.copy[i] end if
      r <- primstat.create[ln, nxself, nxvar, nnumber, nvars, nvals]
    end copy

    export operation typeCheck
      if vars !== nil then
	for i: Integer <- 0 while i <= vars.upperbound by i <- i + 1
	  const lv <- view vars[i] as Sym
	  const thesym <- lv$mysym
	  const thekind <- thesym$mykind
	  if thekind = SConst or thekind = SParam then
	    Environment$env.SemanticError[ln, "Attempt to store into constant symbol %S", { thesym$myident }]
	  end if
	end for
      end if
      FTree.typeCheck[self]
    end typeCheck

    export operation generate [x : Printable]
      const bc <- view x as ByteCode
      const hasGenerateLValue <- typeobject hasGenerateLValue
	operation generateLValue[Printable]
      end hasGenerateLValue
      var lv : hasGenerateLValue
      var first : String
      var instSize : Integer <- 0
      const thisobj <- (view Environment$env as hasThisObject)$thisObject
      if nameof thisobj = "anoblit" then
	instSize <- (view thisObj as hasInstSize)$instanceSize  
      end if
      bc.lineNumber[self$ln]
      bc$usedPrimitive <- true

      if xvar !== nil then
	% all things are assumed vars
	bc.pushSize[8]	
      else
	bc.pushSize[4]
      end if
      if xself !== nil then
	% generate self
	if bc$size = 4 then
	  bc.addCode["LDSELF"]
	else
	  bc.addCode["LDSELFV"]
	end if
      end if

      if instSize == ~8 then
	if number !== nil then
	  first <- (view number[0] as hasStr)$str
	  if first = "SET" then
	    assert vals.upperbound = 1
	    vals[0].generate[x]
	    bc.pushSize[8]
	    vals[1].generate[x]
	    bc.popSize
	  else
	    % generate the vals on the stack
	    if vals !== nil then vals.generate[x] end if
	  end if
	else
	  % generate the vals on the stack
	  if vals !== nil then vals.generate[x] end if
	end if
      else
	% generate the vals on the stack
	if vals !== nil then vals.generate[x] end if
      end if
      
      if number !== nil then
	const limit <- number.upperbound
	for i : Integer <- 0 while i <= limit by i <- i + 1
	  const v <- view number[i] as hasStr
	  const s : String <- v$str
	  if s[0] >= '0' and s[0] <= '9' then
	    const primno <- Integer.Literal[s]
	    bc.addValue[primno, 1]
	  else
	    if s = "SET" and instSize = ~8 then
	      bc.addCode["SETV"]
	    elseif s = "GET" and instSize = ~8 then
	      bc.addCode["GETV"]
	    else
	      bc.addCode[s]
	      if s = "LDIS" then
		bc.alignTo[2]
	      end if
	    end if
	  end if

	end for
      end if

      % store the results back to the vars
      % This has to go backwards through the vars
      if vars !== nil then
	for i: Integer <- vars.upperbound while i >= 0 by i <- i - 1
	  lv <- view vars[i] as hasGenerateLValue
	  if instSize = ~8 and first = "GET" then
	    bc.pushSize[8]
	    lv.generateLValue[bc]
	    bc.popSize
	  else
	    lv.generateLValue[bc]
	  end if
	end for
      end if
      bc.popSize
    end generate

  export function asString -> [r : String]
    r <- "primstat"
  end asString
end Primstat
