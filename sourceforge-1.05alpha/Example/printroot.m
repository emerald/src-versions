const printroot <- object printroot
  process
    var root : String
    primitive "GETROOTDIR" [root] <- []
    stdout.putstring["Emerald root is: " || root || "\n"]
  end process
end printroot
