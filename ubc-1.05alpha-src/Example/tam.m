const initialObject <- object initialObject
  const home <- locate self
  const all <- home.getActiveNodes
  var there : Node
  var stringParam : String <- ""
  var tempString : String <- "aaaaaaaaaaaaaaaa"
  const repetitions <- 5000

  const remote <- object remote
    export operation blank[param: String]
    end blank
  end remote

  process
    for i : Integer <- 1 while i <= 250 by i <- i + 1
      stringParam <- stringParam || tempString
    end for
    there <- all[1]$theNode
    move remote to there
    const send1 <- object send1
      process
	for i : Integer <- 0 while i < repetitions by i <- i + 1
	  remote.blank[stringParam]
	end for
	stdout.putstring["Send1 done\n"]
      end process
    end send1

    const send2 <- object send2
      process
	for i : Integer <- 0 while i < repetitions by i <- i + 1
	  remote.blank[stringParam]
	end for
	stdout.putstring["Send2 done\n"]
      end process
    end send2
  end process
end initialObject
