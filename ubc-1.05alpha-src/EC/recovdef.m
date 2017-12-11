export Recoverydef

const recoverydef <- class Recoverydef (Tree) [xxbody : Tree]
    field body : Tree <- xxbody

    export function upperbound -> [r : Integer]
      r <- 0
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- body
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	body <- r
      end if
    end setElement
    export operation copy [i : Integer] -> [r : Tree]
      var nbody : Tree
      if body !== nil then nbody <- body.copy[i] end if
      r <- recoverydef.create[ln, nbody]
    end copy

  export operation resolveSymbols [pst : SymbolTable, nexp : Integer]
    pst$inInitially <- false
    FTree.resolveSymbols[pst, self, 0]
    pst$inInitially <- true
  end resolveSymbols

  export operation generate[xct : Printable]
    const ct <- view xct as CTCode
    const ove <- opvectore.create["recovery"]
    const templ <- Template.create
    const mybc <- bytecode.create[ct$literals]
    const ov <- ct$opVec
    const bb <- view self$body as hasST

    const returnlabel <- mybc.declareLabel
    ove$templ <- templ
    mybc.nest[returnlabel]

    ov[2] <- ove
    % Generate the template
    bb$st.writeTemplate[templ, 'L']

    mybc.setLocalSize[bb$st$localSize]

    self$body.generate[mybc]

    mybc.lineNumber[self$ln]
    mybc.defineLabel[returnlabel]
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

  export function asString -> [r : String]
    r <- "recoverydef"
  end asString
end Recoverydef
