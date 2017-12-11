const foo <- object foo
  export operation nothing 
    (locate self)$stdout.putstring["Nothing running\n"]
  end nothing
  initially
    move self to (locate self)$activeNodes[1]$theNode
  end initially
end foo
const bar <- object bar
  process
    foo.nothing
  end process
end bar
