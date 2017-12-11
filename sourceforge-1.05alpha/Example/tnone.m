const ttype <- object ttype
  initially
    var x, y : Type
    assert None *> Any
    assert None *> Integer
    assert None *> None
    assert None *> typeobject t end t
    assert None *> immutable typeobject t end t
    assert None *> immutable typeobject t op x end t
    x, y <- None, Integer
    assert x *> y
    x, y <- None, Any
    assert x *> y
    x, y <- None, None
    assert x *> y
    x, y <- None, typeobject t end t
    assert x *> y
    x, y <- None, immutable typeobject t end t
    assert x *> y
    x, y <- None, immutable typeobject t op x end t
    assert x *> y
  end initially
end ttype
