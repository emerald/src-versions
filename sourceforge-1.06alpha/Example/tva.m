const tva <- object tva
  initially
    const voi <- Vector.of[Integer]
    const aoi <- Array .of[Integer]

    const avoi <- voi.create[10]
    const aaoi <- aoi.create[10]

    const limit <- 100000

    var x : Integer
    var i : Integer <- 0

    loop
      exit when i > limit
      x <- aaoi[4]
      i <- i + 1
    end loop
  end initially
end tva
