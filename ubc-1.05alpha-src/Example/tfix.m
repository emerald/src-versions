const tmove <- object tmove
  initially
    const foo <- array.of[Any].empty
    foo.addupper[self]
    fix self at self
    unfix self
    refix self at self
    move self to self
    assert locate self == nil
    
    fix foo[0] at foo[0]
    move foo[0] to foo[0]
    unfix foo[0]
    refix foo[0] at foo[0]

    stdout.putstring[isfixed foo[0].asString]
    stdout.putchar['\n']

    unavailable [x]
      stdout.putstring["Unavailable\n"]
    end unavailable
    failure
      stdout.putstring["Failure\n"]
    end failure
  end initially
end tmove
