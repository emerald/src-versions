const driver <- object driver
  process
    var s : String <- "abcdefg"
    var c : character <- '!'
    loop
      exit when s = ""
      stdout.putstring["value: "||c.asString||"\n"]
      c, s <- s[0], s[1, s.length - 1]
    end loop
    stdout.putstring["Done\n"]
  end process
end driver
