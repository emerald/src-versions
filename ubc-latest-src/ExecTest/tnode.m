const tnode <- object tnode
  const myTest <- runtest.create[stdin, stdout, "tnode"]
  initially
    const mynode : Node <- locate self
    var now, other : Time
    var lnn : Integer
    now <- mynode.getTimeOfDay
    other <- Time.create[0,0]
    myTest.check[now >= other, "now >= other"]
    % This test will start failing again in about 2010
    myTest.check[now <= Time.create[60*60*24*366*40, 0], "now <= Time.create[60*60*24*366*40, 0]"]
    myTest.done
  end initially
end tnode
