% 
% %W% %G%
%
const TimeStamp <- immutable object TimeStamp % builtin 0x1055
  const TimeStampType <- immutable typeobject TimeStampType % builtin 0x1655
    function > [o : TimeStampType] -> [r : Boolean]
    function >= [o : TimeStampType] -> [r : Boolean]
    function < [o : TimeStampType] -> [r : Boolean]
    function <= [o : TimeStampType] -> [r : Boolean]
    function = [o : TimeStampType] -> [r : Boolean]
    function != [o : TimeStampType] -> [r : Boolean]
    function getSeconds -> [r : Integer]
    function getMicroSeconds -> [r : Integer]
    function getIpAddress -> [r : Integer]
    function getIncarnation -> [r : Integer]
    function asString -> [String]
  end TimeStampType
  export function getSignature -> [result : Signature]
    result <- TimeStampType
  end getSignature
  export operation create [seconds : Integer, microseconds : Integer, ipaddress : Integer, incarnation : Integer] -> [result : TimeStampType]
    result <- immutable object aTimeStamp % builtin 0x1455
      const secs : Integer <- seconds
      const msecs: Integer <- microseconds
      const ipaddr : Integer <- ipaddress
      const inc : Integer <- incarnation

      export function < [o : TimeStampType] -> [r : Boolean]
	r <- secs < o$seconds or
	  secs = o$seconds and msecs < o$microSeconds or
	  secs = o$seconds and msecs = o$microSeconds and ipaddr < o$ipAddress or 
	  secs = o$seconds and msecs = o$microSeconds and ipaddr = o$ipAddress and inc < o$incarnation
      end <

      export function <= [o : TimeStampType] -> [r : Boolean]
	r <- secs < o$seconds or
	  secs = o$seconds and msecs < o$microSeconds or
	  secs = o$seconds and msecs = o$microSeconds and ipaddr < o$ipAddress or 
	  secs = o$seconds and msecs = o$microSeconds and ipaddr = o$ipAddress and inc <= o$incarnation
      end <=
      export function > [o : TimeStampType] -> [r : Boolean]
	r <- secs > o$seconds or
	  secs = o$seconds and msecs > o$microSeconds or
	  secs = o$seconds and msecs = o$microSeconds and ipaddr > o$ipAddress or 
	  secs = o$seconds and msecs = o$microSeconds and ipaddr = o$ipAddress and inc > o$incarnation
      end >
      export function >= [o : TimeStampType] -> [r : Boolean]
	r <- secs > o$seconds or
	  secs = o$seconds and msecs > o$microSeconds or
	  secs = o$seconds and msecs = o$microSeconds and ipaddr > o$ipAddress or 
	  secs = o$seconds and msecs = o$microSeconds and ipaddr = o$ipAddress and inc >= o$incarnation
      end >=
      export function = [o : TimeStampType] -> [r : Boolean]
	r <- secs = o$seconds and msecs = o$microSeconds and ipaddr = o$ipAddress and inc = o$incarnation
      end =
      export function != [o : TimeStampType] -> [r : Boolean]
	r <- secs = o$seconds and msecs = o$microSeconds and ipaddr = o$ipAddress and inc = o$incarnation
      end !=
      export function getSeconds -> [r : Integer]
	r <- secs
      end getSeconds
      export function getMicroSeconds -> [r : Integer]
	r <- msecs
      end getMicroSeconds
      export function getIPAddress -> [r : Integer]
	r <- ipaddr
      end getIPAddress
      export function getIncarnation -> [r : Integer]
	r <- inc
      end getIncarnation
      export function asString -> [r : String]
	const x : String <- msecs.asString
	const y <- "000000"
	const l : Integer <- x.length
	r <- secs.asString || ":"
	if l < 6 then
	  r <- r || y[0, 6-x.length]
        end if
	r <- r || x
%	r <- r || "@" || ipaddr.asHexString || "." || inc.asHexString
      end asString
    end aTimeStamp
  end create
end TimeStamp

export TimeStamp % to "Builtins"
