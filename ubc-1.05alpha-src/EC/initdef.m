export Initdef

const initdef <- class Initdef (Tree) [xxbody : Tree]
    field body : Tree <- xxbody

    export function upperbound -> [r : Integer]
      r <- 0
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- body
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	body <- r
      end if
    end setElement
    export operation copy [i : Integer] -> [r : Tree]
      var nbody : Tree
      if body !== nil then nbody <- body.copy[i] end if
      r <- initdef.create[ln, nbody]
    end copy

  export operation generateInitially [ct : Printable]
    self.generate[ct]
  end generateInitially

  export function asString -> [r : String]
    r <- "initdef"
  end asString
end Initdef
