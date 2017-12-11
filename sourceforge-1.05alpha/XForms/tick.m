const other <- object other
  process
    loop
      stdout.putstring["Tick\n"]
      (locate self).delay[Time.create[1, 0]]
    end loop
  end process
end other
