const assign <- object assign
  operation test [a : Any]
    a <- 45
    assign <- 56
    45 <- 99
    "abc" <- "def"
  end test
  initially
    var a, b, c : Any

    a, b <- c
    a <- b, c
    45, a <- 99, 99
    a, 45 <- 99, 99
    a
    45
  end initially
end assign
