const key <- immutable class key[pyear : Integer, pmonth : Integer, pday : Integer]
  field year : Integer <- pyear
  field month : Integer <- pmonth
  field day : Integer <- pday
  export function hash -> [r : Integer]
    r <- year * 7 + month * 13 + day
  end hash
  export function = [other : key] -> [r : Boolean]
    r <- other$year = year and other$month = month and other$day = day
  end =
end key

const value <- class day
  field stuff : any
end day

const tassoc <- object tassoc
  initially
    const myassoctype <- assoc.of[key, value]
    const a <- myassoctype.create
    a.insert[key.create[1996, 2, 2], value.create]
    assert a.lookup[key.create[1996, 2, 2]] !== nil
    assert a.lookup[key.create[1996, 2, 3]] == nil
  end initially
end tassoc
