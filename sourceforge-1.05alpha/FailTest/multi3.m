const target <- object target
  export operation lots -> [x : Integer, y : String, z : Character]
    
  end lots
end target

const victim <- object victim
  initially
    var e : Integer <- target.lots
    const d <- target.lots
  end initially
end victim
