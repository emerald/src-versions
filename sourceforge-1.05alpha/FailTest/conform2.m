const test <- object test
  operation foobar [i : Integer, s : String]
  end foobar

  process
    self.foobar[45.0, "abc"]
    self.foobar[true, true]
  end process
end test
