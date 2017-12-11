const foo <-
  object bar
    const R <-
      class R [xi : Integer]
        var i : Integer <- xi
%        field i : Integer <- xi
      end R
     var baz : R <- R.create[3]
%     const baz <- R.create[3]
  end bar
