const tset <- object tset
  initially
    const sc <- Set.of[Any]
    const s <- sc.create[{}]
    const t <- s.union[nil]
  end initially
end tset
