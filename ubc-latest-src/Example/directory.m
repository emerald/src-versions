export Map

const MapElement <- record MapElement
  var name : String
  var value : Any
end MapElement

const Map <- immutable object Map
  const data <- Array.of[MapElement].empty

  export operation insert[name : String, value : Any]
    for i : Integer <- data.lowerbound while i <= data.upperbound by i<-i+1
      const d <- data[i]
      if d$name = name then
	d$value <- value
	return
      end if
    end for
    data.addUpper[MapElement.create[name, value]]
  end insert
  
  export function lookup[name : String] -> [value : Any]
    for i : Integer <- data.lowerbound while i <= data.upperbound by i<-i+1
      const d <- data[i]
      if d$name = name then
	value <- d$value
	return
      end if
    end for
  end lookup
  
  export operation delete[name : String]
    var found : Boolean <- false
    for i : Integer <- data.lowerbound while i <= data.upperbound by i<-i+1
      const d <- data[i]
      if found then
	data[i - 1] <- data[i]
      elseif d$name = name then
	found <- true
      end if
    end for
    if found then 
      const junk <- data.removeUpper
    end if
  end delete
end Map
