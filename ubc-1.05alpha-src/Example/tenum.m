const colour <- enumeration colour
  red, orange, yellow, green, blue, indigo, violet
end colour

const tcolour <- object tcolour
  initially
    const r <- colour.first
    const l <- colour.last
    var i : Colour <- colour.first
    loop
      stdout.putint[i.ord, 0]
      stdout.putchar[' ']
      stdout.putstring[i.asString]
      stdout.putchar['\n']
      exit when i = colour.last
      i <- i.succ
    end loop
    stdout.putstring[colour.red.asString] stdout.putchar['\n']
    stdout.putstring[colour.orange.asString] stdout.putchar['\n']
    stdout.putstring[colour.yellow.asString] stdout.putchar['\n']
    stdout.putstring[colour.green.asString] stdout.putchar['\n']
    stdout.putstring[colour.blue.asString] stdout.putchar['\n']
    stdout.putstring[colour.indigo.asString] stdout.putchar['\n']
    stdout.putstring[colour.violet.asString] stdout.putchar['\n']
  end initially
end tcolour
