% 
% @(#)Array.m	1.2  3/6/91
%
export Array to "Builtins"

const Array <- 
  immutable object Array builtin 0x1002
    export function of [E_Type : type] -> [result : NAT]
      forall
	E_Type
      where
	RIS <-  typeobject RIS
		  function getElement [Integer] -> [E_Type]
		  function upperbound -> [Integer]
		  function lowerbound -> [Integer]
		end RIS
      where
	NA <-	typeobject NA
		  function  getElement [Integer] -> [E_Type]
		    % get the element indexed by index, failing if index 
		    % out of range.
		  operation setElement [Integer, E_Type]
		    % set the element, failing if index out of range
		  function  upperbound -> [Integer]
		    % return the highest valid index, ub.
		  function  lowerbound -> [Integer]
		    % return the lowest valid index, lb.
		  function  getElement [Integer, Integer] -> [NA]
		  function  getSlice [Integer, Integer] -> [NA]
		    % return a new array, a, with lower bound lb, and 
		    % upper bound ub, such that for lb <= i <= ub:
		    %     self.getElement[i] == a.getElement[i]
		    % fail if lb or ub is out of range.
		  operation setElement [Integer, Integer, RIS]
		  operation setSlice [Integer, Integer, RIS]
		    % set the elements indexed by i for lb <= i <= ub, so 
		    % that for each such i:
		    %     self.getElement[i] == a.getElement[i]
		    % fail if lb or ub is out of range.
		  operation slideTo [Integer]
		    % change the valid indicies for self.  Assuming 
		    % the old indicies ranged from lb to ub, the new 
		    % indicies will range from i to i + ub - lb
		  operation addUpper [E_Type]
		    % extend the set of valid indicies, changing ub to 
		    % ub + 1, and setting the element indexed by the new
		    % ub to be e.
		  operation removeUpper -> [E_Type]
		    % return the element indexed by ub, after contracting 
		    % the set of valid indicies to lb <= i <= ub - 1.
		  operation addLower [E_Type]
		    % extend the set of valid indicies, changing lb to 
		    % lb - 1, and setting
		    % the element indexed by the new lb to be e.
		  operation removeLower -> [E_Type]
		    % return the element indexed by lb, after contracting 
		    % the set of valid indicies to lb + 1 <= i <= ub.
		  function  empty -> [Boolean]
		    % -> true if lb == ub + 1, which is true initially,
		    % since initially lb = 1, and ub = 0.
		  operation catenate [a : RIS] -> [r : NA]
		    % extend the range of valid indicies from lb .. ub to 
		    % lb .. ub + a.length.  Set these new elements to refer
		    % to the elements of a so that for a.lb <= i <= a.ub, 
		    % where oub is the old value of self.ub:
		    %     a.getElement[i] == self.getElement[oub + i - 1]
		end NA
      where
	NAT <-	immutable typeobject NAT
		  operation empty -> [NA]
		  operation literal [RIS] -> [NA]
		  operation create[Integer] -> [NA]
		  function getSignature -> [Signature]
		end NAT

      result <- 
	immutable object aNAT builtin 0x1402

	  const ve <- Vector.of[E_Type]

	  export function getSignature -> [result : Signature]
	    result <- NA
	  end getSignature

	  export operation create[length : Integer] -> [result : NA]
	    result <-
	      object aNA

		var lwb, upb, firstIndex, lastIndex : Integer
		var currentSize, maxSize : Integer
		attached var vec: ve
		
		export function  getElement [i : Integer] -> [r : E_Type]
		  var index : Integer
		  assert i >= lwb
		  assert i <= upb
		  index <- (i - lwb) + firstIndex
		  if index >= maxSize then
		    index <- index - maxSize
		  end if
		  r <- vec[index]
		end getElement

		export operation setElement [i : Integer, r : E_Type]
		  var index : Integer
		  assert i >= lwb
		  assert i <= upb
		  index <- (i - lwb) + firstIndex
		  if index >= maxSize then
		    index <- index - maxSize
		  end if
		  vec[index] <- r
		end setElement

		export function  upperbound -> [r : Integer]
		  r <- upb
		end upperbound

		export function  lowerbound -> [r : Integer]
		  r <- lwb
		end lowerbound

		% return a new Array, a, with lower bound lwb, and 
		% upper bound upb, such that for lwb <= i <= upb:
		%     self.getElement[i] == a.getElement[i]
		% fail if lwb or upb is out of range.
		export function  getSlice [i1 : Integer, l : Integer] -> [r : NA]
		  r <- self.getElement[i1, l]
		end getSlice
		export function  getElement [i1 : Integer, l : Integer] -> [r : NA]
		  var index : Integer
		  var i : Integer <- 0
		  assert l >= 0
		  assert i1 >= lwb
		  assert i1+l-1 <= upb
		  r <- aNAT.create[l]
		  r.slideTo[i1]
		  index <- (i1 - lwb) + firstIndex
		  if index >= maxSize then
		    index <- index - maxSize
		  end if
		  loop
		    exit when i >= l
		    r[i1 + i] <- vec[index]
		    i <- i + 1
		    index <- index + 1
		    if index >= maxSize then
		      index <- index - maxSize
		    end if
		  end loop
		end getElement

		% set the elements indexed by i for lwb <= i <= upb, so 
		% that for each such i:
		%     self.getElement[i] == a.getElement[i]
		% fail if lwb or upb is out of range.
		export operation setSlice [i1 : Integer, l : Integer, s : RIS]
		  self.setElement[i1, l, s]
		end setSlice
		export operation setElement [i1 : Integer, l : Integer, s : RIS]
		  var index : Integer
		  var i : Integer <- 0
		  assert l >= 0
		  assert i1 >= lwb
		  assert i1 + l <= upb
		  assert i1 >= s.lowerbound
		  assert i1 + l <= s.upperbound
		  index <- (i1 - lwb) + firstIndex
		  if index >= maxSize then
		    index <- index - maxSize
		  end if
		  loop
		    exit when i >= l
		    vec[index] <- s[i1 + i]
		    i <- i + 1
		    index <- index + 1
		    if index >= maxSize then
		      index <- index - maxSize
		    end if
		  end loop
		end setElement

		% change the valid indicies for self.  Assuming 
		% the old indicies ranged from lwb to upb, the new 
		% indicies will range from i to i + upb - lwb
		export operation slideTo [i : Integer]
		  var difference : Integer <- lwb - i
		  lwb <- lwb - difference
		  upb <- upb - difference
		end slideTo

		% extend the set of valid indicies, changing upb to 
		% upb + 1, and setting the element indexed by the new
		% upb to be e.
		export operation addUpper [e : E_Type]
		  var index : Integer
		  if currentSize = maxSize then
		    var nvec : ve
		    const nMaxSize : Integer <- maxSize * 2
		    var oldIndex : Integer <- firstIndex
		    var newIndex : Integer <- 0
		    nvec <- ve.create[nMaxSize]
		    loop
		      exit when newIndex >= maxSize
		      nvec[newIndex] <- vec[oldIndex]
		      newIndex <- newIndex + 1
		      oldIndex <- oldIndex + 1
		      if oldIndex >= maxSize then
			oldIndex <- oldIndex - maxSize
		      end if
		    end loop
		    firstIndex <- 0
		    lastIndex <- maxSize - 1
		    maxSize <- nMaxSize
		    vec <- nvec
		  end if
		  index <- lastIndex + 1
		  if index >= maxSize then
		    index <- index - maxSize
		  end if
		  vec[index] <- e
		  lastIndex <- index
		  currentSize <- currentSize + 1
		  upb <- upb + 1
		end addUpper

		% return the element indexed by upb, after contracting 
		% the set of valid indicies to lwb <= i <= upb - 1.
		export operation removeUpper -> [r : E_Type]
		  assert currentSize > 0
		  r <- vec[lastIndex]
		  currentSize <- currentSize - 1
		  upb <- upb - 1
		  if currentSize = 0 then
		    firstIndex <- 0
		    lastIndex <- ~1
		  else
		    lastIndex <- lastIndex - 1
		    if lastIndex < 0 then
		      lastIndex <- lastIndex + maxSize
		    end if
		  end if
		end removeUpper

		% extend the set of valid indicies, changing lwb to 
		% lwb - 1, and setting
		% the element indexed by the new lwb to be e.
		export operation addLower [e : E_Type]
		  var index : Integer
		  if currentSize = maxSize then
		    var nvec : ve
		    const nMaxSize : Integer <- maxSize * 2
		    var oldIndex : Integer <- firstIndex
		    var newIndex : Integer <- 0
		    nvec <- ve.create[nMaxSize]
		    loop
		      exit when newIndex >= maxSize
		      nvec[newIndex] <- vec[oldIndex]
		      newIndex <- newIndex + 1
		      oldIndex <- oldIndex + 1
		      if oldIndex >= maxSize then
			oldIndex <- oldIndex - maxSize
		      end if
		    end loop
		    firstIndex <- 0
		    lastIndex <- maxSize - 1
		    maxSize <- nMaxSize
		    vec <- nvec
		  end if
		  index <- firstIndex - 1
		  if index < 0 then
		    index <- index + maxSize
		  end if
		  vec[index] <- e
		  firstIndex <- index
		  currentSize <- currentSize + 1
		  lwb <- lwb - 1
		end addLower

		% return the element indexed by lwb, after contracting 
		% the set of valid indicies to lwb + 1 <= i <= upb.
		export operation removeLower -> [r : E_Type]
		  assert currentSize > 0
		  r <- vec[firstIndex]
		  currentSize <- currentSize - 1
		  lwb <- lwb + 1
		  if currentSize = 0 then
		    firstIndex <- 0
		    lastIndex <- ~1
		  else 
		    firstIndex <- firstIndex + 1
		    if firstIndex >= maxSize then
		      firstIndex <- firstIndex - maxSize
		    end if
		  end if
		end removeLower

		% -> true if the array is empty
		export function  empty -> [r : Boolean]
		  r <- currentSize = 0
		end empty

		% return a new array the result of catenating the 
		% elements of a to self
		export operation catenate [a : RIS] -> [catenateResult : NA]
		  var index, limit, newsize : Integer
		  var i : Integer <- 0
		  newsize <- currentSize+a.upperbound-a.lowerbound+1
		  catenateResult <- aNAT.create[-newsize]
		  catenateResult.slideTo[lwb]
		  index <- firstIndex
		  loop
		    exit when i >= currentSize
		    catenateResult.addUpper[vec[index]]
		    i <- i + 1
		    index <- index + 1
		    if index >= maxSize then
		      index <- index - maxSize
		    end if
		  end loop
		  i <- a.lowerbound
		  limit <- a.upperbound
		  loop
		    exit when i > limit
		    catenateResult.addUpper[a[i]]
		    i <- i + 1
		  end loop
		end catenate

		initially
		  lwb <- 0
		  firstIndex <- 0
		  if length < 0 then
		    upb <- ~1
		    lastIndex <- ~1
		    maxSize <- ~length
		    currentSize <- 0
		  elseif length = 0 then
		    upb <- ~1
		    lastIndex <- ~1
		    maxSize <- 10
		    currentSize <- 0
		  else
		    upb <- length - 1
		    lastIndex <- length - 1
		    maxSize <- length
		    currentSize <- length
		  end if
		  vec <- ve.create[maxSize]
		end initially
	      end aNA
	  end create
	  export operation empty -> [result : NA]
	    result <- aNAT.create[0]
	  end empty
	  export operation literal [v : RIS] -> [literalResult : NA]
	    var i : Integer <- v.lowerbound
	    const limit : Integer <- v.upperbound
	    literalResult <- aNAT.create[~(limit - i + 1)]
	    loop
	      exit when i > limit
	      literalResult.addUpper[v[i]]
	      i <- i + 1
	    end loop
	  end literal
	end aNAT
    end of
  end Array
