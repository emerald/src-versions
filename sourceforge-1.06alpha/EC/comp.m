
export Comp

const hasLCons <- typeobject hasLCons
  operation lcons [ Tree ]
end hasLCons

const comp <- class Comp (Tree) [xxsfname : Tree, xximports : Tree, xxexports : Tree, xxconsts : Tree]

    field st : SymbolTable
    field sfname  : Tree <- xxsfname
    field imports : Tree <- xximports
    field exports : Tree <- xxexports
    field consts  : Tree <- xxconsts
    export function upperbound -> [r : Integer]
      r <- 2
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- imports
      elseif i = 1 then
	r <- exports
      elseif i = 2 then
	r <- consts
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	imports <- r
      elseif i = 1 then
	exports <- r
      elseif i = 2 then
	consts <- r
      end if
    end setElement
    export operation copy [i : Integer] -> [r : Tree]
      var nsfname, nimports, nexports, nconsts : Tree
      if sfname !== nil then nsfname <- sfname.copy[i] end if
      if imports !== nil then nimports <- imports.copy[i] end if
      if exports !== nil then nexports <- exports.copy[i] end if
      if consts !== nil then nconsts <- consts.copy[i] end if
      r <- comp.create[ln, nsfname, nimports, nexports, nconsts]
    end copy
    operation iremoveSugar -> [r : Tree]
      var s : hasLCons
      var t : Tree
      var u : Tree
      if consts == nil then consts <- sseq.create[0] end if
      s <- view consts as hasLCons
      u <- builtinlit.create[0, 0x11]
      t <- builtinlit.create[0, 8]
      t <- invoc.create[0, t, opname.literal["getstdout"], nil]
      t <- constdecl.create[0, sym.literal["stdout"], u, t]
      s.lcons[t]
      u <- builtinlit.create[0, 0x10]
      t <- builtinlit.create[0, 8]
      t <- invoc.create[0, t, opname.literal["getstdin"], nil]
      t <- constdecl.create[0, sym.literal["stdin"], u, t]
      s.lcons[t]
      r <- self
    end iremoveSugar

    export operation doEnvExports [thest : SymbolTable]
      if imports !== nil then imports.doEnvExports[thest] end if
      if exports !== nil then exports.doEnvExports[thest] end if
      if consts !== nil then consts.doEnvExports[thest] end if
    end doEnvExports

    export operation assignIDs [thest : SymbolTable]
      if imports !== nil then imports.assignIDs[thest] end if
      if exports !== nil then exports.assignIDs[thest] end if
      if consts !== nil then consts.assignIDs[thest] end if
    end assignIDs

    export operation doAllocation 
      var a, b, c : Integer
      a, b, c <- st.Allocate[0, 0, 0, nil]
    end doAllocation

  export operation findThingsToGenerate[q : Any]
    const qt <- view q as aot
    qt.addUpper[self]
    FTree.findThingsToGenerate[q, self]
  end findThingsToGenerate

  export operation generate [ct : Printable]
    const sfnameashasStr <- view self$sfname as hasStr
    const ctasct <- view ct as ctcode
    const ove <- opvectore.create["initially"]
    const mybc <- bytecode.create[ctasct$literals]
    const ov <- ctasct$opVec
    const templ <- Template.create
    ove$templ <- templ

    ctasct$instanceSize <- self$st$instanceSize
    % Compilations are not immutable, but they do have a normal data area.
    ctasct$instanceFlags <- 0x20000000
    ctasct$filename <- sfnameashasStr.getStr
    ctasct$name <- "Compilation"
    ctasct$id <- nextOID.nextOID
    begin
      const temp <- Template.create
      ctasct$templ <- temp
      self$st.writeTemplate[temp, 'O']
    end

    % Generate the template
    self$st.writeTemplate[templ, 'L']

    ov[0] <- ove
    % Generate the prolog (allocate space for locals)
    mybc.setLocalSize[st$localSize]

    self$consts.generate[mybc]

    mybc.lineNumber[self$ln]
    mybc.addCode["QUIT"]
    mybc.addValue[0, 1]
    ove$code <- mybc.getString
    ove$others <- mybc$others
    begin
      const lninfo <- mybc.getLNInfo
      if lninfo !== nil then
	templ.addLineNumbers[lninfo]
      end if
    end
  end generate

  export operation defineSymbols[pst : SymbolTable]
    if self$st == nil then
      self$st <- SymbolTable.create[pst, CComp]
      self$st$myTree <- self
    end if
    FTree.defineSymbols[self$st, self]
  end defineSymbols

  export operation resolveSymbols [pst : SymbolTable, nexp : Integer]
    FTree.resolveSymbols[self$st, self, 0]
  end resolveSymbols

  export operation removeSugar [ob : Tree] -> [r : Tree]
    r <- self.iremoveSugar[]
    r <- FTree.removeSugar[r, ob]
  end removeSugar

  export function asString -> [r : String]
    r <- "comp"
  end asString
end Comp
