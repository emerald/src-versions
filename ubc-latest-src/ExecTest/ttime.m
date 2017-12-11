const ttime <- object ttime
  const myTest <- runtest.create[stdin, stdout, "ttime"]
  initially
    % each test looks like myTest.check[<boolean expression>, "<same exp>"]
    var t1, t2 : Time
    t1 <- Time.create[0,0]
    myTest.check[t1 == t1, "t1 == t1"]
    myTest.check[t1 = t1, "t1 = t1"]
    myTest.check[t1 = Time.create[0,0], "t1 = Time.create[0,0]"]
    myTest.check[t1 !== t2, "t1 !== t2"]
    t1 <- Time.create[5, 999999]
    t2 <- Time.create[0, 000001]
    myTest.check[t1 + t2 = Time.create[6,0], "t1 + t2 = Time.create[6,0]"]
    t2 <- Time.create[0, 000002]
    myTest.check[t1 + t2 = Time.create[6,1], "t1 + t2 = Time.create[6,1]"]
    t1 <- Time.create[~1, 1000000]
    myTest.check[t1 = Time.create[0,0], "t1 = Time.create[0,0]"]
    myTest.check[Time.create[0,~10000000] = Time.create[~10,0], "Time.create[0,~10000000] = Time.create[~10,0]"]
    myTest.check[Time.create[1,~1] = Time.create[0,999999], "Time.create[1,~1] = Time.create[0,999999]"]
    myTest.check[Time.create[~1,2000000] = Time.create[1,0], "Time.create[~1,2000000] = Time.create[1,0]"]
    myTest.check[Time.create[1, 0] <= Time.create[2, 0], "Time.create[1, 0] <= Time.create[2, 0]"]
    myTest.check[Time.create[1,0] >= Time.create[0,0], "Time.create[1,0] >= Time.create[0,0]"]
    myTest.check[!(Time.create[3, 0] <= Time.create[2, 0]), "!(Time.create[3, 0] <= Time.create[2, 0])"]
    myTest.check[!(Time.create[1, 0] >= Time.create[2, 0]), "!(Time.create[1, 0] >= Time.create[2, 0])"]
    myTest.check[Time.create[1,2] <= Time.create[1,2], "Time.create[1,2] <= Time.create[1,2]"]
    myTest.check[Time.create[1,1] <= Time.create[1,2], "Time.create[1,1] <= Time.create[1,2]"]
    myTest.check[Time.create[1,2] >= Time.create[1,2], "Time.create[1,2] >= Time.create[1,2]"]
    myTest.check[Time.create[1,2] >= Time.create[1,1], "Time.create[1,2] >= Time.create[1,1]"]

    myTest.check[!(Time.create[1,3] <= Time.create[1,2]), "!(Time.create[1,3] <= Time.create[1,2])"]
    myTest.check[!(Time.create[2,2] <= Time.create[1,2]), "!(Time.create[2,2] <= Time.create[1,2])"]
    myTest.check[!(Time.create[1,2] >= Time.create[1,3]), "!(Time.create[1,2] >= Time.create[1,3])"]
    myTest.check[!(Time.create[1,2] >= Time.create[2,2]), "!(Time.create[1,2] >= Time.create[2,2])"]

    myTest.done
  end initially
end ttime
