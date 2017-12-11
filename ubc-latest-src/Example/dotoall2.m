const Manager <- class Manager [coordinator : Any]
  export operation dostuff
    (locate self).getStdout.PutString["Manager working\n"]
  end dostuff
end Manager

const start <- object start
  process
    const all <- (locate self).getActiveNodes
    for i : Integer <- 0 while i <= all.upperbound by i <- i + 1
      move self to all[i].getTheNode
      (locate self).getStdout.PutString["Created manager here\n"]
      const m <- Manager.create[self]
      m.dostuff
    end for
  end process
end start
