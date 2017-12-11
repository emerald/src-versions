const tclr <- object tclr
  initially
    stdout.putchar[Character.Literal[033]]
    stdout.putchar['[']
    stdout.putchar['H']
    stdout.putchar[Character.Literal[033]]
    stdout.putchar['[']
    stdout.putchar['J']
    stdout.flush
  end initially
end tclr
