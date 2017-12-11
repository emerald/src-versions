const tunavil <- object tunavil
  var a : Integer
  var b : String
  var d : Integer

  initially
    a <- 45
    b <- "this is a string"
    d <- 99
  end initially

  process
    var pa : String
    pa <- "this is another string"

    unavailable [ c ]
      c <- "abc"
      assert false
    end unavailable

    failure
      const c <- "abcdef"
    end failure
  end process
end tunavil

