const RISS <- typeobject t
  function lowerbound -> [Integer]
  function upperbound -> [Integer]
  function getelement[Integer] -> [String]
end t

const Date <- immutable object Date
  const DateType <- immutable typeobject DateType
    function MonthName -> [m : String]
    function DayName -> [d : String]
    function Year -> [y : Integer]
    function weekday -> [d : Integer]
    function month -> [d : Integer]
    function day -> [d : Integer]
    function hour -> [d : Integer]
    function minute -> [d : Integer]
  end DateType

  const sdays <- { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" }
  const ldays <- { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }
  const smonths <- { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }
  const lmonths <- { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" }
  const monthlengths <- { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }

  export function getSignature -> [r : Signature]
    r <- DateType
  end getSignature

  export function assoc [t : String, vt : RISS] -> [index : Integer]
    const limit <- vt.upperbound
    var i : Integer <- 0
    loop
      exit when i > limit
      const x <- vt[i]
      if t = x then
	index <- i
	exit
      end if
      i <- i + 1
    end loop
  end assoc

  export function daysBetween [t1 : Time, t2 : Time] -> [days : Integer]
    const secsperday <- 24 * 60 * 60
    const tzadj <- -28800
    const s1 <- (t1$seconds + tzadj) / secsperday
    const s2 <- (t2$seconds + tzadj) / secsperday
    days <- s2 - s1
  end daysBetween

  export operation create[t : Time] -> [r : DateType]
    r <- immutable object aDate
      var mindex, dindex, dayofmonth, year, hour, minute : Integer
      const dateString <- t.asDate

      export function MonthName -> [m : String]
	m <- lmonths[mindex]
      end MonthName
      export function DayName -> [d : String]
	d <- ldays[dindex]
      end DayName
      export function Year -> [y : Integer]
	y <- year
      end Year
      export function weekday -> [d : Integer]
	d <- dindex
      end weekday
      export function month -> [d : Integer]
	d <- mindex
      end month
      export function day -> [d : Integer]
	d <- dayofmonth
      end day
      export function hour -> [d : Integer]
	d <- hour
      end hour
      export function minute -> [d : Integer]
	d <- minute
      end minute
      initially
	mindex <- Date.assoc[dateString[4, 3], smonths]
	dindex <- Date.assoc[dateString[0, 3], sdays]
	dayofmonth <- Integer.Literal[dateString[8, 2]]
	year <- Integer.Literal[dateString[20, 4]]
	if datestring[11] = '0' then
	  hour <- Integer.Literal[datestring[12, 1]]
	else
	  hour <- Integer.Literal[datestring[11, 2]]
	end if
	if datestring[14] = '0' then
	  minute <- Integer.Literal[datestring[15, 1]]
	else
	  minute <- Integer.Literal[datestring[14, 2]]
	end if
      end initially
    end aDate
  end create
end Date
export Date
    
