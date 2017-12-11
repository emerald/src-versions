const colour <- enumeration colour
  red, orange, yellow, green, blue, indigo, violet
end colour

const tcolour <- object tcolour
  initially
    const r <- colour.first
    const l <- colour.last
    var i : Colour <- colour.first
    var x : Integer
    loop
      x <- i.ord
      exit when i = colour.last
      i <- i.succ
    end loop
    i <- colour.red
    i <- colour.orange
    i <- colour.yellow
    i <- colour.green
    i <- colour.blue
    i <- colour.indigo
    i <- colour.violet
  end initially
end tcolour
