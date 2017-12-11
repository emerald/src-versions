const IDS <- immutable object IDS
  const t <- 1
  const sizes <- {
    8, % ABSTRACTTYPEI
    8, % ANYI
    8, % ARRAYI
    4, % BOOLEANI
    1, % CHARACTERI
    4, % CONDITIONI
    4, % INTEGERI
    8, % NILI
    4, % NODEI
    4, % SIGNATUREI
    4, % REALI
    4, % STRINGI
    8, % VECTORI
    4, % TIMEI
    4, % NODELISTELEMENTI
    4, % NODELISTI
    4, % INSTREAMI
    4, % OUTSTREAMI
    8, % IMMUTABLEVECTORI
    4, % BITCHUNKI
    8, % SEQUENCEOFCHARACTERI
    8, % HANDLERI
    4, % VECTOROFCHARI
    8, % RDIRECTORYI
    4, % CONCRETETYPEI
    4, % COPVECTORI
    4, % COPVECTOREI
    4, % AOPVECTORI
    4, % AOPVECTOREI
    4, % APARAMLISTI
    4, % VECTOROFINTI
    4, % INTERPRETERSTATEI
    8, % DIRECTORYI
    4, % IVECTOROFANYI
    8, % SEQUENCEOFANYI
    4, % IVECTOROFINTI
    8, % SEQUENCEI
    4, % STUBI
    8, % DIRECTORYGAGGLEI
    4, % LITERALLISTI
    4, % VECTOROFANYI
    4, % IVECTOROFSTRINGI
    4  % VECTOROFSTRINGI
  }

  const brands : ImmutableVector.of[Character] <- {
    'v', % ABSTRACTTYPEI
    'v', % ANYI
    'v', % ARRAYI
    'd', % BOOLEANI
    'c', % CHARACTERI
    'x', % CONDITIONI
    'd', % INTEGERI
    'v', % NILI
    'x', % NODEI
    'x', % SIGNATUREI
    'f', % REALI
    'x', % STRINGI
    'v', % VECTORI
    'x', % TIMEI
    'x', % NODELISTELEMENTI
    'x', % NODELISTI
    'x', % INSTREAMI
    'x', % OUTSTREAMI
    'v', % IMMUTABLEVECTORI
    'x', % BITCHUNKI
    'v', % SEQUENCEOFCHARACTERI
    'v', % HANDLERI
    'x', % VECTOROFCHARI
    'v', % RDIRECTORYI
    'x', % CONCRETETYPEI
    'x', % COPVECTORI
    'x', % COPVECTOREI
    'x', % AOPVECTORI
    'x', % AOPVECTOREI
    'x', % APARAMLISTI
    'x', % VECTOROFINTI
    'x', % INTERPRETERSTATEI
    'v', % DIRECTORYI
    'x', % IVECTOROFANYI
    'v', % SEQUENCEOFANYI
    'x', % IVECTOROFINTI
    'v', % SEQUENCEI
    'x', % STUBI
    'v', % DIRECTORYGAGGLEI
    'x', % LITERALLISTI
    'x', % VECTOROFANYI
    'x', % IVECTOROFSTRINGI
    'x'  % VECTOROFSTRINGI
  }

  export operation IDToSize [id : Integer] -> [size : Integer]
    var index : Integer <- ~1
    size <- 8
    if 0x1600 <= id and id <= 0x1640 then
      index <- id - 0x1600
    elseif 0x1800 <= id and id <= 0x1840 then
      index <- id - 0x1800
    end if
    
    if index >= 0 then
      size <- sizes[index]
    end if
  end IDToSize

  export operation IDToBrand [id : Integer] -> [brand : Character]
    var index : Integer <- ~1
    brand <- 'v'
    if 0x1600 <= id and id <= 0x1640 then
      index <- id - 0x1600
    elseif 0x1800 <= id and id <= 0x1840 then
      index <- id - 0x1800
    end if
    
    if index >= 0 then
      brand <- brands[index]
    end if
  end IDToBrand

  export operation IDToInstCTID [id : Integer] -> [ctid : Integer]
    var index : Integer
    if 0x1600 <= id and id <= 0x1640 then
      const size <- sizes[id - 0x1600]
      if size = 4 or size = 1 then
	ctid <- id + 0x200
      end if
    elseif 0x1000 <= id and id <= 0x1040 then
      const size <- sizes[id - 0x1000]
      if size = 4 or size = 1 then
	ctid <- id + 0x800
      end if
    end if
  end IDToInstCTID
  export operation IDToATID [id : Integer] -> [atid : Integer]
    if 0x1600 <= id and id <= 0x1640 then
      atid <- id
    elseif 0x1000 <= id and id <= 0x1040 then
      atid <- id + 0x200
    end if
  end IDToATID
  export operation IDToCTID [id : Integer] -> [ctid : Integer]
    if 0x1400 <= id and id <= 0x1440 then
      ctid <- id
    elseif 0x1000 <= id and id <= 0x1040 then
      ctid <- id
    end if
  end IDToCTID
  export operation ConformsByID [ln : Integer, id1 : Integer, id2 : Integer] -> [r : Boolean]
    var a : Any
    const e : EnvironmentType <- Environment$env
    r <- e$conformTable.Lookup[id1, id2]
    if r == nil then
      if id1 = id2 then
	r <- true
      elseif id1 = 0x1607 then
	r <- true
      elseif id2 = 0x1601 then
	r <- true
      elseif id1 = 0x1616 or id2 = 0x1616 or
             id1 = 0x161e or id2 = 0x161e or
             id1 = 0x1621 or id2 = 0x1621 or
	     id1 = 0x1623 or id2 = 0x1623 or
 	     id1 = 0x1627 or id2 = 0x1627 then
	if e$tracetypecheck then
	  e.Warning[ln, "Unknown types (%#x) and (%#x) one vector, conformity assumed", {id1, id2}]
	end if
	r <- true
      elseif 0x1600 <= id2 and id2 <= 0x1640 then
	  const size <- sizes[id2 - 0x1600]
	if size = 1 or size = 4 then
	  r <- false
	end if
      end if
      if r !== nil then
	e$conformTable.Insert[id1, id2, r]
      end if
    end if
    if r == nil then
      if e$tracetypecheck then
	e.Warning[ln, "Unknown types (%#x and %#x), conformity assumed",
	  { id1, id2} ]
      end if
      r <- true
      e$conformTable.Insert[id1, id2, r]
    end if
  end ConformsByID
end IDS

export IDS
