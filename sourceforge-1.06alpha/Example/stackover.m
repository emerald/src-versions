const tstack <- object tstack
  const fact <- object fact
    export function orial [n : Integer] -> [r : Integer]
      stdout.putint[n, 0]
      stdout.putchar['\n']
      if n <= 0 then
	r <- 1
      else
	r <- n * self.orial[n - 1]
      end if
      stdout.putint[n, 0]
      stdout.putchar['\n']
    end orial
  end fact
  
  initially
    var f1 : Integer
    f1 <- fact.orial[3000]
  end initially
end tstack
