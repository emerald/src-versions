const tops <- object tops
  export operation foobar 
    
  end foobar
end tops
const topsx <- object topsx
  export operation foobar [i : Integer]
    
  end foobar
end topsx

const test <- object test
  process
    var x : Type
    topsx.foobar
    topsx.foobar[12]
    tops.foobar
    tops.foobar[12]
    const v <- Vector.of[x]
  end process
end test
