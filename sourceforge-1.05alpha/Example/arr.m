const Arr <- object Arr
  export operation of [eType : Type] -> [r : anArr]
    forall eType
    where
      anArr <- typeobject anArr
	function getElement[Integer]->[eType]
	operation setElement[Integer, eType]
	function upperbound -> [Integer]
	function lowerbound -> [Integer]
      end anArr
    r <- Array.of[eType].create[10]
  end of
end Arr

const tester <- object tester
  initially
    const a <- Arr.of[Integer]
    const b <- Arr.of[Character]
    for i : Integer <- 0 while i < 10 by i <- i + 1
      a[i] <- 45 + i
    end for
    for i : Integer <- 0 while i < 10 by i <- i + 1
      stdout.putstring["a["]
      stdout.putint[i, 0]
      stdout.putstring["] = "]
      stdout.putint[a[i], 0]
      stdout.putchar['\n']
    end for
    for i : Integer <- 0 while i < 10 by i <- i + 1
      b[i] <- character.literal['a'.ord + i]
    end for
    for i : Integer <- 0 while i < 10 by i <- i + 1
      stdout.putstring["b["]
      stdout.putint[i, 0]
      stdout.putstring["] = "]
      stdout.putchar[b[i]]
      stdout.putchar['\n']
    end for
    tat.create.printType[stdout, typeof a]
    tat.create.printType[stdout, typeof b]
    if typeof a == typeof b then
      stdout.putstring["Their types are the same\n"]
    else
      stdout.putstring["Their types are the different\n"]
    end if
  end initially
end tester
