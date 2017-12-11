const str <- record str
  var value : Integer
  var next  : str
end str

const driver <- object driver
  process
    var trailer, runner, head : str
    head <- str.create[5, nil]
    head <- str.create[2, head]
    head <- str.create[1, head]
    runner <- head
    loop
      exit when runner == nil
      stdout.putstring["value: "||runner$value.asString||"\n"]
      trailer, runner <- runner, runner$next
    end loop
    stdout.putstring["Done\n"]
  end process
end driver
