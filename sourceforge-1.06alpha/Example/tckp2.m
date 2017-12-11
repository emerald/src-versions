const driver <- immutable object driver
  initially
    ByteCodeReader.read
  end initially
end driver

const driverx <- object driverx
  initially
    var a : Any <- self
    const name <- "junk"
    primitive var "CHECKPOINT" [] <- [a, name]
  end initially
  recovery
    ByteCodeReader.read
  end recovery
  process
    
  end process
end driverx
