export ObjectTable

const ObjectTable <- immutable object ObjectTable
  const table : ITTable <- ITTable.create[517]
  export operation Lookup [id : Integer] -> [r : Tree]
    r <- table.Lookup[id]
  end Lookup
  export operation Define [id : Integer, r : Tree]
    table.Insert[id, r]
  end Define
  export operation okForNextOID [id : Integer]
    table.okForNextOID[id]
  end okForNextOID
end ObjectTable
