%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	          The eventually consistent directory gaggle                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

const DirectoryGaggle <- immutable class DirectoryGaggle (Gaggle) 
  
  class const memberType <- Directory
  
  export operation instantiate[newMember: Directory]
    var size: Integer
    
    primitive self var "GETGAGGLESIZE"[size]<-[]
    if size = 0 then
      self.addMember[newMember]
    else
      const n <- self.list
      for i: Integer <-0 while i <= n.upperBound by i <- i+1
        newMember.insert[n[i], self.lookup[n[i]]]
      end for
      self.addMember[newMember]	
    end if
  end instantiate

  export operation lock
    var size: Integer
    primitive self var "GETGAGGLESIZE"[size]<-[]
    
    for i : Integer <- 0 while i < size by i <- i + 1
      var gotLock : Integer <-0
      var waitTime: Integer <-0
         
      const gid <- self.invokee[i]
      loop
	begin
          gotLock<-gid.lock[]
	  unavailable
	    gotLock <- 1  
	    (locate self)$stdout.PutString["Gaggle Member cannot be locked 
            probably because of the failure of its server \n"]
	  end unavailable
	end
	exit when ((gotLock=1)or(waitTime>100000))
	waitTime<-waitTime+1
      end loop
      if gotLock != 1 then
	for j: Integer <-0 while j < i by j <- j+1
	  const mid <- self.invokee[j]
	  begin
            mid.release[]
            unavailable
              (locate self)$stdout.PutString["Gaggle Member cannot be locked 
              probably because of the failure of its server \n"]
            end unavailable
          end
        end for
        i <- -1
      end if
   end for
 end lock
  
  export operation insert[n: String, v: Any]->[]
    var size: Integer
    primitive self var "GETGAGGLESIZE"[size]<-[]
    
    self.lock[]
    for i : Integer <- 0 while i < size by i <- i + 1
      const gid <- self.invokee[i]
      begin
        gid.insert[n, v]
        gid.release[]
        unavailable
	  (locate self)$stdout.PutString["Gaggle Member cannot be updated 
          probably because of the failure of its server \n"]
        end unavailable
      end
    end for
  end insert
  
  export operation delete[n: String]
    var size: Integer
    primitive self var "GETGAGGLESIZE"[size]<-[]
    
    self.lock[]
    
    for i : Integer <- 0 while i < size by i <- i + 1
      const gid <- self.invokee[i] 
      begin
	gid.delete[n]
      	gid.release[]
        unavailable
	  (locate self)$stdout.PutString["Gaggle Member cannot be updated 
           probably because of the failure of its server \n"]
        end unavailable
      end
    end for
  end delete
  
  export function lookup[n: String]->[v:Any]
    var size, j: Integer
    var s: String
    
    primitive self var "GETGAGGLESIZE"[size]<-[]
    const check <- Array.of[Any].create[size]
    
    for i : Integer <- 0 while i < size by i <- i + 1
      const gid <- self.invokee[i]
      begin
        check[i]  <- gid.lookup[n]
        unavailable
	  (locate self)$stdout.PutString["Gaggle Member cannot be accessed 
          probably because of the failure of its server \n"]
          check[i] <- nil
        end unavailable
      end 
    end for
     
    j<-0
    loop
      v <- check[j]
      j <- j+1
      exit when ((v !== nil) or (j >= size))
    end loop		
    
    if (v !== nil) then
      for i: Integer <- 0 while i < size by i <- i+1
      	if (check[i] !== nil) then
          if ((view check[i] as String) != (view v as String)) then
	    (locate self)$stdout.PutString["Lookup of "||n||" differs among 
             the replications\n"]
	    (locate self)$stdout.PutString["Hence returning one possible 
             lookup value\n"]
	  end if
        else
          (locate self)$stdout.PutString["Lookup of "||n||" differs among 
           the replications\n"]
	  (locate self)$stdout.PutString["Hence returning one possible 
           lookup value\n"]
        end if
      end for
    end if
  end lookup
   
  export function list[] -> [n: ImmutableVectorOfString]
    const gid <- self.invokee
    begin
      n<- gid.list 
      unavailable
        var size: Integer
        var success: Integer 
        primitive self var "GETGAGGLESIZE"[size]<-[]
        loop
	  success <- 1
	  size <- size-1
	  const goid <- self.invokee[size]
	  begin
	    n <- goid.list
	    unavailable
	      success <- 0
	    end unavailable
	  end
	  exit when ((success = 1)or (size = 0))
        end loop	
      end unavailable
    end
  end list

end DirectoryGaggle
