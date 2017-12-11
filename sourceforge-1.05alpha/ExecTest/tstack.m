const tstack <- object tstack
  const myTest <- runtest.create[stdin, stdout, "tstack"]
  const fact <- immutable object fact
    export function orial [n : Integer] -> [r : Integer]
      var x : Integer
      if n <= 0 then
	r <- 1
      else
	r <- n * self.orial[n - 1]
      end if
    end orial
  end fact
  
  initially
    var f1, f2 : Integer
    f1 <- fact.orial[100]
    f2 <- fact.orial[100]
    myTest.check[f1 == f2, "f1 == f2"]
    myTest.done
  end initially
end tstack
