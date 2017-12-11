const foo <- immutable object foo
  initially
    (locate self)$stdout.putstring["foo\n"]
    bar.stuff
  end initially
end foo

const bar <- immutable object bar
  export operation stuff 
    (locate self)$stdout.putstring["bar.stuff\n"]
  end stuff
  initially
    (locate self)$stdout.putstring["bar\n"]
  end initially
end bar

