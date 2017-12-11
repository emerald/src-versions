const reader <- object reader
  process
    loop
      const s <- stdin.getString
      exit when s = "\n"
      stdout.putstring["Got: "||s]
    end loop
  end process
end reader

const doer <- object doer
  process
    loop
      (locate self).delay[Time.create[1, 0]]
      stdout.putstring["Tick\n"]
    end loop
  end process
end doer
