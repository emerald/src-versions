export Opname

const opname <- immutable object Opname
  export operation literal [s : String] -> [r : Ident]
    r <- Environment.getEnv.getITable.lookup[s, 999]
  end literal
end Opname
