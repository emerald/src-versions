const tfail <- object tfail
  var i : Integer <- 34
  var xxx : None
  operation fail
%    nil.f1[]
    begin
      nil.f2[]
      xxx.f2[]
      failure
	stdout.putstring["It failed.\n"]
      end failure
    end
    nil.f3[]
    failure
      stdout.putstring["It can't fail here.\n"]
      assert false
    end failure
  end fail
  initially
    var x : Integer <- 46
    stdout.putstring["X is "||x.asString||".\n"]
    self.fail
    failure
      stdout.putstring["First level handler.\n"]
      stdout.putstring["X is "||x.asString||".\n"]
    end failure
  end initially
end tfail
