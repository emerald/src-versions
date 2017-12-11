const TimeStamp <- immutable object TimeStamp
  const TimeStampType <- immutable typeobject TimeStampType
    function > [o : TimeStampType] -> [r : Boolean]
    function >= [o : TimeStampType] -> [r : Boolean]
    function < [o : TimeStampType] -> [r : Boolean]
    function <= [o : TimeStampType] -> [r : Boolean]
    function = [o : TimeStampType] -> [r : Boolean]
    function != [o : TimeStampType] -> [r : Boolean]
    function getSeconds -> [r : Integer]
    function getMicroSeconds -> [r : Integer]
    function getIpAddress -> [r : Integer]
    function getIncarnation -> [r : Integer]
    function asString -> [String]
  end TimeStampType
  export function getSignature -> [result : Signature]
    result <- TimeStampType
  end getSignature
  export operation create [seconds : Integer, microseconds : Integer, ipaddress : Integer, incarnation : Integer] -> [result : TimeStampType]
    result <- immutable object aTimeStamp
      const secs : Integer <- seconds
      const msecs: Integer <- microseconds
      const ipaddr : Integer <- ipaddress
      const inc : Integer <- incarnation

      export function < [o : TimeStampType] -> [r : Boolean]
	r <- secs < o$seconds or
	  secs = o$seconds and msecs < o$microSeconds or
	  secs = o$seconds and msecs = o$microSeconds and ipaddr < o$ipAddress or 
	  secs = o$seconds and msecs = o$microSeconds and ipaddr = o$ipAddress and inc < o$incarnation
      end <

      export function <= [o : TimeStampType] -> [r : Boolean]
	r <- secs < o$seconds or
	  secs = o$seconds and msecs < o$microSeconds or
	  secs = o$seconds and msecs = o$microSeconds and ipaddr < o$ipAddress or 
	  secs = o$seconds and msecs = o$microSeconds and ipaddr = o$ipAddress and inc <= o$incarnation
      end <=
      export function > [o : TimeStampType] -> [r : Boolean]
	r <- secs > o$seconds or
	  secs = o$seconds and msecs > o$microSeconds or
	  secs = o$seconds and msecs = o$microSeconds and ipaddr > o$ipAddress or 
	  secs = o$seconds and msecs = o$microSeconds and ipaddr = o$ipAddress and inc > o$incarnation
      end >
      export function >= [o : TimeStampType] -> [r : Boolean]
	r <- secs > o$seconds or
	  secs = o$seconds and msecs > o$microSeconds or
	  secs = o$seconds and msecs = o$microSeconds and ipaddr > o$ipAddress or 
	  secs = o$seconds and msecs = o$microSeconds and ipaddr = o$ipAddress and inc >= o$incarnation
      end >=
      export function = [o : TimeStampType] -> [r : Boolean]
	r <- secs = o$seconds and msecs = o$microSeconds and ipaddr = o$ipAddress and inc = o$incarnation
      end =
      export function != [o : TimeStampType] -> [r : Boolean]
	r <- secs = o$seconds and msecs = o$microSeconds and ipaddr = o$ipAddress and inc = o$incarnation
      end !=
      export function getSeconds -> [r : Integer]
	r <- secs
      end getSeconds
      export function getMicroSeconds -> [r : Integer]
	r <- msecs
      end getMicroSeconds
      export function getIPAddress -> [r : Integer]
	r <- ipaddr
      end getIPAddress
      export function getIncarnation -> [r : Integer]
	r <- inc
      end getIncarnation
      export function asString -> [r : String]
	const x : String <- msecs.asString
	const y <- "000000"
	const l : Integer <- x.length
	r <- secs.asString || ":"
	if l < 6 then
	  r <- r || y[0, 6-x.length]
        end if
	r <- r || x
%	r <- r || "@" || ipaddr.asHexString || "." || inc.asHexString
      end asString
    end aTimeStamp
  end create
end TimeStamp

export TimeStamp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%			THE BASE GAGGLE CLASS                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Every subclass of this class, must declare a class const named memberType  %
% that is the type of the elements of the Gaggle.                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

const Gaggle <- immutable class Gaggle
  class const memberType <- Any

  export operation addMember[newMember: memberType]->[]
    primitive self var "ADDTOGAGGLE" [] <- [newMember]
  end addMember

  operation invokee [] -> [gaggleInvokee: memberType]
    primitive self var "GETGAGGLEMEMBER" [gaggleInvokee] <- []
  end invokee

  operation invokee[i: Integer]->[gaggleInvokee:memberType]
    primitive self var "GETGAGGLEELEMENT" [gaggleInvokee]<-[i]
  end invokee

  operation lowerbound -> [ind: Integer]
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

  export operation getElements -> [r : ImmutableVector.of[memberType]]
    const limit <- self.upperbound
    const l <- Vector.of[memberType].create[limit + 1]
    for i : Integer <- 0 while i <= limit by i <- i + 1
      l[i] <- self[i]
    end for
    r <- ImmutableVector.of[memberType].Literal[l, limit + 1]
  end getElements

end Gaggle


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	         A directory with eventual consistency                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

const VectorofTimeStamp <- Vector.of[TimeStamp]
const ImmutableVectorofTimeStamp <- ImmutableVector.of[TimeStamp]

const RDirectory <- immutable object RDirectory builtin 0x1017

  const DirectoryType <- typeobject DirectoryType builtin 0x1617
    operation insert [String, Any]
    function  lookup [String] 		-> [Any]
    operation delete [String]
    function  list 			-> [ImmutableVectorOfString]
    operation update[String, Any, TimeStamp, Boolean]
    operation update[ImmutableVectorofString, ImmutableVectorofAny, ImmutableVectorofTimeStamp]
    operation requestUpdate -> [ImmutableVectorofString, ImmutableVectorofAny, ImmutableVectorofTimeStamp]
  end DirectoryType

  const ExternalDirectoryType <- typeobject ExternalDirectoryType
    operation insert [String, Any]
    function  lookup [String] 		-> [Any]
    operation delete [String]
    function  list 			-> [ImmutableVectorOfString]
  end ExternalDirectoryType

  const internalType <- typeobject internalType
    operation update[String, Any, TimeStamp, Boolean]
    operation update[ImmutableVectorofString, ImmutableVectorofAny, ImmutableVectorofTimeStamp]
    operation requestUpdate -> [ImmutableVectorofString, ImmutableVectorofAny, ImmutableVectorofTimeStamp]
  end internalType

  export function getSignature -> [ r : Signature ]
    r <- DirectoryType
  end getSignature

  export operation create [g : DirectoryGaggle] -> [r : DirectoryType]
    r <- monitor object aUnixDirectory builtin 0x1417
      var allocsize : Integer <- 4
      var size : Integer <- 0
      attached var names : VectorOfString <- VectorOfString.create[allocsize]
      attached var values : VectorOfAny <- VectorOfAny.create[allocsize]
      attached var timestamps : VectorOfTimeStamp <- VectorOfTimeStamp.create[allocsize]
      attached var hasProcess : Boolean <- false
      attached field isStale  : Boolean <- false

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
	    const oldtimestamps <- timestamps
	    names <- VectorOfString.create[allocsize]
	    values <- VectorOfAny.create[allocsize]
	    timestamps <- VectorOfTimeStamp.create[allocsize]
	    i <- 0
	    loop
	      exit when i = size
	      names[i] <- oldnames[i]
	      values[i] <- oldvalues[i]
	      timestamps[i] <- oldtimestamps[i]
	      i <- i + 1
	    end loop
	  end if
	
	  i <- size
	  loop
	    exit when i <= lwb
	    names[i] <- names[i - 1]
	    values[i] <- values[i - 1]
	    timestamps[i] <- timestamps[i - 1]
	    i <- i - 1
	  end loop
	  names[i] <- n
	  values[i] <- nil
	  timestamps[i] <- nil
	  mid <- i
	  size <- size + 1
	elseif !found then
	  mid <- size
	end if
      end find

      operation getnow -> [r : TimeStamp]
	const here <- locate self
	const now <- here.getTimeOfDay
	var ipaddr, inc, seq : Integer
	primitive self var "GETOID" [ipaddr, inc, seq] <- []
	r <- TimeStamp.create[now$seconds, now$microSeconds, ipaddr, inc]
      end getnow

      export operation insert [n : String, v : Any]
	self.iupdate[n, v, self.getnow, true]
      end insert

      export operation delete [n : String]
	self.iupdate[n, nil, self.getnow, true]
      end delete

      export function lookup [n : String] -> [v : Any]
	const index <- self.find[n, false]
	if index < size then
	  v <- values[index]
	end if
      end lookup

      export function list -> [n : ImmutableVectorOfString]
	const lnames <- VectorOfString.create[allocsize]
	var j : Integer <- 0
	for i : Integer <- 0 while i < size by i <- i + 1
	  if values[i] !== nil then
	    lnames[j] <- names[i]
	    j <- j + 1
	  end if
	end for
	n <- ImmutableVectorOfString.Literal[lnames, j]
      end list

      %
      % Keep trying the elements of others until you find one that is
      % willing to send you update information right now

      operation tryRequestUpdate[o : RDirectory] -> [ns : ImmutableVectorofString, vs : ImmutableVectorofAny, tss : ImmutableVectorofTimeStamp, r : Boolean]
	if o == nil then r <- false return end if
	r <- true
	ns, vs, tss <- (view o as InternalType).requestUpdate
	unavailable
	  r <- false
	end unavailable
      end tryRequestUpdate

      operation ping[others : ImmutableVector.of[RDirectory]]
	var ns : ImmutableVectorofString
	var vs : ImmutableVectorofAny
	var tss : ImmutableVectorofTimeStamp
	var success : Boolean
	const limit <- others.upperbound
	for i : Integer <- 0 while i <= limit by i <- i + 1
	  ns, vs, tss, success <- self.tryRequestUpdate[others[i]]
	  if success then
	    self.iupdate[ns, vs, tss]
	    exit
	  end if
	end for
      end ping

      export operation update[n : String, v : Any, ts : TimeStamp, now : Boolean]
	self.iupdate[n, v, ts, now]
      end update

      operation iupdate[n : String, v : Any, ts : TimeStamp, now : Boolean]
	const index <- self.find[n, true]
	assert index < size
	if timestamps[index] == nil or ts > timestamps[index] then
	  names [index] <- n
	  values[index] <- v
	  timestamps[index] <- ts
	  if now then
	    const them <- g.getElements
	    const limit <- them.upperbound
	    for i : Integer <- 0 while i <= limit by i <- i + 1
	      const o <- them[i]
	      if o !== self and o !== nil then
		const junk <- object eagerUpdate
		  process
		    (view o as InternalType).update[n, v, ts, false]
		    unavailable
		      aUnixDirectory.isStale
		    end unavailable
		  end process
		end eagerUpdate
	      end if
	    end for
	  else
	    self.iisStale
	  end if
	end if
      end iupdate

      export operation update[ns : ImmutableVectorOfString, vs : ImmutableVectorofAny, tss : ImmutableVectorofTimeStamp]
	self.iupdate[ns, vs, tss]
      end update
      operation iupdate[ns : ImmutableVectorOfString, vs : ImmutableVectorofAny, tss : ImmutableVectorofTimeStamp]
	const limit <- ns.upperbound
	for i : Integer <- 0 while i <= limit by i <- i + 1
	  self.iupdate[ns[i], vs[i], tss[i], false]
	end for
      end iupdate

      export operation RequestUpdate -> [ns : ImmutableVectorofString, vs : ImmutableVectorofAny, tss : ImmutableVectorofTimeStamp]
	ns  <- ImmutableVectorofString.Literal[names, size]
	vs  <- ImmutableVectorofAny.Literal[values, size]
	tss <- ImmutableVectorofTimeStamp.Literal[timestamps, size]
      end RequestUpdate

      export operation isStale
	self.iisStale
      end isStale

      operation iisStale
	isStale <- true
	if !hasProcess then
	  hasProcess <- true
	  const slowUpdate <- object lazyUpdate
	    process
	      const howoften <- Time.create[15 * 60, 0]
	      loop
		(locate self).delay[howoften]
		exit when !aUnixDirectory$isStale
		aUnixDirectory$isStale <- false
		const them <- g.getElements
		const limit <- them.upperbound
		const ns  <- ImmutableVectorofString.Literal[names, size]
		const vs  <- ImmutableVectorofAny.Literal[values, size]
		const tss <- ImmutableVectorofTimeStamp.Literal[timestamps, size]
		
		for i : Integer <- 0 while i <= limit by i <- i + 1
		  const o <- them[i]
		  if o !== self and o !== nil then
		    const junk <- object eagerUpdate
		      process
			(view o as internalType).update[ns, vs, tss]
			unavailable
			  aUnixDirectory.isStale
			end unavailable
		      end process
		    end eagerUpdate
		  end if
		end for
	      end loop
	    end process
	  end lazyUpdate
	end if
      end iisStale

      export operation theProcess
	const e <-  g.getElements
	if e.upperbound >= 0 then
	  self.ping[e]
	end if
	g.addMember[self]
      end theProcess

      initially
	const junk <- object initializeRootDirectory
	  process
	    aUnixDirectory.theProcess
	  end process
	end initializeRootDirectory
      end initially
    end aUnixDirectory
  end create
  export operation create -> [r : DirectoryType]
    r <- self.create[DirectoryGaggle.create]
  end create
end RDirectory


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		  An eventually consistent directory gaggle                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

const DirectoryGaggle <- immutable class DirectoryGaggle (Gaggle) builtin 0x1026

  class const memberType <- RDirectory

  operation tryinsert[d : RDirectory, n : String, v : Any] -> [r : Boolean]
    r <- true
    d.insert[n, v]
    unavailable
      r <- false
    end unavailable
  end tryinsert
    
  export operation insert[n: String, v: Any]
    const first <- self.invokee
    first.insert[n, v]
    failure
      const them <- self.getElements
      const limit <- them.upperbound
      for i : Integer <- 0 while i <= limit by i <- i + 1
	const target <- them[i]
	if target !== first and target !== nil then
	  exit when self.tryinsert[target, n, v]
        end if
      end for
    end failure
  end insert

  operation trydelete[d : RDirectory, n : String] -> [r : Boolean]
    r <- true
    d.delete[n]
    unavailable
      r <- false
    end unavailable
  end trydelete
    
  export operation delete[n: String]
    const first <- self.invokee
    first.delete[n]
    failure
      const them <- self.getElements
      const limit <- them.upperbound
      for i : Integer <- 0 while i <= limit by i <- i + 1
	const target <- them[i]
	if target !== first and target !== nil then
	  exit when self.trydelete[target, n]
        end if
      end for
    end failure
  end delete

  operation trylookup[d : RDirectory, n : String] -> [v : Any, r : Boolean]
    r <- true
    v <- d.lookup[n]
    unavailable
      r <- false
    end unavailable
  end trylookup
    
  export function lookup[n: String] -> [v: Any]
    const first <- self.invokee
    v <- first.lookup[n]
    failure
      const them <- self.getElements
      const limit <- them.upperbound
      var done : Boolean
      for i : Integer <- 0 while i <= limit by i <- i + 1
	const target <- them[i]
	if target !== first and target !== nil then
	  v, done <- self.trylookup[target, n]
	  exit when done
        end if
      end for
    end failure
  end lookup

  operation trylist[d : RDirectory] -> [n : ImmutableVectorOfString, r :Boolean]
    r <- true
    n <- d.list
    unavailable
      r <- false
    end unavailable
  end trylist
    
  export function list[] -> [n: ImmutableVectorOfString]
    const first <- self.invokee
    n <- first.list
    failure
      const them <- self.getElements
      const limit <- them.upperbound
      var done : Boolean
      for i : Integer <- 0 while i <= limit by i <- i + 1
	const target <- them[i]
	if target !== first and target !== nil then
	  n, done <- self.trylist[target]
	  exit when done
        end if
      end for
    end failure
  end list

end DirectoryGaggle

export RDirectory to "Builtins"
export DirectoryGaggle to "Builtins"
