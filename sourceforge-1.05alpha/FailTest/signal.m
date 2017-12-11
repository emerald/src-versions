const failsignal <- object failsignal
  process
    var c : Condition
    wait c
    signal c
  end process
end failsignal
