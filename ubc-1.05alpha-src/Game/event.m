% Define an Event queue creation object

export Command
export Event
export EventQueue

const Command <- enumeration Command
  worldTick,
  roomTick,
  moveToRoom,
  newRoomServer,
  addPlayerToRoom, 
  removePlayerFromRoom,
  playerUpdateRoom,
  addPlayerToGame,
  addMeToGame,
  removePlayerFromGame
end Command

const Event <- immutable record Event
  attached c : Command
  fromPlayer : Any
  attached tick : Integer
  otherPlayer : Any
  attached roomID : Integer
  attached dataXInt : Integer
  attached dataYInt : Integer
  attached dataXReal : Real
  attached dataYReal : Real
  attached dataString : String
end Event

const EventQueue <- monitor class EventQueue
  const c <- Condition.create
  const field store : Array.of[Event] <- Array.of[Event].empty

  export operation enqueue[n: Event]
    store.addUpper[n]
    signal c
  end enqueue

  export operation dequeue -> [n: Event]
    n <- store.removeLower
  end dequeue

  export function isEmpty -> [result : Boolean]
    result <- store.empty
  end isEmpty

  export operation waitForEvent
    if store.empty then wait c end if
  end waitForEvent
end EventQueue


%const test <- object test 
%  process
%    const home <- (locate self)
%    const there <- (locate self)$activeNodes[1]$theNode
%
%    move self to there
%
%    const remote <- object remote
%      const field eq : EventQueue <- EventQueue.create
%
%
%      process
%	 var lastEvent : Event <- Event.create[-1]
%	 (locate self)$stdout.putString[eq.isEmpty.asString || "\n"]
%	 eq.enqueue[Event.create[100]]
%	 (locate self)$stdout.putString[eq.isEmpty.asString || "\n"]
%	 const x <- eq.dequeue
%	 (locate self)$stdout.putString[eq.isEmpty.asString || "\n"]
%	 loop
%	   (locate self).delay[Time.create[0,500000]]
%	   if !eq.isEmpty then
%	     lastEvent <- eq.dequeue
%	   end if
%	   (locate self)$stdout.putString["Dequeued " || lastEvent$type.asString || "\n"]
%	 end loop    
%      end process
%    end remote
%
%    move self to home
%
%    var i:Integer <- 0
%    loop
%      (locate self)$stdout.putString["Creating " || i.asString || "\n"]
%      remote$eq.enqueue[Event.create[i]]
%      (locate self).delay[Time.create[1,0]]
%      i <- i+1
%    end loop
%
%  end process
%end test

%const testclass <- class testclass
%  operation foo
%  end foo
%
%  process
%    atestclass.foo
%  end process
%end testclass