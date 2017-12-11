export newid

const newid <- immutable object newid
  const count <- object count
      var i : Integer <- 0
      export operation newid -> [r : Integer]
	r <- i
	i <- i + 1
      end newid
      export operation reset
	i <- 0
	i <- 0
      end reset
  end count
  export operation newid -> [r : Ident]
    const it : IdentTable <- Environment.getEnv.getITable
    r <- it.lookup["_$"||count.newid.asString, 999]
  end newid
  export operation reset
    count.reset
  end reset
end newid
