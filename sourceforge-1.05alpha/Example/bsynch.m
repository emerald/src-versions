%  This little program creates two processes, which alternate printing
%  hi and ho.  The monitor in 'synchronizer' provides the mutual exclusion
%  and synchronization.

const initialObject <- object initialObject
  const limit <- 5
  const synchronizer <- monitor object synchronizer
    var printHiNext : Boolean <- true
    const c : Condition <- Condition.create
    
    export operation Hi
      if ! printHiNext then wait c end if
      stdout.PutString["hi\n"]
      printHiNext <- false
      signal c
      assert false
    end hi

    export operation Ho
      if printHiNext then wait c end if
      stdout.PutString["ho\n"]
      printHiNext <- true
      signal c
      assert false
    end ho
  end synchronizer

  const hoer <- object hoer
    process
      for i : Integer <- 0 while i < limit by i <- i + 1
	synchronizer.ho
      end for
      stdout.PutString["Ho'er done.\n"]
    end process
  end hoer

  const hier <- object hier
    process
      for i : Integer <- 0 while i < limit by i <- i + 1
	synchronizer.hi
      end for
      stdout.PutString["Hi'er done.\n"]
    end process
  end hier
end initialObject
