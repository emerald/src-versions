const ttok <- object ttok
  process
    var s, t, u, v : String
    loop
      stdout.putstring["String: "]
      stdout.flush
      exit when stdin.eos
      s <- stdin.getstring
      s <- s[0, s.upperbound]
      stdout.putstring["Delim: "]
      stdout.flush
      t <- stdin.getstring
      t <- t[0, t.upperbound]
      u, v <- s.token[t]
      stdout.putstring["\""]
      stdout.putstring[s]
      stdout.putstring["\".token[\""]
      stdout.putstring[t]
      stdout.putstring["\"] = [\""]
      stdout.putstring[u]
      stdout.putstring["\", \""]
      stdout.putstring[v]
      stdout.putstring["\"]\n"]
    end loop
  end process
end ttok
