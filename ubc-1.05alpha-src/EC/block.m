export Block

const block <- class Block (Tree) [xxstats : Tree, xxunavailablehandler : Tree, xxfailurehandler : Tree]
    field stats : Tree <- xxstats
    field unavailablehandler : Tree <- xxunavailablehandler
    field failurehandler  : Tree <- xxfailurehandler
    field st  : SymbolTable

    export function upperbound -> [r : Integer]
      r <- 2
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- stats
      elseif i = 1 then
	r <- unavailablehandler
      elseif i = 2 then
	r <- failurehandler
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	stats <- r
      elseif i = 1 then
	unavailablehandler <- r
      elseif i = 2 then
	failurehandler <- r
      end if
    end setElement
    export operation copy [i : Integer] -> [r : Tree]
      var nstats, nunavailablehandler, nfailurehandler : Tree
      if stats !== nil then nstats <- stats.copy[i] end if
      if unavailablehandler !== nil then 
	nunavailablehandler <- unavailablehandler.copy[i] end if
      if failurehandler !== nil then
	nfailurehandler <- failurehandler.copy[i] end if
      r <- block.create[ln, nstats, nunavailablehandler, nfailurehandler]
    end copy

  export operation defineSymbols[pst : SymbolTable]
    self$st <- SymbolTable.create[pst, CBlock]
    self$st$myTree <- self
    FTree.defineSymbols[self$st, self]
  end defineSymbols

  export operation resolveSymbols [pst : SymbolTable, nexp : Integer]
    FTree.resolveSymbols[self$st, self, 0]
  end resolveSymbols

  export operation generate [xct : Printable]
    const ct <- view xct as ByteCode
    
    var fh : HandlerRecord
    var uh : HandlerRecord
    const label : Integer <- ct.fetchnest
    if false and label !== nil and (failurehandler !== nil or unavailablehandler !== nil)then
      Environment.getEnv.SemanticError[ln, "Failure/Unavailable handers in loops are not supported", nil]
    end if

    if failurehandler !== nil then
      fh <- ct.beginHandlerBlock[failurehandler]
    end if
    if unavailablehandler !== nil then
      uh <- ct.beginHandlerBlock[unavailablehandler]
      uh$name <- 1
      if unavailablehandler[0] !== nil then
	const thesym : Symbol <- (view unavailablehandler[0][0] as Sym)$mysym
	uh$varOffset <- thesym$offset
      end if
    end if
    stats.generate[xct]
    if uh !== nil then ct.endHandlerBlock end if
    if fh !== nil then ct.endHandlerBlock end if
  end generate

  export function asString -> [r : String]
    r <- "block"
  end asString
end Block
