%  This little program creates two processes, which alternate printing
%  hi and ho.  The monitor in 'synchronizer' provides the mutual exclusion
%  and synchronization.

const initialObject <- object initialObject
  const limit <- 5
  const here <- locate self
  const there <- (here.getActiveNodes)[1]$thenode

  const synchronizer <- monitor object synchronizer
    var printHiNext : Boolean <- true
    attached const c : Condition <- Condition.create
    
    export operation Hi
      if ! printHiNext then wait c end if
      (locate self)$stdout.PutString["hi\n"]
      printHiNext <- false
      signal c
    end hi

    export operation Ho
      if printHiNext then wait c end if
      (locate self)$stdout.PutString["ho\n"]
      printHiNext <- true
      signal c
    end ho
  end synchronizer

  const hoer <- object hoer
    process
      for i : Integer <- 0 while i < limit by i <- i + 1
	synchronizer.ho
      end for
      here$stdout.PutString["Ho'er done.\n"]
    end process
  end hoer

  const hier <- object hier
    process
      for i : Integer <- 0 while i < limit by i <- i + 1
	synchronizer.hi
      end for
      here$stdout.PutString["Hi'er done.\n"]
    end process
  end hier

  initially
    move synchronizer to there
  end initially
end initialObject
