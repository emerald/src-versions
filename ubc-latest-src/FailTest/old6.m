const tscope <- object tscope
  operation s [ s : String ]
    var s : String
  end s
end tscope

  
const tctops <- object tctops
  export harry
  operation harry 
    
  end harry
  function harry -> [ Integer ]
    
  end harry
end tctops

const tatops <- type tatops
  op sally
  op sally[Integer]
  op billy
  function billy -> [integer]
end tatops

const tmon <- object tmon
  var outer : Integer
  monitor
    var inner : Integer
    operation blotto 
      inner <- 5
      outer <- 6
    end blotto
    initially
      inner <- 5
      outer <- 6
    end initially
  end monitor
  operation hairy 
    inner <- 5
    outer <- 6
  end hairy
end tmon

const tfun <- object tfun
  function hairy
  end hairy
  function blotto [n : Integer]
  end blotto
  function sally -> [s : String, n : Integer]
  end sally
end tfun
