const Func <- typeobject Func
  function value [d : Real] -> [r : Real]
  function defined[d : Real] -> [r : Boolean]
end Func

export Func

export GraphPaper

const GraphPaper <- class GraphPaper[myxf : XForms, size : Integer, range : Real]
  const rsize : Real <- size.asReal

  operation minmax[a : Integer, b : Integer] -> [r : Integer, s : Integer]
    if a < b then
      r, s <- a, b
    else
      r, s <- b, a
    end if
  end minmax

  operation Line[ox : Integer, oy : Integer, nx : Integer, ny : Integer, color: Integer]
    primitive "NCCALL" "XFORMS" "FL_LINE" [] <- [ox, oy, nx, ny, color]
  end Line

  function xtos[v : Real] -> [r : Integer]
    r <- (v / range * (rsize / 2.0) + 0.5).asInteger + size / 2
  end xtos

  function ytos[v : Real] -> [r : Integer]
    r <- size - self.xtos[v]
  end ytos

  operation RLine[ox : Real, oy : Real, nx : Real, ny : Real, color : Integer]
    self.line[self.xtos[ox], self.ytos[oy], self.xtos[nx], self.ytos[ny], color]
  end RLine

  operation Axes
    const origin <- size / 2
    const max <- size
    const min <- 0
    % x axis
    self.Line[min, origin, max, origin, FL_BLACK]
    % y axis
    self.Line[origin, min, origin, max, FL_BLACK]
    for i : Integer <- 1 while i < range.asInteger by i <- i + 1
      self.Line[self.xtos[-range], self.ytos[i.asReal], self.xtos[range], self.ytos[i.asReal], FL_GRAY35]
      self.Line[self.xtos[-range], self.ytos[-i.asReal], self.xtos[range], self.ytos[-i.asReal], FL_GRAY35]
      self.Line[self.xtos[i.asReal], self.ytos[-range], self.xtos[i.asReal], self.ytos[range], FL_GRAY35]
      self.Line[self.xtos[-i.asReal], self.ytos[-range], self.xtos[-i.asReal], self.ytos[range], FL_GRAY35]
    end for
  end Axes

  export operation clear
    primitive "NCCALL" "XFORMS" "FL_RECTANGLE" [] <- [1, 0, 0, size, size, FL_GRAY90]
  end clear

  export operation Draw[x : Integer, y : Integer, w : Integer, h : Integer]
    % stdout.putstring["Draw\n"]

  end Draw

  export operation Plot[f : Func, granularity : Real, color : Integer]
    var lastx : Real <- nil
    var lasty : Real <- nil
    var y : Real

    self.clear
    self.axes
    for d : Real <- 0.0 while d <= range by d <- d + granularity
      if f.defined[d] then
	y <- f.value[d]
      else
	y <- nil
      end if
%      (locate self)$stdout.putstring["("||lastx.asString||", "||lasty.asString||" -> ("||d.asString||", "||y.asString||")\n"]
      if y !== nil and lasty !== nil then
	self.RLine[lastx, lasty, d, y, color]
      end if
      lastx, lasty <- d, y
    end for
    lastx <- nil
    lasty <- nil
    for d : Real <- 0.0 while d >= -range by d <- d - granularity
      if f.defined[d] then
	y <- f.value[d]
      else
	y <- nil
      end if
%      (locate self)$stdout.putstring["("||lastx.asString||", "||lasty.asString||" -> ("||d.asString||", "||y.asString||")\n"]
      if y !== nil and lasty !== nil then
	self.RLine[lastx, lasty, d, y, color]
      end if
      lastx, lasty <- d, y
    end for
  end Plot

  export operation Enter
  end Enter
  export operation Leave
  end Leave
  export operation Motion[mx : Integer, my : Integer]
  end Motion
  export operation Push[mx : Integer, my : Integer, key : Integer]
  end Push

  export operation Release[key : Integer]
  end Release
  export operation DoubleClick
  end DoubleClick
  export operation TripleClick
  end TripleClick
  export operation Mouse[mx : Integer, my : Integer, key : Integer]
  end Mouse
  export operation Focus
  end Focus
  export operation Unfocus
  end Unfocus
  export operation Keyboard[mx : Integer, my : Integer, key : Integer]
  end Keyboard
  export operation Step
  end Step
  export operation Other[key : Integer]
  end Other

  process
    const myform <- Form.create[myxf, fl_up_box, size, size]
    const myfree <- free.create[myxf, fl_input_free, 0, 0, size, size, "", self]

    myform.close
    myform.show[fl_place_free, fl_fullborder, "Graph paper"]
  end process
end GraphPaper
