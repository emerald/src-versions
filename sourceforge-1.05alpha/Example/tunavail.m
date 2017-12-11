const tunavil <- object tunavil
  process
    var a : Integer
    var b : String
    unavailable [ c : Any ]
      c <- "abc"
    end unavailable
  end process
end tunavil
