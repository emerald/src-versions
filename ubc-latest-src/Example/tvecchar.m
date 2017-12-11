const tvecchar <- object tvecchar
  initially
    const foo <- { 'a', 'b', 'c', 'd', 'e' }
    stdout.putint[foo[0].ord, 0]
    stdout.putchar['\n']
  end initially
end tvecchar
