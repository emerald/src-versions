const treal <- object treal
  initially
    const y : Real <- Real.create
    const x : Real <- Real.literal["3.14159"]
    
    stdout.putstring[x.asString]
    stdout.putchar['\n']

    stdout.putstring[y.asString]
    stdout.putchar['\n']
    stdout.putstring[(3.15 + 6.57).asString]
    stdout.putchar['\n']
    stdout.putstring[(~3.15).asString]
    stdout.putchar['\n']
    stdout.putstring[(-3.15).asString]
    stdout.putchar['\n']
    
  end initially
end treal
