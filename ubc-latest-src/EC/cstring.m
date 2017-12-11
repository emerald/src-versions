const OIDWriter <- immutable object OIDWriter
  export operation Out [Seq : Integer, File : OutStream]
    file.writeInt[0, 4]   % IPAddress
    file.writeInt[0, 1]   % Emerald Instance
    file.writeInt[0, 1]   % Unused
    file.writeInt[0, 2]   % Epoch
    file.writeInt[Seq, 4] % Sequence
  end Out
  export operation OutX [seq : Integer, unused : Integer, file : OutStream]
    file.writeInt[0, 4]   % IPAddress
    file.writeInt[0, 1]   % Emerald Instance
    file.writeInt[unused, 1]   % Unused
    file.writeInt[0, 2]   % Epoch
    file.writeInt[Seq, 4] % Sequence
  end OutX
end OIDWriter

export OIDWriter

const CStringCT <- immutable object CStringCT
  const obj <- "-OB-"
  const stringCTOID <- 0x180b
  const myind <- object x
      field myind : Integer <- ~1
      field myq : CPQueue
  end x
  export operation fetchIndex -> [r : Integer]
    r <- myind$myind
  end fetchIndex
  
  export operation getIndex [start : Integer, q : CPQueue]
    if myind$myq !== q then
      myind$myq <- q
      q.addUpper[self]
      myind$myind <- q.upperbound
    end if
  end getIndex
  
  export operation CPoint [file : OutStream]
    file.putString[obj]
    OIDWriter.Out[stringCTOID, file]
  end CPoint
end CStringCT

const CString <- class CString
    field others : aoa
    field s : String <- ""
    var myind : Integer <- ~1
    field myid : Integer
    const stringId <- 38
    const obj <- "+OB+"
    const objxid <- "+OB-"

    export operation getAnID 
      myid <- nextOID.nextOID
      if Environment$env$generateBuiltin then
	primitive "INSTALLINOID" [] <- [myid, s]
      end if
    end getAnID

    export operation fetchIndex -> [r : Integer]
      r <- myind
    end fetchIndex

    export operation getIndex [start : Integer, q : CPQueue]
      if myind < 0 then
	q.addUpper[self]
	myind <- q.upperbound
	CStringCT.getIndex[start, q]
	if others !== nil then
	  for i : Integer <- 0 while i <= others.upperbound by i <- i + 1
	    const y : CPAble <- view others[i] as CPAble
	    y.getIndex[start, q]
	  end for
	end if
      end if
    end getIndex

    export operation cpoint [file : OutStream]
      var rest : Integer
      if myid !== nil then
	file.putString[obj]
	file.writeInt[16 + 4 + (s.length + 3) / 4 * 4, 4]
	OIDWriter.Out[myid, file]
 	file.writeInt[0x40000000 + CStringCT.fetchIndex, 4]
      else
	file.putString[objxid]
	file.writeInt[4 + 4 + (s.length + 3) / 4 * 4, 4]
 	file.writeInt[0x00000000 + CStringCT.fetchIndex, 4]
      end if
      file.writeInt[s.length, 4]
      file.putstring[s]
      rest <- 4 - s.length # 4
      if rest = 4 then rest <- 0 end if
      loop
	exit when rest = 0
	file.putchar['*']
	rest <- rest - 1
      end loop
    end cpoint
end CString

export CString


const CIntsCT <- immutable object CIntsCT
  const obj <- "-OB-"
  const instctOID <- 0x1827
  const myind <- object x
      field myind : Integer <- ~1
      field myq : CPQueue
  end x
  export operation fetchIndex -> [r : Integer]
    r <- myind$myind
  end fetchIndex
  
  export operation getIndex [start : Integer, q : CPQueue]
    if myind$myq !== q then
      myind$myq <- q
      q.addUpper[self]
      myind$myind <- q.upperbound
    end if
  end getIndex
  
  export operation CPoint [file : OutStream]
    file.putString[obj]
    OIDWriter.Out[instctOID, file]
  end CPoint
end CIntsCT

const IntPair <- class IntPair[pfirst : Integer, psecond : Integer]
  export function first -> [r : Integer]
    r <- pfirst
  end first
  export function second -> [r : Integer]
    r <- psecond
  end second
  export function = [o : IntPair] -> [r : Boolean]
    r <- pfirst = o.first and psecond = o.second
  end =
end IntPair

const aoip <- Array.of[IntPair]
export IntPair
export aoip

const CInts <- class CInts[ps : aoip]
    const s : aoip <- ps
    var myind : Integer <- ~1
    const objxid <- "+OB-"

    export operation fetchIndex -> [r : Integer]
      r <- myind
    end fetchIndex

    export operation getIndex [start : Integer, q : CPQueue]
      if myind < 0 then
	q.addUpper[self]
	myind <- q.upperbound
	CIntsCT.getIndex[start, q]
      end if
    end getIndex

    export operation cpoint [file : OutStream]
      file.putString[objxid]
      file.writeInt[4 + 4 + (s.upperbound + 1) * 16, 4]
      file.writeInt[0x00000000 + CIntsCT.fetchIndex, 4]
      file.writeInt[(s.upperbound + 1) * 4, 4]
      for i : Integer <- 0 while i <= s.upperbound by i <- i + 1
        OIDWriter.OutX[s[i].first, s[i].second, file]
	file.writeInt[0x80000000, 4]
      end for
    end cpoint
end CInts

export CInts

