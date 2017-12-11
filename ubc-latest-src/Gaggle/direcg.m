%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%			THE BASE GAGGLE CLASS                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

const Gaggle <- immutable class Gaggle 
  class const memberType <- Any
  
  initially
    primitive self var "CREATEGAGGLE" [] <- []
  end initially
  
  export operation addMember[newMember: memberType]->[]
    primitive self var "ADDTOGAGGLE" [] <- [newMember]
  end addMember
  
  export operation invokee [] -> [gaggleInvokee: memberType]
    primitive self var "GETGAGGLEMEMBER" [gaggleInvokee] <- []
  end invokee
  
  export operation invokee[i: Integer]->[gaggleInvokee:memberType]
    primitive self var "GETGAGGLEELEMENT" [gaggleInvokee]<-[i]
  end invokee 

  export operation lowerbound -> [ind: Integer]
    primitive self var "GETGAGGLESIZE"[ind]<-[]
    if ind == 0 then
      ind <- -1
    else
      ind <- 0
    end if
  end lowerbound

  export operation upperbound -> [ind: Integer]
    primitive self var "GETGAGGLESIZE"[ind]<-[]
    ind <- ind - 1
  end upperbound

  export operation getElement[ind: Integer]->[gaggleInvokee: memberType]
    gaggleInvokee <- self.invokee[ind]
  end getElement

end Gaggle  




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	         THE DIRECTORY OBJECT WITH LOCKING                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

const L_Directory <- immutable object L_Directory
  
%  record logRecord 
%    name  : String
%    value : Any
%    type  : Integer
%    tm    : Time
%   end logRecord
  
 const L_DirectoryType <- typeobject L_DirectoryType 
    operation insert [String, Any]
    function  lookup [String] 		-> [Any]
    operation delete [String]
    function  list 			-> [ImmutableVectorOfString]
    function  lock 			-> [res: Integer]
    operation release 		
    function  islocked 			-> [res: Integer]
    function  ping 			-> [res: Integer]
  end L_DirectoryType

  export function getSignature -> [ r : Signature ]
    r <- L_DirectoryType
  end getSignature

  export operation create -> [r : L_DirectoryType]
    r <- monitor object aUnixDirectory 
      var canread   : Boolean <- True   % lock variable
      var timer     : Any     <- nil    % for timer thread
      var waitTime  : Integer <- 0
      var allocsize : Integer <- 4
%     var logArray  : Array.Of[logRecord] <- Array.Of[logRecord].create[25]
      var size : Integer <- 0
      attached var names : VectorOfString <- VectorOfString.create[allocsize]
      attached var values : VectorOfAny <- VectorOfAny.create[allocsize]      
      
      function find [n : String, insert : Boolean] -> [mid : Integer]
	var lwb, upb, i : Integer
	var found : Boolean <- false
	lwb <- 0
	upb <- size - 1

	loop
	  mid <- (lwb + upb) / 2
	  exit when lwb > upb
	  const aname <- names[mid]
	  if aname = n then
	    found <- true
	    exit
	  elseif aname < n then
	    lwb <- mid + 1
	  else
	    upb <- mid - 1
	  end if
	end loop
	if !found and insert then

	  % Think about growing the vectors
	  if size = allocsize then
	    if allocsize < 128 then
	      allocsize <- allocsize * 2
	    else
	      allocsize <- allocsize + 128
	    end if
	    const oldnames <- names
	    const oldvalues <- values
	    names <- VectorOfString.create[allocsize]
	    values <- VectorOfAny.create[allocsize]
	    i <- 0
	    loop
	      exit when i = size
	      names[i] <- oldnames[i]
	      values[i] <- oldvalues[i]
	      i <- i + 1
	    end loop
	  end if
	    
	  i <- size
	  loop
	    exit when i <= lwb
	    names[i] <- names[i - 1]
	    values[i] <- values[i - 1]
	    i <- i - 1
	  end loop
	  names[i] <- n
	  values[i] <- nil
	  mid <- i
	  size <- size + 1
	end if
      end find

      export operation insert [n : String, v : Any]
	const index <- self.find[n, true]
	assert names[index] = n
	values[index] <- v
      end insert

      export operation delete [n : String]
	var index : Integer <- self.find[n, false]
	if index < size and names[index] = n then
	  size <- size - 1
	  loop
	    exit when index >= size
	    names[index] <- names[index + 1]
	    values[index] <- values[index + 1]
	    index <- index + 1
	  end loop
        end if
      end delete

      export function lookup [n : String] -> [v : Any]
	const index <- self.find[n, false]
	if index < size and names[index] = n then
	  v <- values[index]
	end if
      end lookup

      export function list -> [n : ImmutableVectorOfString]
	n <- ImmutableVectorOfString.Literal[names, size]
      end list
      
      export function lock [] ->[res: Integer]
	if canread = True  then
	  canread<-False
	  if timer == nil then
	    timer <- self.startTimer[]
          else
	    waitTime<-0
          end if
	  res <- 1
	else
	  res <- 0
        end if
      end lock
      
      export operation release [] -> []
	canread<-True
      end release
      
      export function islocked [] -> [res: Integer] 
	if canread = True then
	  res <- 0
	else
	  res <- 1
	end if
      end islocked

      export function ping[]->[res: Integer]
	waitTime <- waitTime+1
	if canread =True then
	  res    <- 1
	  timer  <- nil
	elseif waitTime == 2 then
	  canread <- True
	  timer  <- nil
          res    <- 1
	else
          res<-0
      	end if
      end ping
      
      operation startTimer[]->[a : Any]
	a <- object timerThread
	   process
	     loop
	       (locate self).delay[Time.create[10, 0]]
               exit when aUnixDirectory.ping=1	
	     end loop
	   end process
	end timerThread
      end startTimer
    
    end aUnixDirectory
  end create
end L_Directory


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		      THE STRONG DIRECTORY GAGGLE                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

const DirectoryGaggle <- immutable class DirectoryGaggle (Gaggle) 
  
  class const memberType <- L_Directory
  
  export operation instantiate[newMember: L_Directory]
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

export DirectoryGaggle, L_Directory, Gaggle
