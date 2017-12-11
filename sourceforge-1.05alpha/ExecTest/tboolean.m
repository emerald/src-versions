const tboolean <- object tboolean
  const myTest <- runtest.create[stdin, stdout, "tboolean"]
  initially
    % each test looks like myTest.check[<boolean expression>, "<same exp>"]
    var i, j : Boolean
    i <- false
    myTest.check[i = false, "i = false"]
    myTest.check[i == false, "i == false"]
    myTest.check[false == false, "false == false"]
    i <- true
    myTest.check[i = true, "i = true"]
    myTest.check[i == true, "i == true"]
    myTest.check[true == true, "true == true"]
    i <- false
    j <- true
    myTest.check[i < j, "i < j"]
    myTest.check[i <= j, "i <= j"]
    myTest.check[j > i, "j > i"]
    myTest.check[j >= i, "j >= i"]
    j <- false
    myTest.check[i <= j, "i <= j"]
    myTest.check[i >= j, "i >= j"]
    i <- true
    j <- true
    myTest.check[i <= j, "i <= j"]
    myTest.check[i >= j, "i >= j"]

    i <- false
    j <- true    
    myTest.check[i | j, "i | j"]
    myTest.check[i or j, "i or j"]
    myTest.check[!i & j, "!i & j"]
    myTest.check[!i and j, "!i and j"]
    myTest.check[!i, "!i"]
    myTest.check[!false, "!false"]
    myTest.check[i.asString = "false", "i.asString = \"false\""]
    myTest.check[j.asString = "true", "j.asString = \"true\""]
    myTest.check[false.asString = "false", "false.asString = \"false\""]
    myTest.check[true.asString = "true", "true.asString = \"true\""]
    
    myTest.done
  end initially
end tboolean
