const tt <- typeobject banana
  operation getv -> [vc]
end banana

const yyy <- object yyy
  initially
    var t : tt
    if t.getv.foobar = "abc" then
      stdout.putstring["This is a pain\n"]
    end if
  end initially
end yyy
