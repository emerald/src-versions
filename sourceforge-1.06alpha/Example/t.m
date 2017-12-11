const foo <- immutable object foo
  export function xx -> [r : Integer] r <- 45 end xx
end foo

const bar <- object bar
  initially
    var x : Integer <- foo.xx
    
  end initially
end bar
