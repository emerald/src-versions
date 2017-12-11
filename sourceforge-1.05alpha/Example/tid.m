const Ident <- class Ident [xname : String, xval : Integer]
  field name : String <- xname
  field val : Integer <- xval
end Ident

const t <- object t
  initially
    var x : Ident <- Ident.create["abc", 9]
    const y <- Ident.create["def", 10]
  end initially
end t
