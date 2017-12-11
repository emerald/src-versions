const foo <- object foo
  initially
    var x : Decoder
    var y : Sequence
    var z : Sequence.of[Boolean] <- Vector.of[Boolean].create[3]
    tat.create.printType[stdout, Sequence.of[Boolean]]
  end initially
end foo
