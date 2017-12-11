const tassert <- class tassert
  const foo <- "This is a string"
    var x : Integer <- 34
    var c : Character <- 'x'
    var d : Character <- '\011'
    initially
      self.foo
    end initially
  operation foo 
    assert false
  end foo
end tassert

const xx <- object xx
  initially
    var i : Integer <- 33
    var j : String <- "abc"
    var a : Any <- tassert.create
  end initially
end xx
