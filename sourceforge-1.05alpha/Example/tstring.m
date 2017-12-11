const tstring <- object tstring
  initially
    const x <- "this
is 
a 
long
string"
    stdout.putstring[x]
    stdout.putchar['\n']
  end initially
end tstring
