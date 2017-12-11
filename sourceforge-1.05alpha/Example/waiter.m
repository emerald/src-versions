const waiter <- object waiter
  process
    shared.waitforit
  end process
end waiter

const loader <- object loader
  process
    const signaler <- "signaler.x"
    primitive "DLOAD" [] <- [signaler]
  end process
end loader
