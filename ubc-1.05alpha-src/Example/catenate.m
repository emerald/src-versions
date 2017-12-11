const test <-
  object test
  
    var a1,a2,a3 : array.of[string]
    var i : integer
    
    process
      for(i <- 0: i <= 10: i <- i+1)
        a1.addupper[i.asstring]
      end for
      a2 <- a1[a1.lowerbound,3]
      a3 <- a1[a1.lowerbound+3+1,a1.upperbound-a1.lowerbound-3]
      a1 <- a2.catenate[a3]
      for(i<- a2.lowerbound: i <= a2.upperbound: i <- i+1)
        stdout.putstring[a2[i]||"\n"]
      end for  
      stdout.putstring["\n"]
      for(i<- a3.lowerbound: i <= a3.upperbound: i <- i+1)
        stdout.putstring[a3[i]||"\n"]
      end for  
      stdout.putstring["\n"]
      for(i<- a1.lowerbound: i <= a1.upperbound: i <- i+1)
        stdout.putstring[a1[i]||"\n"] 
      end for
    end process
    
    initially
      a1 <- array.of[string].empty
      a2 <- array.of[string].empty
      a3 <- array.of[string].empty
    end initially
  end test
