const tdict <- object tdict
  initially
    var a : String
    external foo : String
    a <- view foo as String
    stdout.putstring[a]
    stdout.putchar['\n']
    foo <- "This is a string"
  end initially
end tdict
