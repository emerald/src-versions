const tc <- object tc
  const t <- typeobject t
    operation foo
  end t
  var x : t
  const y <- object z
    export operation foo
    end foo
  end z
  initially
    x <- y    
  end initially
end tc
