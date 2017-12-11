const BarType <- immutable typeobject BarType
  operation bar [] -> []
end BarType

const MyObject <- object MyObject
  export operation foo [b : BarType] -> []
    b.bar []
  end foo
end MyObject

const Another <- object Another
  export operation bar [] -> []
  end bar

  process
    MyObject.foo[self]
  end process
end Another
