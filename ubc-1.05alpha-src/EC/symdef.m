export Symdef

const symdef <- immutable object Symdef
  const x <- 1
  export operation create [ln : Integer, id : Ident] -> [r : Sym]
    r <- Sym.create[ln, id]
  end create
end Symdef
