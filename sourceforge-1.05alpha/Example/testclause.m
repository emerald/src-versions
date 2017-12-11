const testclause <- object testclause
  export function identity[a : t] -> [b : t]
    forall t
    b <- a
  end identity

  export function makeVector[arg : argType] -> [res : resType]
    forall argType
    where resType <- Vector.of[argType]

    res <- resType.create[10]
    for i : Integer <- 0 while i < 10 by i <- i + 1
      res[i] <- arg
    end for
  end makeVector

  export function inOrder[t : Type, a : t, b : t, c : t] -> [r : Boolean]
    suchthat t *> typeobject comparable
      function <= [comparable] -> [Boolean]
    end comparable

    r <- a <= b % and b <= c
  end inOrder

  export function inOrderImplicit[a : t, b : t, c : t] -> [r : Boolean]
    forall t
    suchthat t *> typeobject comparable
      function <= [comparable] -> [Boolean]
    end comparable

    r <- a <= b % and b <= c
  end inOrderImplicit

end testclause

const tester <- object tester
  initially
    const a : Integer <- testclause.identity[4]
    const b : String <- testclause.identity["abc"]
    const c : Vector.of[Integer] <- testclause.makeVector[4]
    const d : Vector.of[String] <- testclause.makeVector["abc"]
    const e : Boolean <- testclause.inOrder[Integer, 3, 4, 5]
    const f : Boolean <- testclause.inOrder[String, "abc", "def", "ghi"]
    const g : Boolean <- testclause.inOrderImplicit[3, 4, 5]
    const h : Boolean <- testclause.inOrderImplicit["abc", "def", "ghi"]
  end initially
end tester
