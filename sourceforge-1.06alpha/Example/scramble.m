% Scramble.m
%
% Stress test an emerald environment by performing a lot of moves and
% invokes and stuff.  The idea is to get a bunch of nodes doing a bunch of
% things, and if you really like fun, kill one.

const slob <- class slob
  field one : Any
  field two : Any
  export operation poke end poke
end slob
const slobarray <- Array.of[slob]

const howmanydroids  <- 100
const reporthowoften <- 100
const delayinms      <- 100000
const loophowmany    <- 10000

const droid <- class droid[index : Integer]
  var alive : NodeList <- (locate self).getActiveNodes
  attached const slobs <- slobarray.empty

  export operation random [upb : Integer] -> [n : Integer]
    primitive "NCCALL" "RAND" "RANDOM" [n] <- []
    n <- n.abs # upb
  end random

  export operation srandom
    var seed : Integer <- (locate self)$timeOfDay$microseconds
    primitive "NCCALL" "RAND" "SRANDOM" [] <- [seed]
  end srandom

  operation makeone
    if slobs.upperbound < slobs.lowerbound + 15 then
      const aslob <- slob.create
      if slobs.lowerbound <= slobs.upperbound and self.random[10] != 0 then
	aslob.setone[slobs[slobs.lowerbound]]
      end if
      slobs.addupper[aslob]
    end if
  end makeone
    
  operation removeone
    if slobs.upperbound > slobs.lowerbound then
      const aslob <- slobs.removeLower
      aslob.poke
      if self.random[30] = 1 then
	const index <- self.random[slobs.upperbound - slobs.lowerbound + 1]
	aslob.settwo[slobs[slobs.lowerbound + index]]
      end if
    end if
  end removeone

  operation trans
    const draw <- self.random[3]
    if draw == 2 then
      self.makeone
    elseif draw == 1 then
      self.removeone
    elseif draw == 0 then
      const index <- self.random[alive.upperbound - alive.lowerbound + 1]
      move self to alive[index]$theNode
    end if
    (locate self).delay[Time.create[0, self.random[delayinms]]]
  end trans

  operation keepdroiding
    alive <- (locate self).getActiveNodes
    self.trans

    unavailable [who]
      (locate self)$stdout.PutString["Unavailable "||nameof who||"\n"]
      if who == alive then
	(locate self)$stdout.PutString["  It is alive\n"]
      end if
      if who == slobs then
	(locate self)$stdout.PutString["  It is slobs\n"]
      end if
    end unavailable
  end keepdroiding

  function getLabel -> [label : Character]
    if index < 10 then
      label <- character.literal['0'.ord + index]
    elseif index < 36 then
      label <- character.literal['a'.ord + index - 10]
    elseif index < 62 then
      label <- character.literal['A'.ord + index - 36]
    elseif index < 93 then
      label <- "`~!@#$%^&*()-_=+[]{}\\|;:'\",.<>/"[index - 62]
    else
      label <- '?'
    end if
  end getLabel

  process
    var label : Character <- self$label
    self.makeone
    self.makeone
    self.makeone
    var count : Integer <- 0
    var loops : Integer <- 0
    var out : OutStream
    loop
      self.keepdroiding
      count <- count + 1
      if count = reporthowoften then
	out <- (locate self)$stdout
	out.putchar[label]
	out.flush
	out <- nil
	count <- 0
	loops <- loops + 1
	exit when loops = loophowmany
      end if
    end loop
    out.putchar[label]
    out.putstring["done"]
    out.flush
  end process
end droid

const driver <- object driver
  process
    stdout.putstring["Starting\n"]
    for i : Integer <- 0 while i < howmanydroids by i <- i + 1
      const junk <- droid.create[i]
    end for
  end process
end driver
