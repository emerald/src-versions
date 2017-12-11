const tbuf <- object tbuf
  initially
    const b <- Buffer.create[1]
    b.addChar["y".getelement[0]]

    b.write
  end initially
end tbuf
