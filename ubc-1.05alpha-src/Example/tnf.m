const tnf <- object tnf
  const tfn <- "./nf"
  function existsAndIsNotEmpty [fn : String] -> [b : Boolean]
    const f <- InStream.fromUnix[fn, "r"]
    const c <- f.getchar
    f.close
    b <- true
    failure
      b <- false
      if f !== nil then f.close end if
    end failure
  end existsAndIsNotEmpty
  process
    stdout.putstring[tfn || ": " || self.existsAndIsNotEmpty[tfn].asString || "\n"]
  end process
end tnf
