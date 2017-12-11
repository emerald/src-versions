const Color <- Integer

const Position <- immutable class Position[px : Integer, py : Integer]
  const field x : Integer <- px
  const field y : Integer <- py
end Position

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

export matrix

const formsize <- 400
const width <- 10
const screensize <- formsize / width
const HZ <- 5

const tront <- typeobject tront
  operation poke
  operation drawRect[integer, integer, color]
end tront

const mob <- matrix.of[Boolean]

const mgr <- class mgr
  field dead : Boolean <- false
  const trons <- Vector.of[tront].create[12]
  const screen <- mob.create[screensize, screensize]
  const colors <- { FL_RED, FL_BLUE, FL_GREEN, FL_YELLOW, FL_MAGENTA, FL_CYAN, FL_TOMATO, FL_INDIANRED, FL_SLATEBLUE, FL_PALEGREEN, FL_DARKGOLD, FL_ORCHID }
  const xs <- { 0, screensize - 1, 0, screensize - 1, 1, 1, 1, 1, 1, 1, 1, 1 : Integer}
  const ys <- { 0, 0, screensize - 1, screensize - 1, 1, 1, 1, 1, 1, 1, 1, 1 : Integer}
  const dxs <- { 1, -1, 1, -1, 1, 1, 1, 1, 1, 1, 1, 1 }
  const dys <- { 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1 }

  export operation register [t : tront] -> [m : mob, c : Color, x : Integer, y : Integer, dx : Integer, dy : Integer, trs : Vector.of[tront]]
    for i : Integer <- 0 while i <= trons.upperbound by i <- i + 1
      if trons[i] == nil then
	trons[i] <- t
	c, x, y, dx, dy <- colors[i], xs[i], ys[i], dxs[i], dys[i]
	m <- screen
	trs <- trons
	exit
     end if
    end for
  end register
  export operation deregister[t : tront]
   for i : Integer <- 0 while i <= trons.upperbound by i <- i + 1
      if trons[i] == t then
	trons[i] <- nil
      end if
    end for
  end deregister
  initially
    screen.setAll[false]
  end initially
  process
    const here <- locate self
    here.delay[Time.create[5, 0]]
    const t <- Time.create[0, 1000000 / HZ]
    loop
      exit when dead
      for i : Integer <- 0 while i <= trons.upperbound by i <- i + 1
	if trons[i] !== nil then trons[i].poke end if
      end for
      here.delay[t]
    end loop
  end process
end mgr

const tron <- object tron
  const here <- locate self

  const mgrtype <- typeobject mgr
    operation register [tront] -> [mob, color, integer, integer, integer, integer, Vector.of[tront]]
    operation deregister [tront]
    operation setdead [Boolean]
  end mgr
  var mymgr : mgrtype

  const myxf : XForms <- XForms.create
  const path <- Array.of[Position].create[-200]
  var screen : mob
  var trons : Vector.of[tront]
  var cx, cy : Integer
  var dx : Integer
  var dy : Integer
  var phase : Boolean <- false
  var mycolor : Color

  export operation drawRect[x : Integer, y : Integer, c : Color]
    const px <- x * width
    const py <- y * width
    primitive "NCCALL" "XFORMS" "FL_RECTANGLE" [] <- [1, px, py, width, width, c]
    myxf.flush
  end drawRect

  export operation drawCircle[x : Integer, y : Integer, w : Integer, h : Integer, c : Color]
    primitive "NCCALL" "XFORMS" "FL_OVAL" [] <- [0, x, y, w, h, c]
  end drawCircle

  operation minmax[a : Integer, b : Integer] -> [r : Integer, s : Integer]
    if a < b then
      r, s <- a, b
    else
      r, s <- b, a
    end if
  end minmax

  export operation Draw[x : Integer, y : Integer, w : Integer, h : Integer]
    % stdout.putstring["Draw "|| x.asString || " " || y.asString || " " || w.asString || " " || h.asString || "\n"]
    primitive "NCCALL" "XFORMS" "FL_RECTANGLE" [] <- [1, x, y, w, h, FL_BLACK]
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
%    stdout.putstring["Keyboard "||key.asString||" '"||Character.literal[key].asString||"' @ ("|| mx.asString||","||my.asString||")\n"]
    if 65361 = key then
      dx <- -1
      dy <- 0
    elseif 65362 = key then
      dx <- 0
      dy <- -1
    elseif key = 65363 then
      dx <- 1
      dy <- 0
    elseif key = 65364 then
      dx <- 0
      dy <- 1
    end if
  end Keyboard
  export operation Step
    % stdout.putstring["Step\n"]
  end Step
  export operation Other[key : Integer]
    stdout.putstring["Other "|| key.asString || "\n"]
  end Other

  operation boom
    mymgr$dead <- true
  end boom

  export operation poke
    cx <- cx + dx
    cy <- cy + dy
    if cx < 0 or cx >= screensize or cy < 0 or cy >= screensize or screen[cx, cy] then
      self.boom
    else
      screen[cx, cy] <- true
    end if
    for i : Integer <- 0 while i <= trons.upperbound by i <- i + 1
      if trons[i] !== nil then
	trons[i].drawRect[cx, cy, mycolor]
      end if
    end for
	
    path.addupper[position.create[cx, cy]]
    if phase then
      const old <- path.removelower
      for i : Integer <- 0 while i <= trons.upperbound by i <- i + 1
	if trons[i] !== nil then
	  trons[i].drawRect[old$x, old$y, FL_BLACK]
	end if
      end for
      screen[old$x, old$y] <- false
    end if
    phase <- ! phase
    myxf.flush
  end poke

  process
    const myform <- Form.create[myxf, fl_up_box, 400, 400]
    const myfree <- free.create[myxf, fl_input_free, 0, 0, 400, 400, "", self]
    myform.add[myfree]
    myform.show[fl_place_free, fl_fullborder, "Things"]
    const rd : Directory <- here$rootDirectory
    mymgr <- view rd.lookup["tronmgr"] as mgrtype
    if mymgr == nil then
      mymgr <- mgr.create
      rd.insert["tronmgr", mymgr]
    end if
    screen, mycolor, cx, cy, dx, dy, trons <- mymgr.register[self]
    path.addupper[Position.create[cx, cy]]
    self.drawRect[cx, cy, mycolor]
    myxf.go
  end process
end tron
