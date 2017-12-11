const child <- class child(base)
    export operation pmo1 -> [r : String]
      r <- "cmo1"
    end pmo1
    export operation cmo2 -> [r : String]
      r <- "cmo2"
    end cmo2
    export operation foo[o : OutStream]
      o.putString[pi1]
      o.putchar['\n']
      o.putString[pmi1]
      o.putchar['\n']
    end foo
  export operation po1 -> [r : String]
    r <- "co1"
  end po1
  export operation co2 -> [r : String]
    r <- "co2"
  end co2
end child

const test <- object test
  initially
    const x <- child.create
    stdout.putstring[x.pmo1]
    stdout.putchar['\n']
    stdout.putstring[x.pmo2]
    stdout.putchar['\n']
    stdout.putstring[x.cmo2]
    stdout.putchar['\n']
    stdout.putstring[x.po1]
    stdout.putchar['\n']
    stdout.putstring[x.po2]
    stdout.putchar['\n']
    stdout.putstring[x.co2]
    stdout.putchar['\n']
    x.foo[stdout]
  end initially
end test
