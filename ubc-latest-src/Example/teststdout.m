const Test <- object Test
  process
    const home <- locate self
    home$stdout.PutString["hi\n"]
  end process
end Test
