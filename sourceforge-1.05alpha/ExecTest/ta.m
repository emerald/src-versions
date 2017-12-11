const ta <- object ta
  const aoi <- Array.of[Integer]
  const aoa <- Array.of[Any]
  var a : aoi
  var aa : aoa
  var iz : Integer
  var az : Any

  initially
    a <- aoi.create[10]
    aa <- aoa.create[10]
    a[5] <- 99
    iz <- a[5]
    for i : integer <- 0 while i < 10 by i <- i + 1
      aa[i] <- ta
      az <- aa[i]
      aa[i] <- i
      az <- aa[i]
    end for
  end initially
end ta
