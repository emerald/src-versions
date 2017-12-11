% This little program creates two processes, which alternate creating
% objects.  This is supposed to test the interaction of the process management
% and the garbage collection.

const initialObject <- object initialObject
  const synchronizer <- monitor object synchronizer
    var doHiNext : Boolean <- true
    const c : Condition <- Condition.create
    
    export operation makeHi [junk : Any] -> [one : Any]
      if ! doHiNext then wait c end if
      one <- object fred
	var a : Any <- junk
	var b,c,d,e,f,g,h,i,j: Any
      end fred
      doHiNext <- ! doHiNext
      signal c
    end makeHi

    export operation makeHo [junk : Any] -> [one : Any]
      if doHiNext then wait c end if
      one <- object fred
	var a : Any <- junk
	var b,c,d,e,f,g,h,i,j: Any
      end fred
      doHiNext <- ! doHiNext
      signal c
    end makeHo
  end synchronizer

  const hoer <- object hoer
    process
      const inside : Integer <- 10000
      const outside : Integer <- 100
      var junk : Any
      for i : Integer <- 0 while i < outside by i <- i + 1
	junk <- nil
	for j : Integer <- 0 while j < inside by j <- j + 1
	  junk <- synchronizer.makeHo[junk]
	end for
	stdout.putchar['o'] stdout.flush
      end for
    end process
  end hoer

  const hier <- object hier
    process
      const inside : Integer <- 10000
      const outside : Integer <- 100
      var junk : Any
      for i : Integer <- 0 while i < outside by i <- i + 1
	junk <- nil
	for j : Integer <- 0 while j < inside by j <- j + 1
	  junk <- synchronizer.makeHi[junk]
	end for
	stdout.putchar['i'] stdout.flush
      end for
    end process
  end hier
end initialObject
