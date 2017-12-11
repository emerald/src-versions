const first <- object first
  operation nothinginteresting [a : integer, b : Integer] -> [c : Integer]
    const junk <- { a, 1, 2, 3, 4, 5 : Integer}
    c <- a + b
  end nothinginteresting
  process
    var i : Integer <- 1
    const limit : Integer <- 1000000
    var junk : Any
    loop
      exit when i > limit
      junk <- self.nothinginteresting[23, 45]
      i <- i + 1
    end loop
  end process
end first
