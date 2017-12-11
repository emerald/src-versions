const global <- monitor object global
  field x : Integer <- 0
  export operation inc 
    x <- x + 1
  end inc
end global
const inc <- object inc
  var ndone : Integer <- 0
  export operation doit 
    for i : Integer <- 0 while i < 1000 by i <- i + 1
      global.inc
    end for
    self.done
  end doit
  export operation done 
    ndone <- ndone + 1
    if ndone = 2 then
      stdout.putstring["Final value = "]
      stdout.putint[global$x, 0]
      stdout.putchar['\n']
    end if
  end done
end inc
const c1 <- object c1
  process
    inc.doit
  end process
end c1
const c2 <- object c2
  process
    inc.doit
  end process
end c2
