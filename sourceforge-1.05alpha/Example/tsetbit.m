const tsetbit <- object tsetbit
  process
    stdout.putint[(0).setbit[29, true], 0]
    stdout.putchar['\n']
  end process
end tsetbit
