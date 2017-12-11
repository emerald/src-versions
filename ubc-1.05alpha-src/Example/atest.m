const Tl <- typeobject Tl
  operation a [] -> [i]
  operation b [] -> []
  operation c [] -> []
end Tl

const Tm <- typeobject Tm
  operation a [] -> [i]
  operation b [] -> []
end Tm

const i <- typeobject i
  operation a [] -> [i]
  operation b [] -> []
  operation c [] -> [Any]
end i

const foo <- immutable object foo
  export function of [a : type] -> [b : Any]
    suchthat a *> typeobject c
      operation a [] -> [c]
    end c
    
    b <- immutable object ab
      export function getSignature -> [r : Signature]
	r <- Integer.getSignature
      end getSignature
      export operation create -> [r : Any]
	r <- object foo
	end foo
      end create
    end ab
  end of
end foo

const test0 <- foo.of[Any]
const test1 <- foo.of[Tl]
const test2 <- foo.of[Tm]
