const toid <- object toid
  process
    var a, b, c : Integer
    primitive self var "GETOID"[a, b, c] <- []
    stdout.putstring[a.asHexString || "-" || b.asHexString || "-" || c.asHexString || "\n"]
    primitive var "GETOID" [a, b, c] <- [1]
    stdout.putstring[a.asHexString || "-" || b.asHexString || "-" || c.asHexString || "\n"]
  end process
end toid
