const tset <- object tset
  initially
    const sc <- Set.of[Integer]
    assert sc.singleton[34] = sc.singleton[34]
    assert !(sc.singleton[34] = sc.singleton[35])
    var s : sc
    s <- sc.create[ { 1, 2, 3, 4 } ]
    assert s.union[s] = s
    assert s.intersect[s] = s
  end initially
end tset
