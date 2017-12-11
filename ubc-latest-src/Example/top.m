const o <- object o
    operation foo 
      
    end foo
    operation bar
      self.foo
    end bar
    operation baz
      self.bar
    end baz
  process
    self.foo
    self.bar
    self.baz
  end process
end o
