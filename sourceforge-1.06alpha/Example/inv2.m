export invoker

const invoker <- object invoker
  initially
    const c <- target.foo
    (locate 1).getStdout.PutString[c || "\n"]
  end initially
end invoker
