const moveme <- object moveme
  const here <- locate self
  const alive <- here.getActiveNodes

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
	move self to thenode
      end for
    end loop
  end process
end moveme
