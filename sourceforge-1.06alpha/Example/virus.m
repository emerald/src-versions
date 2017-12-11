const virus <- class virus
  operation doit 
    % ....
  end doit
end virus

const mover <- object mover
  process
    const all <- (locate self)$activeNodes
    for i : Integer <- 0 while i <= all.upperbound by i <- i + 1
      move virus.create to all[i]$thenode
    end for
  end process
end mover
