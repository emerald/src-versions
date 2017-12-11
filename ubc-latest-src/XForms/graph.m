const xgraph <- object xgraph
  field color : Integer <- FL_RED

  const inverse <- object inverse
    export function defined[x : Real] -> [r : Boolean]
      r <- x != 0.0
    end defined

    export function value[x : Real] -> [y : Real]
      y <- 1.0 / x
    end value
  end inverse
  const cubic <- object cubic
    export function defined[x : Real] -> [r : Boolean]
      r <- true
    end defined

    export function value[x : Real] -> [y : Real]
      y <- x * x * x
    end value
  end cubic
  const quadratic <- object quadratic
    export function defined[x : Real] -> [r : Boolean]
      r <- true
    end defined

    export function value[x : Real] -> [y : Real]
      y <- x * x
    end value
  end quadratic
  const linear <- object linear
    export function defined[x : Real] -> [r : Boolean]
      r <- true
    end defined

    export function value[x : Real] -> [y : Real]
      y <- x
    end value
  end linear
  const exponential <- object exponential
    export function defined[x : Real] -> [r : Boolean]
      r <- true
    end defined

    export function value[x : Real] -> [y : Real]
      y <- 2.0 ^ x
    end value
  end exponential
  const invexponential <- object invexponential
    export function defined[x : Real] -> [r : Boolean]
      r <- true
    end defined

    export function value[x : Real] -> [y : Real]
      y <- 2.0 ^ -x
    end value
  end invexponential

  process
    const myxf : XForms <- XForms.create
    const mygraph <- GraphPaper.create[myxf, 400, 8.0]
    const goer <- object foo
      process
	myxf.go
      end process
    end foo
    (locate self).delay[time.create[1,0]]
    mygraph.plot[linear, 0.1, color]
    (locate self).delay[time.create[1,0]]
    mygraph.plot[quadratic, 0.1, color]
    (locate self).delay[time.create[1,0]]
    mygraph.plot[cubic, 0.1, color]
    (locate self).delay[time.create[1,0]]
    mygraph.plot[inverse, 0.1, color]
    (locate self).delay[time.create[1,0]]
    mygraph.plot[exponential, 0.1, color]
    (locate self).delay[time.create[1,0]]
    mygraph.plot[invexponential, 0.1, color]
    myxf.go
  end process
end xgraph
