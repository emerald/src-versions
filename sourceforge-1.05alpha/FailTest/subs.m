const tem <- object tem
  operation foo -> [r : ImmutableVectorOfInt]
    r <- { 1, 2, 3 }
  end foo
  initially
    stdout.putint[self.foo[1], 0]
    stdout.putchar['\n']
  end initially
end tem
