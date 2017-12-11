const trread <- object trread
  var f : InStream
  const buf <- Vector.of[Character].create[8*1024]
  var totalread : Integer <- 0
  var starttime, diff : Time
  process
    f <- InStream.FromUnix["/spare/norm/ae.t.b", "r"]
    const here <- locate self
%    const allhosts <- here.getActiveNodes
%    move self to allhosts[1]$theNode
    starttime <- here.getTimeOfDay
    loop
      exit when f.eos
      const nread <- f.rawRead[buf]
      totalread <- totalread + nread
    end loop
    f.close
    diff <- here.getTimeOfDay - starttime
    stdout.putstring["Read "||totalread.asString||" bytes in "||diff.asString||" seconds\n"]
    const bandwidth <- totalread.asReal / 1048576.0 / (diff$seconds.asReal + diff$microseconds.asReal/1000000.0)
    stdout.putstring["Read at "||bandwidth.asString||" MBytes/second\n"]    
  end process
end trread
