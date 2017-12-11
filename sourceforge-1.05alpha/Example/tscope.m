const tscope <- object tscope
  initially
    var x : Integer <- 34
    begin
      var x : Integer <- 99
      assert false
    end
  end initially
end tscope
