const Sieve <- class Sieve
  var next : Sieve
  var myprime : Integer
  export operation filter [n : Integer] -> [isPrime : Boolean]
    if myprime == nil then
      myprime <- n
      isPrime <- true
    elseif n # myprime = 0 then
      isPrime <- false
    else
      if next == nil then
	next <- Sieve.create
      end if
      isPrime <- next.filter[n]
    end if
  end filter
end Sieve

const driver <- object driver
  initially
    const s <- Sieve.create
    const limit <- 10000
    for i : Integer <- 2 while i < limit by i <- i + 1
      if s.filter[i] then
	stdout.putint[i, 0]
	stdout.putchar['\n']
      end if
    end for
  end initially
end driver
