export Symref

const symref <- immutable object Symref
  % Don't you love lines like this next one?
  const x <- 1
  export operation create [ln : Integer, id : Ident] -> [r : Sym]
    r <- Sym.create[ln, id]
  end create
end Symref
