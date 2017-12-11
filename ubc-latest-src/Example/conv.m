const locator <- class locator [k : Integer]
  export operation getsomething -> [r : Integer]
    r <- k
  end getsomething
end locator

const driver <- object driver
  process
    const here <- locate self
    const rootdir <- here$rootdirectory
    const all <- here$activeNodes
    const locators <- Vector.of[Locator].create[all.upperbound + 1]

    const mylocator <- Locator.create[here$lnn # 0x10000]
    var otherlocator : Locator

    const fiveseconds <- Time.create[5, 0]

    here$locationServer <- mylocator

    for i : Integer <- 0 while i <= all.upperbound by i <- i + 1
      stdout.putstring["Looking for "|| i.asString || "\n"] stdout.flush
      loop
	otherlocator <- view all[i]$theNode$locationServer as Locator
	exit when otherlocator !== nil
	here.delay[fiveseconds]
      end loop
      stdout.putstring["Found "|| i.asString || " which answers with "||otherlocator$something.asString|| "\n"] stdout.flush
    end for
    stdout.putstring["All happy\n"] stdout.flush
  end process
end driver
