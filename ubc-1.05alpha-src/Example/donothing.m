const DoNothing <- object DoNothing
  export operation foo [] -> []
    stdout.putstring["Hello, world\n"]
  end foo

  process
    self.foo []
  end process
end DoNothing
