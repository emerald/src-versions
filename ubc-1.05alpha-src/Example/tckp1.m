const ByteCodeReader <- object ByteCodeReader
  const initialized <- object init
      field initialized : Boolean <- false
  end init

  export operation read
    if initialized$initialized then return end if
    initialized$initialized <- true
    (locate self).getStdout.putstring["Initialized"]
  end read
end ByteCodeReader

export ByteCodeReader
