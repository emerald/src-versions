export holder

const holder <- object holder
  field whatever : Any
end holder

const tmov <- object tmov
  process
    holder.setWhatever[self]
    const starting <- locate 1
    const alive <- starting.getActiveNodes
    assert alive.upperbound > 0
    const movingto <- alive[1]$theNode
    assert movingto !== starting
  
    move self to movingto
    (locate self).getStdout.putstring["Here I am\n"]
    move self to starting
    const out <- (locate self).getStdout
    if self == holder.getWhatever then
      out.putstring["I am myself\n"]
    else
      out.putstring["I am not myself\n"]
    end if
  end process
end tmov
