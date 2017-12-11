const tcy <- object tcy
   initially
     for i : Integer <- 0 while i < 10 by i <- i + 1
       self.foo[0]
     end for
     self.bar[0]
   end initially
   operation foo [x : Integer]
     if x == 0 then
       self.foo[1]
       self.bar[1]
     end if
   end foo
   operation bar [x : Integer]
     if x == 0 then
       self.foo[1]
     end if
   end bar
end tcy
