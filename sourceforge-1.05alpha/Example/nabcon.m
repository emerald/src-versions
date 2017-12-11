const abcon <- object abcon
  const printable <- typeobject printable
    function asString -> [String]
  end printable

  const thingtype <- typeobject thingtype
    operation foo[printable, integer, any]
    operation bar[printable]
  end thingtype

  const thing <- object thing
    export operation foo [a : printable, b : integer, c : any]
      var  x  : String <- a.asString
      x <- nameof c
    end foo
    export operation bar [a : printable]
      const x <- a.asString
    end bar
  end thing
  initially
    thing.foo["abc", 5, 7]
    thing.bar[5]
  end initially
end abcon
