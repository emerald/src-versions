const foo <- object foo
  initially
    
  end initially
end foo

const bar <- object bar
  initially
    stdout.putstring["It is a " || nameof foo || "\n"];
    stdout.putstring["I am a " || nameof self || "\n"];
  end initially
end bar
