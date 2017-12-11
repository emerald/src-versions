const trread <- object trread
  var f : InStream
  process
    f <- InStream.FromUnix["/tmp/whatever", "r"]
    const here <- locate self
    const allhosts <- here.getActiveNodes
    move self to allhosts[1]$theNode
    loop
      exit when f.eos
      const s <- f.getString
      (locate self)$stdout.putstring[s]
      move f to self
    end loop
    f.close
  end process
end trread
