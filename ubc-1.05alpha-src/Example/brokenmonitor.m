const synchronizer <- object synchronizer
  var printHiNext : Boolean <- true
  const c : Condition <- Condition.create
  
  export operation Hi
    if ! printHiNext then wait c end if
    stdout.PutString["hi\n"]
    printHiNext <- false
    signal c
  end hi

  export operation Ho
    if printHiNext then wait c end if
    stdout.PutString["ho\n"]
    printHiNext <- true
    signal c
  end ho
end synchronizer
