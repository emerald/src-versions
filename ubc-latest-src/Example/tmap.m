const tmap <- object tmap
  initially
    const mymap <- Map.of[Integer, String].create
    mymap.insert[45, "45"]
    mymap.insert[99, "99"]
    stdout.putstring[mymap.lookup[45]]
    stdout.putchar['\n']
  end initially
end tmap
