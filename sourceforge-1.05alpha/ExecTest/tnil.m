const tnil <- object tnil
  const myTest <- runtest.create[stdin, stdout, "tnil"]
  initially
    var res : Boolean <- false
    begin
      nil.foo
      failure
	res <- true
      end failure
    end
    myTest.check[res, "Invoking nil raised catchable failure"]
    var uninitialized : Integer
    myTest.check[uninitialized == nil, "uninitialized == nil"]
    myTest.done
  end initially
end tnil
