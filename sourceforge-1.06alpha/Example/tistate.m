const tistate <- object tistate
  operation dosome [x : Integer]
    var is : InterpreterState
    if x = 0 then
      primitive "GETISTATE" [is] <- []
      self.printIState[is]
    else
      self.dosome[x - 1]
    end if
  end dosome
  operation printIState [is : InterpreterState]
    stdout.putstring["PC = "]
    stdout.putint[is$pc, 0]
    stdout.putchar['\n']
    stdout.putstring["SP = "]
    stdout.putint[is$sp, 0]
    stdout.putchar['\n']
    stdout.putstring["FP = "]
    stdout.putint[is$fp, 0]
    stdout.putchar['\n']
    stdout.putstring["SB = "]
    stdout.putint[is$sb, 0]
    stdout.putchar['\n']
    stdout.putstring["O is an "]
    stdout.putstring[nameof is$o]
    stdout.putchar['\n']
    if is$e !== nil then
      stdout.putstring["E is an "]
      stdout.putstring[nameof is$e]
      stdout.putchar['\n']
    end if
  end printIState
  process
    self.dosome[3]
  end process
end tistate
