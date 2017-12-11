const moveme <- object moveme
  const here <- locate self
  const alive <- here.getActiveNodes

  % This assures that there are two stack frames in the same object that
  % need to move.
  operation domove [limit : Integer, towhere : Node]
    if limit > 0 then
      self.domove[limit - 1, towhere]
    else
      stdout.putstring["Moving out\n"]
      move self to towhere
    end if
  end domove

  process
    var outs : OutStream
    var ins  : InStream

    loop
      outs <- here$stdout
      outs.putstring["> "] outs.flush
      ins <- here$stdin
      const junk <- ins.getstring
      outs <- nil
      ins <- nil
      for j: Integer <- alive.upperbound while j >= 0 by j <- j - 1
	const thenode <- alive[j]$theNode
	self.doMove[10, thenode]
      end for
    end loop
  end process
end moveme
