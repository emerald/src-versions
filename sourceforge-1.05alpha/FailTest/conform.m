const tconforms <- object tconforms
  const recType <- immutable record rec
    var x : Integer
  end rec
  process
    var arec : recType
    arec <- immutable object rudolph
    end rudolph
    arec <- immutable object harry
      export function getx -> [r : Real]
	r <- 1.0
      end getx
    end harry
    arec <- object sally
      export function getx -> [ r : Integer ]
	r <- 1.0
      end getx
    end sally
    arec <- object billy
      export operation getx -> [ r : Integer ]
	r <- 1
      end getx
    end billy
    arec <- object mary
      export function getx [ p : Integer ] -> [ r : Integer ]
	r <- p
      end getx
    end mary
  end process
end tconforms
