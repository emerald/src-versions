% 
% @(#)Time.m	1.2  3/6/91
%
const Time <- immutable object Time builtin 0x100d
  const TimeType <- immutable typeobject TimeType builtin 0x160d
    function + [o : Time] -> [r : Time]
    function - [o : Time] -> [r : Time]
    function * [o : Integer] -> [r : Time]
    function / [o : Integer] -> [r : Time]
    function > [o : Time] -> [r : Boolean]
    function >= [o : Time] -> [r : Boolean]
    function < [o : Time] -> [r : Boolean]
    function <= [o : Time] -> [r : Boolean]
    function = [o : Time] -> [r : Boolean]
    function != [o : Time] -> [r : Boolean]
    function getSeconds -> [r : Integer]
    function getMicroSeconds -> [r : Integer]
    function asString -> [String]
    function asDate -> [String]
  end TimeType
  export function getSignature -> [result : Signature]
    result <- TimeType
  end getSignature
  export operation create [seconds : Integer, microseconds : Integer] -> [result : TimeType]
    result <- immutable object aTime builtin 0x140d
      var secs : Integer <- seconds
      var msecs: Integer <- microseconds
      initially
	if msecs < 0 then
	  secs <- secs + (msecs / 1000000) - 1
	  msecs <- 1000000 + (msecs # 1000000)
	end if
	if msecs >= 1000000 then
	  secs <- secs + (msecs / 1000000)
	  msecs <- msecs # 1000000
	end if
      end initially
      export function + [o : Time] -> [r : Time]
	r <- Time.create[secs+o$seconds, msecs+o$microSeconds]
      end +
      export function - [o : Time] -> [r : Time]
	r <- Time.create[secs-o$seconds, msecs-o$microSeconds]
      end -
      export function * [o : Integer] -> [r : Time]
	r <- Time.create[secs * o, msecs * o]
      end *
      export function / [o : Integer] -> [r : Time]
	r <- Time.create[secs / o, (secs # o * 1000000 + msecs)/ o]
      end /
      export function > [o : Time] -> [r : Boolean]
	r <- secs = o$seconds and msecs > o$microSeconds or secs > o$seconds
      end >
      export function >= [o : Time] -> [r : Boolean]
	r <- secs = o$seconds and msecs >= o$microSeconds or secs > o$seconds
      end >=
      export function < [o : Time] -> [r : Boolean]
	r <- secs = o$seconds and msecs < o$microSeconds or secs < o$seconds
      end <
      export function <= [o : Time] -> [r : Boolean]
	r <- secs = o$seconds and msecs <= o$microSeconds or secs < o$seconds
      end <=
      export function = [o : Time] -> [r : Boolean]
	r <- secs = o$seconds and msecs = o$microSeconds
      end =
      export function != [o : Time] -> [r : Boolean]
	r <- secs != o$seconds or msecs != o$microSeconds
      end !=
      export function getSeconds -> [r : Integer]
	r <- secs
      end getSeconds
      export function getMicroSeconds -> [r : Integer]
	r <- msecs
      end getMicroSeconds
      export function asString -> [r : String]
	const x : String <- msecs.asString
	const y <- "000000"
	const l : Integer <- x.length
	r <- secs.asString || ":"
	if l < 6 then
	  r <- r || y[0, 6-x.length]
        end if
	r <- r || x
      end asString
      export function asDate -> [r : String]
	primitive "DSTR" [r] <- [secs]
      end asDate
    end aTime
  end create
  export operation fromLocal [year : Integer, month : Integer, day : Integer, hour : Integer, minute : Integer, second : Integer] -> [r : Time]
    var seconds : Integer
    primitive "LSECS" [seconds] <- [year, month, day, hour, minute, second]
    r <- self.create[seconds, 0]
  end fromLocal
end Time

export Time to "Builtins"
