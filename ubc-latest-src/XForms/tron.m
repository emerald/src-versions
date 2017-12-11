% Stuff to do:
%   Disable join/leave while a game is going on.
%   When a new display starts in the middle of a game, we don't handle
%     it right.  We need to block out joins until the game is over.

const Color <- Integer
const background <- FL_BLACK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%			THE BASE GAGGLE CLASS                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Every subclass of this class, must declare a class const named memberType  %
% that is the type of the elements of the Gaggle.                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
const maxtrons <- 9

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
%		  A highly consistent tron gaggle                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% One display generates the lub/dub, and when the others notice that he is dead
% they take over.

% Each tron invokes his display (or returns from the keyboard invocation) with
% his direction each time it changes.  The display figures out where all of the
% snakes it is managing are going, and returns to lub a vector of spots to
% color (including the ones to uncolor).  The manager then generates a dub 
% which propagates all this information to everybody.

const TronGaggle <- immutable class TronGaggle (Gaggle) 
  class const memberType <- Display
end TronGaggle

%
% A totally replicated Vector.of[Tron] to keep track of the players
%
const TronPlayersGaggle <- immutable class TronPlayersGaggle (Gaggle) 
  class const memberType <- Array.of[Tron]

  export operation join[max : Integer]
    const myarray <- Array.of[Tron].create[max]
    if self.upperbound >= 0 then
      for i : Integer <- 0 while i < max by i <- i + 1
	myarray[i] <- self.gete[i]
      end for
    end if
    self.addMember[myarray]
  end join

  export operation gete[index : Integer] -> [t : Tron]
    const target <- self.invokee
    if target !== nil then
      t <- target[index]
    end if
    unavailable
      t <- self.getE[index]
    end unavailable
  end gete

  operation trysete[d : memberType, index : Integer, t : Tron]
    if d !== nil then
      d[index] <- t
    end if
    unavailable
    end unavailable
  end trysete

  operation findFree -> [index : Integer]
    const target <- self.invokee
    index <- 0
    loop
      exit when target[index] == nil
      index <- index + 1
    end loop
    failure
      index <- 0
    end failure
  end findFree
	
  operation sete[index : Integer, t : Tron]
    const limit <- self.upperbound
    for i : Integer <- 0 while i <= limit by i <- i + 1
      self.trysete[self.invokee[i], index, t]
    end for
  end sete

  export operation newplayer[t : Tron] -> [index : Integer]
    index <- self.findFree
    self.sete[index, t]
  end newplayer

  export operation deleteplayer[index : Integer]
    self.sete[index, nil]
  end deleteplayer

  operation dead[t : Tron] -> [r : Boolean]
    r <- false
    t.ok
    unavailable
      r <- true
    end unavailable
  end dead

  export operation verify
    const limit <- self.invokee.upperbound
    for i : Integer <- 0 while i <= limit by i <- i + 1
      const t <- self.invokee.getelement[i]
      if t !== nil then
	if self.dead[t] then
	  self.sete[i, nil]
	end if
      end if
    end for
  end verify

end TronPlayersGaggle

%
% A position on the screen, including the color that it should be
%
const Position <- immutable class Position[px : Integer, py : Integer, pc : Color]
  const field x : Integer <- px
  const field y : Integer <- py
  const field c : Color   <- pc
end Position

const ivop <- ImmutableVector.of[Position]

%
% A matrix, used for quick searching for collisions
%

const matrix <- immutable object matrix
  export function of [eType : Type] -> [r : MCType]
    forall
      eType
    where voe <- Vector.of[eType]
    where
      MCType <- immutable typeobject MCType
	operation create [Integer, Integer] -> [MType]
	function getSignature -> [Signature]
      end MCType
    where
      MType <- typeobject MType
	operation setAll[eType]
	operation setElement[Integer, Integer, eType]
	operation getElement[Integer, Integer] -> [eType]
      end MType
    r <- class MClass [b1 : Integer, b2 : Integer]
      const e <- voe.create[b1 * b2]

      export operation setAll[v : eType]
	const limit <- e.upperbound
	for i : Integer <- 0 while i <= limit by i <- i + 1
	  e[i] <- v
	end for
      end setAll

      export operation setElement[i1 : Integer, i2 : Integer, v : eType]
	assert i1 < b1
	assert i2 < b2
	e[i2 + i1 * b2] <- v
      end setElement

      export function getElement[i1 : Integer, i2 : Integer] -> [v : eType]
	assert i1 < b1
	assert i2 < b2
	v <- e[i2 + i1 * b2]
      end getElement
    end MClass
  end of
end matrix

const width <- 10
const screensize <- 42
const formsize <- 420

const mob <- matrix.of[Integer]

const info <- immutable record info
  var c : Color
  var x : Integer
  var y : Integer
  var dx : Integer
  var dy : Integer
end info

const tron <- class tron[screen : mob]
  var keyup, keydown, keyleft, keyright : Integer
  var myinfo : Info
  field mycolor : Color
  field cx : Integer
  field cy : Integer
  field moves : Integer <- 0
  var dx : Integer
  var dy : Integer
  var phase : Integer <- 0
  field imdead  : Boolean <- false
  const path <- Array.of[Position].create[-200]
  const stdout <- (locate self)$stdout
  var movessinceinput : Integer <- 0
  field mydisplay : Display

  export operation ok
  end ok

  export operation setup[pkeyup : Integer, pkeydown : Integer,
	pkeyleft : Integer, pkeyright : Integer,
	pmyinfo : Info]
    keyup <- pkeyup
    keydown <- pkeydown
    keyleft <- pkeyleft
    keyright <- pkeyright
    myinfo <- pmyinfo
    self.doreset
  end setup

  export operation reset
    self.doreset
  end reset

  export operation doreset
    cx <- myinfo$x
    cy <- myinfo$y
    dx <- myinfo$dx
    dy <- myinfo$dy
    mycolor <- myinfo$c
    phase <- 0
    imdead <- false
    loop
      exit when path.empty
      const junk <- path.removeUpper
    end loop
    path.slideTo[0]
    path.addUpper[Position.create[cx, cy, background]]
    moves <- 0
  end doreset
    
  export operation Keyboard[mx : Integer, my : Integer, key : Integer]
    movessinceinput <- 0
    if key = keyleft then
      dx <- -1 dy <- 0
    elseif key = keyright then
      dx <- 1 dy <- 0
    elseif key = keyup then
      dx <- 0 dy <- -1
    elseif key = keydown then
      dx <- 0 dy <- 1
    else
      assert false
    end if
  end Keyboard

  function random[n : Integer] -> [r : Integer]
    primitive "NCCALL" "RAND" "RANDOM" [r] <- []
    r <- r # n
  end random

  operation newDirection[odx : Integer, ody : Integer, i : Integer] -> [ndx : Integer, ndy : Integer]
    const r <- self.random[4]

    if i <= 4 and r = 0 or i > 4 and odx = 0 and ody = 1 then
      ndx <- -1 ndy <- 0
    elseif i <= 4 and r = 1 or i > 4 and odx = 0 and ody = -1 then
      ndx <- 1 ndy <- 0
    elseif i <= 4 and r = 2 or i > 4 and odx = 1 and ody = 0 then
      ndx <- 0 ndy <- 1
    elseif i <= 4 and r = 3 or i > 4 and odx = -1 and ody = 0 then
      ndx <- 0 ndy <- -1
    end if
  end newDirection

  operation autopilot
    var i : Integer <- 0
%    (locate self)$stdout.putstring["Autopilot started: "||dx.asString||"x"||dy.asString||"\n"]
    loop
      exit when i > 8
      i <- i + 1
      const dead <- cx+dx < 0 or
		    cy+dy < 0 or
		    cx + dx >= screensize or
		    cy + dy >= screensize or
		    screen[cx+dx, cy+dy] != 0
      const rturn <- i == 1 and self.random[100] < 5

%      (locate self)$stdout.putstring[" i = "||i.asString||" dead = "||dead.asString||"rturn = "||rturn.asString||"\n"]
      exit when !dead and !rturn
      dx, dy <- self.newDirection[dx, dy, i]
    end loop
%    (locate self)$stdout.putstring["Autopilot ended: "||dx.asString||"x"||dy.asString||"\n"]
  end autopilot
    
  export operation lub -> [movesto : ivop, movesfrom : ivop]
    if ! imdead then
      if movessinceinput > 50 then
	self.autopilot
      end if
      movessinceinput <- movessinceinput + 1
      cx <- cx + dx
      cy <- cy + dy
  
      if cx < 0 or cx >= screensize or cy < 0 or cy >= screensize then
	% dead
      else
	const here <- position.create[cx, cy, mycolor]
	const erase<- position.create[cx, cy, background]
	path.addupper[erase]
	movesto <- { here : Position }
	if phase == myDisplay$shortenInterval then
	  const old : Position <- path.removelower
	  movesfrom <- { old : Position}
	  phase <- 0
	else
	  phase <- phase + 1
	end if
	moves <- moves + 1
      end if
    end if
  end lub

  export operation dub [movesto : ivop, movesfrom : ivop] -> [stillAlive : Integer]
    stillAlive <- 1
    if !imdead then
      imdead <- cx < 0 or cx >= screensize or
	      cy < 0 or cy >= screensize or screen[cx, cy] != 1
      if imdead then
%	(locate self)$stdout.putstring["I'm dead\n"]
      end if
    end if
    if imdead then stillAlive <- 0 end if
  end dub
end tron

const display <- class display
  var tron1 : Tron
  var HZ : Integer <- 13
  var shortenInterval : Integer <- 3
  var playing : Boolean <- false
  field fullyReady : Boolean <- false
  const screen <- mob.create[screensize, screensize]
  const infos <- {
    info.create[FL_RED, 0, 0, 1, 0],
    info.create[FL_BLUE, screensize - 1, 0, -1, 0],
    info.create[FL_GREEN, 0, screensize - 1, 1, 0],
    info.create[FL_YELLOW, screensize - 1, screensize - 1, -1, 0],
    info.create[FL_MAGENTA, 0, screensize / 2, 1, 0],
    info.create[FL_CYAN, screensize - 1, screensize / 2, -1, 0],
    info.create[FL_TOMATO, screensize / 2, 0, 0, 1],
    info.create[FL_INDIANRED, screensize / 2, screensize - 1, 0, -1],
    info.create[FL_SLATEBLUE, screensize / 2, screensize / 2, 1, 0],
   : info}
  
  const here <- locate self
  const stdout <- here$stdout

  field trong : trongaggle
  field playerg : TronPlayersGaggle
  field theboss : Display <- nil

  const myxf <- XForms.create
  var myvalslider, myshortenslider : ValSlider
  var myform : Form
  var colorbox : XFormObject
  var tronbox : XFormObject

  var tron1index : Integer

  const tron1left <- 65361
  const tron1up <- 65362
  const tron1right <- 65363
  const tron1down <- 65364

  const synch <- monitor object synch
    var nArrived, nExpected : Integer
    const c : Condition <- Condition.create
    
    export operation prepareWait[n : Integer]
      nExpected <- n
      nArrived <- 0
    end prepareWait
  
    export operation doWait
      if nArrived < nExpected then
	wait c
      end if
    end doWait

    export operation done
      nArrived <- nArrived + 1
      if nArrived = nExpected then
	signal c
      end if
    end done
  end synch

  const death <- monitor object death
    var nArrived, nExpected : Integer
    const c : Condition <- Condition.create
    
    export operation prepareWait[n : Integer]
      nExpected <- n
      nArrived <- 0
    end prepareWait
  
    export operation doWait
      if nArrived < nExpected then
	wait c
      end if
    end doWait

    export operation done
      nArrived <- nArrived + 1
      if nArrived = nExpected then
	signal c
      end if
    end done
  end death

  field allmovetos : ivop
  field allmovefroms : ivop
  field stillAlive : Integer

  const handlego <- object handlego
    var going : Boolean <- false
    export operation disable
    end disable
    export operation CallBack [f : XFormObject]
      if aDisplay$theboss == aDisplay and !going then
	going <- true
	f.setColor[FL_INACTIVE_COL, FL_BUTTON_COL2]
	f.deactivate
	adisplay.go
      end if
    end CallBack
    export operation done
      going <- false
      var max : Integer <- 0
      const cs : Array.of[Color] <- Array.of[Color].create[-4]
      for i : Integer <- 0 while i < maxtrons by i <- i + 1
	const t <- aDisplay$playerg.gete[i]
	if t !== nil then
	  var livedfor : Integer
	  var hesdead : Boolean
	  var c : Color
	  begin
	    hesdead <- t$imdead
	    livedfor <- t$moves
	    c <- t$mycolor
	    unavailable
	      livedfor <- 0
	      c <- FL_BLACK
	    end unavailable
	  end
	  if !hesdead and livedfor > 1 or livedfor > max then
	    if hesdead then
	      max <- livedfor
	    else
	      max <- livedfor + 1
	    end if
	    loop
	      exit when cs.empty
	      const junk <- cs.removeupper
	    end loop
	    cs.addupper[c]
	  elseif livedfor == max then
	    cs.addupper[c]
	  end if
	end if
      end for
      if cs.empty then
	(locate self)$stdout.putstring["No winner\n"]
	cs.addupper[FL_BLACK]
      elseif cs.upperbound == 0 then
	(locate self)$stdout.putstring["The winner is "||cs[0].asString|| " with "||max.asString||" moves\n"]
      else
	(locate self)$stdout.putstring["There is a tie "||(cs.upperbound + 1).asString||"\n"]
      end if
      aDisplay.winner[ImmutableVector.of[Color].literal[cs]]
      here.delay[Time.create[5,0]]
      myxf.flush
    end done
  end handlego

  export operation setHZ [val : Integer]
    HZ <- val
    const foo <- object foo
      process
	myvalslider.set[val.asReal]
      end process
    end foo
  end setHZ

  export function getHZ -> [val : Integer]
    val <- HZ
  end getHZ

  export operation setshortenInterval [val : Integer]
    shortenInterval <- val
    const foo <- object foo
      process
	myshortenslider.set[val.asReal]
      end process
    end foo
  end setshortenInterval

  export function getshortenInterval -> [val : Integer]
    val <- shortenInterval
  end getshortenInterval

  export operation showwinner[cs : ImmutableVector.of[Color]]
    if ! playing then return end if
    playing <- false
    if cs.upperbound = 0 then
      self.drawText[100, "Winner!", cs[0]]
    else
      for i : Integer <- 0 while i <= cs.upperbound by i <- i + 1
	self.drawText[i * 40, "We have a tie!", cs[i]]
      end for
    end if
    myxf.flush
  end showwinner

  export operation flashsub[s : String, c : Color]
    self.blank
    self.drawText[100, s, c]
    myxf.flush
  end flashsub

  export operation winner[c : ImmutableVector.of[Color]]
    for i : Integer <- 0 while i <= trong.upperbound by i <- i + 1
      const other <- trong[i]
      if other !== self then
	const junk <- object dowinners
	  process
	    other.showwinner[c]
	    unavailable
	    end unavailable
	  end process
	end dowinners
      end if
    end for
    self.showwinner[c]
  end winner
    
  export operation flash[s : String, c : Color]
    for i : Integer <- 0 while i <= trong.upperbound by i <- i + 1
      const other <- trong[i]
      if other !== self then
	const junk <- object doflashs
	  process
	    other.flashsub[s, c]
	    unavailable
	      i <- i - 1
	    end unavailable
	  end process
	end doflashs
      end if
    end for
    self.flashsub[s, c]
  end flash
    
  export operation ok
    (locate self).delay[time.create[60 * 60 * 24,0]]
  end ok
	
  export operation blank
    if !fullyReady then return end if
    primitive "NCCALL" "XFORMS" "FL_RECTANGLE" [] <- [1, 10, 10, formsize, formsize, background]
  end blank

  export operation drawText[offset : Integer, msg : String, c : Color]
    if !fullyready then return end if
    const basey <- 10 + offset
    primitive "NCCALL" "XFORMS" "FL_DRAW_TEXT" [] <- [FL_ALIGN_CENTER, 10, basey, formsize, 200, c, FL_SHADOW_STYLE, 48, msg]
  end drawText

  export operation drawRect[x : Integer, y : Integer, c : Color]
    const px <- x * width + 10
    const py <- y * width + 10
    primitive "NCCALL" "XFORMS" "FL_RECTANGLE" [] <- [1, px, py, width, width, c]
    myxf.flush
  end drawRect

  export operation drawCircle[x : Integer, y : Integer, w : Integer, h : Integer, c : Color]
    primitive "NCCALL" "XFORMS" "FL_OVAL" [] <- [0, x, y, w, h, c]
  end drawCircle

  initially
    assert screensize * width = formsize
    screen.setAll[0]
  end initially

  export operation Draw[x : Integer, y : Integer, w : Integer, h : Integer]
%    stdout.putstring["Draw "|| x.asString || " " || y.asString || " " || w.asString || " " || h.asString || "\n"]
    primitive "NCCALL" "XFORMS" "FL_RECTANGLE" [] <- [1, x, y, w, h, FL_WHITE]
  end Draw

  export operation Enter
    % stdout.putstring["Enter\n"]
  end Enter

  export operation Leave
    % stdout.putstring["Leave\n"]
  end Leave

  export operation Motion[mx : Integer, my : Integer]
    % stdout.putstring["Motion @ ("|| mx.asString||","||my.asString||")\n"]
  end Motion

  export operation Push[mx : Integer, my : Integer, key : Integer]
    % const keys <- { "", "left", "middle", "right" }
    % stdout.putstring["Push "|| keys[key]|| " @ (" || mx.asString || ","||my.asString||") \n"]
  end Push

  export operation Release[key : Integer]
    % stdout.putstring["Release"||key.asString||"\n"]
  end Release

  export operation DoubleClick
    % stdout.putstring["DoubleClick\n"]
  end DoubleClick

  export operation TripleClick
    % stdout.putstring["TripleClick\n"]
  end TripleClick

  export operation Mouse[mx : Integer, my : Integer, key : Integer]
    % stdout.putstring["Mouse @ ("|| mx.asString||","||my.asString||") "||key.asString||"\n"]
  end Mouse

  export operation Focus
    % stdout.putstring["Focus\n"]
  end Focus

  export operation Unfocus
    % stdout.putstring["Unfocus\n"]
  end Unfocus

  export operation Keyboard[mx : Integer, my : Integer, key : Integer]
    % stdout.putstring["Keyboard "||key.asString||" '"||Character.literal[key].asString||"'\n"]
    if key = tron1left or key = tron1right or key = tron1up or key = tron1down then
      if tron1 !== nil then
	tron1.keyboard[mx, my, key]
      end if
    end if
  end Keyboard

  export operation Step
    % stdout.putstring["Step\n"]
  end Step

  export operation Other[key : Integer]
    stdout.putstring["Other "|| key.asString || "\n"]
  end Other
  
  export operation join[which : Integer] -> [playerindex : Integer]
    assert which = 0
    tron1 <- tron.create[screen]
    playerindex <- playerg.newplayer[tron1]
    tron1index <- playerindex
    tron1.setMyDisplay[aDisplay]
    tron1.setup[tron1up, tron1down, tron1left, tron1right,infos[playerindex]]
  end join

  export operation reset
    playing <- true
    screen.setAll[0]
    self.blank
    myxf.flush
    if tron1 !== nil then
      tron1.reset
      const px <- tron1$cx
      const py <- tron1$cy
      const pc <- tron1$mycolor
      self.drawRect[px, py, pc]
    end if
  end reset

  operation append[a : ivop, b : ivop] -> [c : ivop]
    if a == nil then
      c <- b
    elseif b == nil then
      c <- a
    else
      c <- a.catenate[b]
    end if
  end append

  export operation lub -> [movesto : ivop, movesfrom : ivop]
    if !playing then return end if
    var lmovesfrom, lmovesto : ivop
    if tron1 !== nil then
      lmovesto, lmovesfrom <- tron1.lub
      movesfrom <- self.append[movesfrom, lmovesfrom]
      movesto <- self.append[movesto, lmovesto]
    end if
  end lub

  operation show[vt : ivop]
    for i : Integer <- 0 while i <= vt.upperbound by i <- i + 1
      const t <- vt[i]
      if t$c == background then
	if screen[t$x, t$y] > 0 then
	  screen[t$x, t$y] <- screen[t$x, t$y] - 1
	end if
	if screen[t$x, t$y] == 0 then
	  self.drawRect[t$x, t$y, t$c]
	end if
      else
	screen[t$x, t$y] <- screen[t$x, t$y] + 1
	if screen[t$x, t$y] == 1 then
	  self.drawRect[t$x, t$y, t$c]
	end if
      end if
    end for
  end show

  export operation dub[movesto : ivop, movesfrom : ivop] -> [sAlive : Integer]
    var newAlive : Integer
    sAlive <- 0
    if !playing then
      return
    end if

    if movesfrom !== nil then self.show[movesfrom] end if
    if movesto !== nil then self.show[movesto] end if

    if tron1 !== nil then
      newAlive <- tron1.dub[movesto, movesfrom]
      sAlive <- sAlive + newAlive
    end if
  end dub

  export operation resetMoves
    allmovetos <- nil
    allmovefroms <- nil
  end resetMoves

  export operation someMoveTos[movetos : ivop]
    if movetos !== nil then
      if allmovetos == nil then
	allmovetos <- movetos
      else
	allmovetos <- allmovetos || movetos
      end if
    end if
  end someMoveTos

  export operation someMoveFroms[movefroms : ivop]
    if movefroms !== nil then
      if allmovefroms == nil then
	allmovefroms <- movefroms
      else
	allmovefroms <- allmovefroms || movefroms
      end if
    end if
    synch.done
  end someMoveFroms

  export operation someAliveInfo [nAlive : Integer]
    stillAlive <- stillAlive + nAlive
    synch.done
  end someAliveInfo

  export operation go
    const theGoer <- object theGoer
      const here <- locate self
      const stdout <- here$stdout
      const onesecond <- Time.create[1, 0]
      var val : Boolean <- true

      operation ping[other : Display] -> [r : Boolean]
	r <- true
	other.ok
	failure
	  r <- false
	end failure
      end ping

      export operation trylub[other : Display] -> [movetos : ivop, movefroms : ivop]
	if other !== nil then
	  movetos, movefroms <- other.lub
	end if
	unavailable
	end unavailable
      end trylub
      export operation trydub[other : Display, movetos : ivop, movefroms : ivop] -> [sAlive : Integer]
	sAlive <- 0
	if other !== nil then
	  sAlive <- other.dub[movetos, movefroms]
	end if
	unavailable
	end unavailable
      end trydub
      process
	loop
	  if aDisplay$theboss == aDisplay then
	    playerg.verify
	    tronbox.setColor[FL_RED, FL_BUTTON_COL2]
	    if val == true then
	      for count : Integer <- 3 while count > 0 by count <- count - 1
		aDisplay.flash[count.asString, FL_RED]
		here.delay[onesecond]
	      end for
	      val <- false
	      for i : Integer <- 0 while i <= trong.upperbound by i <- i + 1
		const other <- trong[i]
		const junk <- object doresets
		  process
		    other.reset
		    unavailable
		    end unavailable
		  end process
		end doresets
	      end for
	      here.delay[Time.create[0, 20000]]
	    end if
  
	    const startTime <- here.getTimeOfDay
	    var nextTick : Time <- startTime
	    var movetos, movefroms : ivop
	    
	    loop
	      nextTick <- nextTick + Time.create[0, 1000000/aDisplay$HZ]
	      const delayTime <- nextTick - here.getTimeOfDay
%	      stdout.putstring["Delaying for " || delayTime.asString || "\n"]
%	      here.Delay[delayTime]
	      here.Delay[Time.create[0, 1000000/aDisplay$HZ]]
	      aDisplay.resetMoves
	      const howmany <- trong.upperbound + 1
	      synch.prepareWait[howmany]
	      for i : Integer <- 0 while i < howmany by i <- i + 1
		%stdout.putstring["I am the boss"||i.asString||"\n"]  
		const other <- trong[i]
		const junk <- object dolubs
		  process
		    % stdout.putstring["lubbing\n"]
		    movetos, movefroms <- theGoer.trylub[other] 
		    aDisplay.someMoveTos[movetos]
		    aDisplay.someMoveFroms[movefroms]
		   
		    unavailable
		      %stdout.putstring["Not available\n"]		  
		    end unavailable
		  end process
		end dolubs
	      end for
	      synch.doWait
	      var newAlive : Integer
	      aDisplay$stillAlive <- 0
	      synch.prepareWait[howmany]
	      for i : Integer <- 0 while i < howmany by i <- i + 1
		const other <- trong[i]
		const junk <- object dodubs
		  process
		    
		    % stdout.putstring["dubbing\n"]
		    newAlive <- theGoer.trydub[other, aDisplay$allmovetos, aDisplay$allmovefroms]
		    aDisplay.someAliveInfo[newAlive]
		    unavailable
		    end unavailable
		  end process
		end dodubs
	      end for
	      synch.doWait
	      exit when aDisplay$stillAlive <= 1
	    end loop
	    val <- true
	    handlego.done
	  else
	    val <- false
%	    stdout.putstring["I am not the boss\n"]
	    here.delay[Time.create[0, 2000]]
	    const startTime <- here.getTimeOfDay
	    var nextTick : Time <- startTime
	    loop 
	      nextTick <- nextTick + Time.create[0, 500000/aDisplay$HZ]
	      const delayTime <- nextTick - here.getTimeOfDay
	      here.Delay[delayTime]
	      exit when !self.ping[aDisplay$theboss]
	    end loop
	    stdout.putstring["The boss has died\n"]
	    if trong[0] == aDisplay then
	      aDisplay$theboss <- aDisplay
	      const rd <- here$rootDirectory
	      loop
		rd.insert["theboss", aDisplay]
		exit when rd.lookup["theboss"] == aDisplay
		stdout.putstring["Waiting to update theboss\n"]
		here.delay[time.create[0, 10000]]
	      end loop
	    else
	      aDisplay$theboss <- trong[0]
	    end if
	  end if
	end loop
      end process
    end theGoer
  end go
  
  export operation setColor[which : Integer, c : Color]
    colorbox.setColor[c, FL_BLACK]
    myxf.flush
  end setColor

  operation doPlayerControl[]
    colorbox <- Box.create[myxf, fl_up_box, formsize + 25, 15, 180, 30, ""]
  end doPlayerControl

  operation checkSkew
    const all <- here$activeNodes
    const mytime <- here$timeOfDay
    const lwb <- Time.create[-2, 0]
    const upb <- Time.create[2, 0]

    for i : Integer <- 0 while i <= all.upperbound by i <- i + 1
      const h <- all[i]$theNode
      const mutt <- h$timeOfDay
      const skew <- mytime - mutt
      if lwb <= skew and skew <= upb then
	% Everything is fine
      else
	stdout.putstring["The clock on "||h$name||"is off by "||skew.asString||" seconds\n"]
	primitive "NCCALL" "MISK" "UEXIT" [] <- [0]
      end if
    end for
  end checkSkew

  process
    myform <- Form.create[myxf, fl_up_box, formsize + 200 + 20, formsize + 20]
    const myfree <- free.create[myxf, fl_input_free, 10, 10, formsize, formsize, "", self]

    const handlequit <- object handlequit
      export operation CallBack [f : XFormObject]
	myxf.die
	primitive "NCCALL" "MISK" "UEXIT" [] <- [0]
      end CallBack
    end handlequit

    here.delay[Time.create[0, 100000]]
    const rd : Directory <- here$rootDirectory
    trong <- view rd.lookup["TronGaggle"] as TronGaggle
    if trong == nil then
      trong <- TronGaggle.create
      rd.insert["TronGaggle", trong]
      rd.insert["theboss", self]
%      stdout.putstring["I should be the boss\n"]
      theboss <- self
    else
      theboss <- view rd.lookup["theboss"] as Display
    end if
    trong.addMember[self]
    self.checkSkew

    playerg <- view rd.lookup["TronPlayersGaggle"] as TronPlayersGaggle
    if playerg == nil then
      playerg <- TronPlayersGaggle.create
      rd.insert["TronPlayersGaggle", playerg]
    end if
    playerg.join[maxtrons]
    here.delay[Time.create[0, 100000]]

    myform.close
    myform.show[fl_place_free, fl_fullborder, "Tron @ " || here$name]
    myform.open

    const handlevalslider <- monitor object handlevalslider
      export operation CallBack[f : XFormObject]
	const myvalslider <- view f as Valslider
	const newspeed <- myvalslider.get.asInteger
	if aDisplay$theboss == aDisplay then
	  aDisplay$HZ <- newspeed
	  for i : Integer <- 0 while i <= playerg.upperbound by i <- i + 1
	    const thedisplay <- playerg.gete[i]$myDisplay
	    if thedisplay !== aDisplay then thedisplay$Hz <- newspeed end if
	  end for
	end if
      end CallBack
    end handlevalslider

    const handleshortenslider <- monitor object handleshortenslider
      export operation CallBack[f : XFormObject]
	const myvalslider <- view f as Valslider
	const newspeed <- myvalslider.get.asInteger
	if aDisplay$theboss == aDisplay then
	  aDisplay$shortenInterval <- newspeed
	  for i : Integer <- 0 while i <= playerg.upperbound by i <- i + 1
	    const thedisplay <- playerg.gete[i]$myDisplay
	    if thedisplay !== nil and thedisplay !== aDisplay then
	      thedisplay$shortenInterval <- newspeed
	    end if
	  end for
	end if
      end CallBack
    end handleshortenslider

    myvalslider <- valslider.create[myxf, fl_hor_nice_slider, formsize + 30, formsize - 120, 180, 30, "Speed", handlevalslider]
    myvalslider.setbounds[1.0, 50.0]
    myvalslider.setstep[1.0]
    myvalslider.setprecision[0]
    myvalslider.set[HZ.asReal]

    myshortenslider <- valslider.create[myxf, fl_hor_nice_slider, formsize + 30, formsize - 70, 180, 30, "Tail shorten interval", handleshortenslider]
    myshortenslider.setbounds[1.0, 10.0]
    myshortenslider.setstep[1.0]
    myshortenslider.setprecision[0]
    myshortenslider.set[shortenInterval.asReal]

    primitive "NCCALL" "XFORMS" "FL_RECTANGLE" [] <- [1, 10, 10, formsize, formsize, background]

    const quitbutton <- button.create[myxf, fl_normal_button, formsize + 30, formsize - 20, 180, 30, "Quit", handlequit]

    tronbox <- Box.create[myxf, fl_up_box, formsize +30, 100, 180, 180, "Snakies"]
    tronbox.setFontSize[48]
    tronbox.setFontStyle[FL_SHADOW_STYLE]
    
    self.doPlayerControl
    myform.close
    const playerIndex <- aDisplay.join[0]
    aDisplay.setColor[0, infos[playerIndex]$c]
    fullyReady <- true
    self.go
    myxf.go
  end process
end display

const driver <- object driver
  process
    const mydisplay <- display.create
  end process
end driver
