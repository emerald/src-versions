const TestObject <- class TestObject[]
  var count : Integer
  export operation OneArg[data : ImmutableVector.of[Character]]
  end OneArg

  export operation NoArg[]
    count <- 1
  end NoArg

  export operation CurrentLocation[] -> [result : String]
    result <- (locate self)$name.asString
  end CurrentLocation
  export operation die 
    const junk <- object junk
      process
	(locate self).delay[time.create[1,0]]	
	primitive "NCCALL" "MISK" "UEXIT" [] <- [0]
      end process
    end junk
  end die
end TestObject


const TimerType <- typeobject TimerType
  op StartTransfer
  op EndTransfer
end TimerType

const ThroughputObject 
    <- class ThroughputObject[target: TestObject, data : ImmutableVector.of[Character], Timer : TimerType]
  const home         <- locate self
  var all    : NodeList<- home.getActiveNodes
  var there  : Node    <- all[1]$theNode

  process
    home$stdout.PutString[":    ThroughputObject created\n"]
    home$stdout.PutString[":    Home is " || home$name.asString || "\n"]
    home$stdout.PutString[":    Target leaving " || target.CurrentLocation || "\n"]
    move target to there
    there$stdout.PutString[":       arrived on " || target.CurrentLocation || "\n"]
    Timer.StartTransfer[]
    target.OneArg[data]
    Timer.EndTransfer[]
    home$stdout.PutString[":  ThroughputObject done\n"]
    const killer <- TestObject.create
    move killer to there
    killer.die
    primitive "NCCALL" "MISK" "UEXIT" [] <- [0]
  end process
end ThroughputObject

const Timer <- object Timer
  const home <- locate self
  const TRIAL_COUNT      <- 3
  const BUF_SIZE         <- 50000
  const buffer  <- ImmutableVector.of[Character].create[BUF_SIZE]
  var startTime, diff : Time
  var count   : Integer <- 0
  field s   : Boolean <- FALSE
  var all     : NodeList<- home.getActiveNodes
  var there   : Node <- all[1]$theNode

  export operation SetCount[num : Integer]
    count <- num
  end SetCount

  export operation StartTransfer[]
    if (s == FALSE) then
      s <- TRUE
      startTime <- home.getTimeOfDay      
    end if
  end StartTransfer
  
  export operation EndTransfer[]
    count <- count - 1
    if (count == 0) then
      diff <- home.getTimeOfDay - startTime
      home$stdout.PutString["Total time = " || diff.asString || "\n"]      
      home$stdout.PutString["Timer done\n"]
    end if
  end EndTransfer

  process
    home$stdout.PutString[":  Home is " || home$name.asString || "\n"]
    self.SetCount[2]
    const Remote1 <- TestObject.create
    const Remote2 <- TestObject.create
    const Mike1 <- ThroughputObject.create[Remote1, buffer, Timer]
    const Mike2 <- ThroughputObject.create[Remote2, buffer, Timer]
  end process
end Timer
