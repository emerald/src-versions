const iv <- object iv
  operation printv [v : ImmutableVector.of[Any]]
    for i : Integer <- 0 while i <= v.upperbound by i <- i + 1
      const e <- view v[i] as typeobject t function asString -> [String] end t
      if i = 0 then
	stdout.putstring["{ "]
      else
	stdout.putstring[", "]
      end if
      stdout.putstring[e.asString]
    end for
    stdout.putstring[" }\n"]
  end printv

  initially
    self.printv[{ 45, 99, 37 : Any }]
    self.printv[{ 45, 99, 37 : Integer}]
  end initially
end iv
