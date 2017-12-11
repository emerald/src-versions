const target <- object target
  const value : Integer <- 34 + 65
  export operation foo ->[v : String]
    v <- value.asString
  end foo
end target

export target
