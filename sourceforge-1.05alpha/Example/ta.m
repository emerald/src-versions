const foo <- object foo
  initially
    const t <- typeobject t
      operation foo[Integer] -> [Boolean]
      operation bar -> [Boolean]
      operation baz [Boolean]
      function x -> [String]
    end t
    var x : Integer <- 45
    var s : Any
    const atx <- (typeof self).getsignature
    stdout.putstring[nameof atx]
    stdout.putstring[atx.getFileName]
    stdout.putchar['\n']
    s <- typeof x
  end initially
end foo
