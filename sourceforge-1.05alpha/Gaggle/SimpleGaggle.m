%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%			THE BASE GAGGLE CLASS                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Every subclass of this class, must declare a class const named memberType  %
% that is the type of the elements of the Gaggle.                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

const Gaggle <- immutable class Gaggle
  class const memberType <- Any

  initially
    primitive self var "CREATEGAGGLE" [] <- []
  end initially

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
%	         A replicated integer variable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

const RepInt <- immutable object RepInt

  const RepIntType <- typeobject RepIntType
    operation setv [Integer]
    function  getv -> [Integer]
  end RepIntType

  export function getSignature -> [ r : Signature ]
    r <- RepIntType
  end getSignature

  export operation create [g : RepIntGaggle] -> [r : RepIntType]
    r <- monitor object aRepInt
      var v : Integer <- 0

      export operation setv [nv : Integer]
	const limit <- g.upperbound
	for i : Integer <- 0 while i <= limit by i <- i + 1
	  const o <- g[i]
	  if o !== self then
	    const junk <- object eagerUpdate
	      process
		o$v <- nv
		unavailable
		end unavailable
	      end process
	    end eagerUpdate
	  end if
	end for
      end setv

      export function getv -> [nv : Integer]
	nv <- v
      end getv

      initially
	if g.upperbound >= 0 then
	  v <- g$v
	end if
	g.addMember[self]
      end initially
    end aRepInt
  end create
end RepInt


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		  A Replicated Integer Gaggle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

const RepIntGaggle <- immutable class RepIntGaggle (Gaggle)

  class const memberType <- RepInt

  operation trysetv[d : RepInt, nv : Integer] -> [r : Boolean]
    r <- true
    d$v <- nv
    unavailable
      r <- false
    end unavailable
  end trysetv
    
  export operation setv[nv : Integer]
    const limit <- self.upperbound
    var done : Boolean <- false
    for i : Integer <- 0 while i <= limit and !done by i <- i + 1
      const target <- self.invokee[i]
      done <- self.trysetv[target, nv]
    end for
  end setv

  operation trygetv[d : RepInt] -> [nv : Integer, r : Boolean]
    r <- true
    nv <- d.getv
    unavailable
      r <- false
    end unavailable
  end trygetv
    
  export operation getv -> [nv: Integer]
    const first <- self.invokee
    nv <- first$v
    failure
      const limit <- self.upperbound
      var done : Boolean
      for i : Integer <- 0 while i <= limit by i <- i + 1
	const target <- self.invokee[i]
	if target !== first then
	  nv, done <- self.trygetv[target]
	  exit when done
        end if
      end for
    end failure
  end getv

end RepIntGaggle

export RepInt, RepIntGaggle
