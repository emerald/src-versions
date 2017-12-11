const parent <- class parent
  export operation foo [a : Integer]
    (locate self)$stdout.putstring["p - foo[1]\n"]
  end foo
  export operation foo [a : Integer, b : Integer]
    (locate self)$stdout.putstring["p - foo[2]\n"]
  end foo
end parent
const child <- class child (parent)
  export operation foo [a : Integer]
    (locate self)$stdout.putstring["c - foo[1]\n"]
  end foo
end child

const junk <- object junk
  process
    const p <- parent.create
    const c <- child.create
    p.foo[1]
    p.foo[1,1]
    c.foo[1]
    c.foo[1,1]
  end process
end junk
