export shared

const shared <- monitor object shared
  const c : Condition <- Condition.create
  export operation waitforit 
    wait c
  end waitforit
  export operation goforit 
    signal c
  end goforit
end shared
