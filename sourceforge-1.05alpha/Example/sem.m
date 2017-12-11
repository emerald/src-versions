export Semaphore 

const Semaphore <- monitor class Semaphore [initial : Integer]
  class export operation create -> [r : Semaphore]
    r <- Semaphore.create[1]
  end create
  var count : Integer <- initial
  var waiters : Condition <- Condition.create
  export operation P 
    count <- count - 1
    if count < 0 then
      wait waiters
    end if
  end P
  export operation V 
    count <- count + 1
    if count <= 0 then
      signal waiters
    end if
  end V
end Semaphore
