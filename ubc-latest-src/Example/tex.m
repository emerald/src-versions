const foo <- object foo
  export operation foo1 
    self.foo3
  end foo1
  operation foo2 
    
  end foo2
  operation foo3
      self.foo2
  end foo3
end foo

const bar <- object bar
  initially
    foo.foo1
    foo.foo2
    foo.foo3
  end initially
end bar
