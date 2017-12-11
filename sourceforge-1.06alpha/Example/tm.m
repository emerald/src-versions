export o1
export o2

const o1 <- object o1
  initially
  end initially
  process
    move self to (locate self)$activeNodes[1]$thenode
    o2.foo
  end process
end o1

const o2 <- object o2
  export operation foo 
    (locate self)$stdout.putstring["hi\n"]
  end foo
end o2
