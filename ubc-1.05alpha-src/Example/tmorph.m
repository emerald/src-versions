const old <- object old
  export operation foo -> [r : String]
    r <- "old"
  end foo
end old
const xnew <- object xnew
  export operation foo -> [r : String]
    r <- "xnew"
  end foo
end xnew
const test <- object test
  initially
    stdout.putstring[old.foo]
    stdout.putchar['\n']
    primitive "MORPH" [] <- [old, xnew]
    stdout.putstring[old.foo]
    stdout.putchar['\n']
  end initially
end test
