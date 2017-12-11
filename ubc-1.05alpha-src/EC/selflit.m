
export Selflit

const selflit <- class Selflit (Tree)
  field myobject : ObLit

  export function upperbound -> [r : Integer]
    r <- 0
  end upperbound

  export operation copy [i : Integer] -> [r : Tree]
    r <- selflit.create[ln]
  end copy

  export operation removeSugar [ob : Tree] -> [r : Tree]
    if ob == nil then
      Environment$env.SemanticError[self$ln, "selfliteral outside of object", nil]
    end if
    myobject <- view ob as ObLit
    r <- self
  end removeSugar

  export function getAT -> [r : Tree]
    r <- myobject$name.getAT
  end getAT

  export function getCT -> [r : Tree]
    r <- myobject$name.getCT
  end getCT
    
  export operation getIsNotManifest -> [r : Boolean]
    r <- myobject$name.getIsNotManifest
  end getIsNotManifest
  
  export operation setIsNotManifest [r : Boolean]
    myobject$name.setIsNotManifest[r]
  end setIsNotManifest
  
  export function getCodeOID -> [oid : Integer]
    oid <- (view myobject$name as hasIDs).getCodeOID
  end getCodeOID

  export function asType -> [r : Tree]
    r <- myobject$name.asType
  end astype
  
  export operation execute -> [r : Tree]
    r <- myobject$name.execute
  end execute

  export operation generate[xct : Printable]
    const bc <- view xct as ByteCode
    if bc$size = 4 then
      bc.addCode["LDSELF"]
    else
      bc.addCode["LDSELFV"]
    end if
  end generate

  export function asString -> [r : String]
    r <- "selflit"
  end asString
end Selflit
