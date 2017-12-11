const tarraytype <- object tarraytype
  initially
    var x : Array.of[None]
%    var xs : Array.of[String] <- Array.of[String].empty
%    x <- xs
    x <- Array.of[String].empty
    stdout.putstring[(Array.of[String] *> Array.of[None]).asstring]
    stdout.putchar['\n']
  end initially
end tarraytype
