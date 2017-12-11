const tbad <- object tbad
  export operation opone [x : Integer]
    
  end opone
  operation optwo 
    
  end optwo
  export operation opthree [y : Boolean]
    
  end opthree
end tbad

const tgood <- object tgood
  operation opone [x : Integer]
    
  end opone
  operation optwo 
    
  end optwo
end tgood

const driver <- object driver
  initially
    tbad.opone
    tgood.opone[1]
  end initially
end driver
