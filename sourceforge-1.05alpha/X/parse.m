const RISS <- typeobject t
  function lowerbound -> [Integer]
  function upperbound -> [Integer]
  function getelement[Integer] -> [String]
end t

const parser <- immutable object Parser
  var d1, d2, d3, d4, d5, t1, t2 : Integer
  const d1s <- "^(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) ([0-9]+), ([0-9][0-9][0-9][0-9]) *"
  const d2s <- "^([1-9]|1[012])/([0-9][0-9]?)/([0-9][0-9]) *"
  const d3s <- "^(January|February|March|April|May|June|July|August|September|October|November|December) ([0-9]+), ([0-9][0-9][0-9][0-9]) *"
  const d4s <- "^(Sunday|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday) *"
  const d5s <- "^(Sun|Mon|Tue|Wed|Thu|Fri|Sat) *"
  const t1s <- "^<?([0-9][0-9]?):([0-9][0-9]) *([ap]m)?"

  const sdays <- { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" }
  const ldays <- { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }
  const smonths <- { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }
  const lmonths <- { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" }
  const cummdays <- { 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334 }

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

  operation regtrim [input : String, pattern : Integer] -> [rest : String]
    var match : String
    const zero <- "\\0"
    primitive "CCALL" "REGSUB" [match] <- [pattern, zero]
    const len <- match.length
    rest <- input[len, input.length - len]
  end regtrim

  operation matches [pattern : Integer, input : String] -> [r :Boolean]
    primitive "CCALL" "REGEXEC" [r] <- [pattern, input]    
  end matches

  operation report [year : Integer, mindex : Integer, dayofmonth : Integer]
    (locate self).getstdout.putstring[" Found " || year.asString || "." || (mindex + 1).asString || "." || dayofmonth.asString || "\n"]
  end report

  export operation fromString[input : String] -> [r : Time, rest : String]
    var mindex, dayofmonth, year : Integer
    var hour, minute : Integer
    var match : Boolean
    const one <- "\\1"
    const two <- "\\2"
    const three <- "\\3"

    if self.matches[d1, input] then
      var monthname, dayindexs, years : String
      primitive "CCALL" "REGSUB" [monthname] <- [d1, one]
      primitive "CCALL" "REGSUB" [dayindexs] <- [d1, two]
      primitive "CCALL" "REGSUB" [years] <- [d1, three]
      mindex <- self.assoc[monthname, smonths]
      dayofmonth <- Integer.Literal[dayindexs]
      year <- Integer.Literal[years]
      rest <- self.regtrim[input, d1]
      self.report[year, mindex, dayofmonth]
    elseif self.matches[d2, input] then
      var monthindexs, dayindexs, years : String
      primitive "CCALL" "REGSUB" [monthindexs] <- [d1, one]
      primitive "CCALL" "REGSUB" [dayindexs] <- [d1, two]
      primitive "CCALL" "REGSUB" [years] <- [d1, three]
      mindex <- Integer.Literal[monthindexs]
      dayofmonth <- Integer.Literal[dayindexs]
      year <- Integer.Literal[years] + 1900
      if year < 1970 then
	year <- year + 100
      end if
      rest <- self.regtrim[input, d1]
      self.report[year, mindex, dayofmonth]
    elseif self.matches[d3, input] then
      var monthname, dayindexs, years : String
      primitive "CCALL" "REGSUB" [monthname] <- [d3, one]
      primitive "CCALL" "REGSUB" [dayindexs] <- [d3, two]
      primitive "CCALL" "REGSUB" [years] <- [d3, three]
      mindex <- self.assoc[monthname, lmonths]
      dayofmonth <- Integer.Literal[dayindexs]
      year <- Integer.Literal[years]
      rest <- self.regtrim[input, d3]
      self.report[year, mindex, dayofmonth]
    elseif self.matches[d4, input] then
      var daynames: String
      primitive "CCALL" "REGSUB" [daynames] <- [d4, one]
      rest <- self.regtrim[input, d4]
      (locate self).getstdout.putstring["Found " || daynames ||"\n"]
      year <- 0 mindex <- 0 dayofmonth <- 0
    elseif self.matches[d5, input] then
      var daynames: String
      primitive "CCALL" "REGSUB" [daynames] <- [d5, one]
      rest <- self.regtrim[input, d5]
      (locate self).getstdout.putstring["Found " || daynames ||"\n"]
      year <- 0 mindex <- 0 dayofmonth <- 0
    else
      (locate self).getstdout.putstring["Can't parse: " || input || "\n"]
      return
    end if

    % look for repeating spec

    % look for time
    if self.matches[t1, rest] then
      var hours, minutes, designs : String
      primitive "CCALL" "REGSUB" [hours] <- [t1, one]
      primitive "CCALL" "REGSUB" [minutes] <- [t1, two]
      primitive "CCALL" "REGSUB" [designs] <- [t1, three]

      hour <- Integer.Literal[hours]
      minute <- Integer.Literal[minutes]
      if designs !== nil and designs = "pm" then
	hour <- hour + 12
      end if
      rest <- self.regtrim[rest, t1]
      (locate self).getstdout.putstring["   at " || hour.asString || ":" || minute.asString || "\n"]
    else
      hour <- 0 minute <- 0
    end if
    r <- Time.fromLocal[year, mindex, dayofmonth, hour, minute, 0]
  end fromString
  initially
    primitive "CCALL" "REGCOMP" [d1] <- [d1s]
    primitive "CCALL" "REGCOMP" [d2] <- [d2s]
    primitive "CCALL" "REGCOMP" [d3] <- [d3s]
    primitive "CCALL" "REGCOMP" [d4] <- [d4s]
    primitive "CCALL" "REGCOMP" [d5] <- [d5s]
    primitive "CCALL" "REGCOMP" [t1] <- [t1s]
  end initially
end Parser

export Parser
