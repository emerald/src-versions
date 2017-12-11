const Manager <- class Manager [coordinator : Any]
  export operation dostuff
    (locate self).getStdout.PutString["Manager working\n"]
  end dostuff
end Manager

const start <- object start
  process
    const all <- (locate self).getActiveNodes
    for i : Integer <- 0 while i <= all.upperbound by i <- i + 1
      const m <- Manager.create[self]
      move m to all[i].getTheNode
      all[i].getTheNode.getStdout.PutString["Created manager here\n"]
      m.dostuff
    end for
  end process
end start
