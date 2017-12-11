const parent1 <- class parent1[n : Integer]
  class export operation foobar -> [r : String]
    r <- "foobar"
  end foobar
  initially
    stdout.putstring["Parent1 init\n"]
  end initially
  process
    stdout.putstring["Parent1 process\n"]
  end process
end parent1

const parent2 <- class parent2[n : Integer]
  class export operation foobar -> [r : String]
    r <- "foobar"
  end foobar
  initially
    stdout.putstring["Parent2 init\n"]
  end initially
  process
    stdout.putstring["Parent2 process\n"]
  end process
end parent2

const parent3 <- class parent3[n : Integer]
  class export operation foobar -> [r : String]
    r <- "foobar"
  end foobar
  initially
    stdout.putstring["Parent3 init\n"]
  end initially
  process
    stdout.putstring["Parent3 process\n"]
  end process
end parent3

const child1 <- class child1 (parent1) [z : Real]
  class export operation foobar -> [r : String]
    r <- "foobar"
  end foobar
  initially
    stdout.putstring["Child1 init\n"]
  end initially
  process
    stdout.putstring["Child1 process\n"]
  end process
end child1

const child2 <- class child2 (parent2) [z : Real]
  class export operation foobar -> [r : String]
    r <- "foobar"
  end foobar
  process
    stdout.putstring["Child2 process\n"]
  end process
end child2

const child3 <- class child3 (parent3) [z : Real]
  class export operation foobar -> [r : String]
    r <- "foobar"
  end foobar
  initially
    stdout.putstring["Child3 init\n"]
  end initially
end child3

const driver <- object driver
  initially
    assert child1 *> parent1
    assert child2 *> parent2
    assert child3 *> parent3
    assert typeof child1 *> typeobject zz op foobar -> [String] end zz
    assert typeof child2 *> typeobject zz op foobar -> [String] end zz
    assert typeof child3 *> typeobject zz op foobar -> [String] end zz
    const junk1 <- child1.create[2, 2.2]
    const junk2 <- child2.create[2, 2.2]
    const junk3 <- child3.create[2, 2.2]
  end initially
end driver
