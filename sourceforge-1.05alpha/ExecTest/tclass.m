const tclass <- class tclass [xxfoo : Integer]
  field foo : Integer <- xxfoo
end tclass

const driv <- object driv
  const myTest <- runtest.create[stdin, stdout, "tclass"]
  initially
    const x <- tclass.create[56]
    mytest.check[x$foo = 56, "x$foo = 56"]
    mytest.done
  end initially
end driv
