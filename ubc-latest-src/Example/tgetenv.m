const foo <- object foo
  initially
    var x : String <- "This is a string\n"
    var a : Any
    stdout.putString[x]
    primitive var "SETENV" [] <- [x]
    x <- "This is another string\n"
    stdout.putString[x]
    primitive var "GETENV" [a] <- []
    x <- view a as String
    stdout.putString[x]
  end initially
end foo
