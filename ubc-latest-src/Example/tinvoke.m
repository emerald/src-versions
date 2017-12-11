const target <- immutable object target
  const targetType <- typeobject t
    operation op2 [integer] -> [integer]
    operation op1 [integer] -> [integer]
  end t
  export function getSignature -> [r : Signature]
    r <- targetType
  end getSignature
  export operation create -> [r : targetType]
    r <- object aTarget
      export operation op1 [x : integer] -> [y : integer]
	y <- x + x
      end op1
      export operation op2 [x : integer] -> [y : integer]
	y <- x + x
      end op2
    end aTarget
  end create
end target

const invoker <- object invoker
  initially
    var tar : Target <- target.create
    const t <- tar.op1[tar.op2[5]]
    stdout.putint[t, 0]
    stdout.putchar['\n']
  end initially
end invoker
