const tdict <- object tdict
  initially
    var a : String
    a <- foo
    stdout.putstring[a]
    stdout.putchar['\n']
    foo <- "This is a string"
  end initially
end tdict
