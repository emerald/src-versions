const boring <- object boring
  process
    loop
      (locate self).Delay[Time.create[600000, 0]]
    end loop
  end process
end boring
