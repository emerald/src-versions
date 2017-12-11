% tlocate.m

const locator <- object locator

  const foo <- object foo
  end foo

  process
    const here <- (locate 1)
    const all <- here.getActiveNodes
    for i : Integer <- all.lowerbound while i <= all.upperbound by i <- i + 1
      stdout.putstring["Checking "]
      stdout.putint[i, 0]
      stdout.putstring["\n"]
      const thenode <- all[i].getthenode
      const thenodesplace <- locate thenode
      assert thenode == thenodesplace
      assert locate thenode.getName == here
      move foo to thenode
      assert locate foo == thenode
      stdout.putstring["Moved to "||(locate foo)$name||"\n"]
    end for
    stdout.putstring["done\n"]
  end process
end locator

% EOF
