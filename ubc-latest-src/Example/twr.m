const twr <- object twr
  initially
    const x <- view stdout as OutStream
    x.writeint[1,2+4]
  end initially
end twr
