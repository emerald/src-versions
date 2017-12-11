const taxx <- object taxx
  process
    const a <- Array.of[Integer].create[-4]
    a.addupper[1]
    a.addupper[2]
    for i : Integer <- a.lowerbound while i <= a.upperbound by i <- i + 1
    end for
  end process
end taxx
