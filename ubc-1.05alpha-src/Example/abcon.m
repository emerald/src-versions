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
      stdout.putstring["foo: "]
      stdout.putstring[a.asString]
      stdout.putint[b, 10]
      stdout.putchar[' ']
      stdout.putstring[nameof c]
      stdout.putchar['\n']
    end foo
    export operation bar [a : printable]
      stdout.putstring["bar: "]
      stdout.putstring[a.asString]
      stdout.putchar['\n']
    end bar
  end thing
  initially
    thing.foo["abc", 5, 7]
    thing.bar[5]
  end initially
end abcon
