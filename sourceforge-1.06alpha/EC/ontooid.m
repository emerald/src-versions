export OpNameToOID

const OpNameToOID <- immutable object OpNameToOID
  const table : SITable <- SITable.create[513]
  var count  : Integer <- 0
  var opoidname : String <- nil
  var initialized : Boolean <- false

  export function Lookup [name : String] -> [r : Integer]
    if !initialized then
      self.loadGlobals
    end if

    r <- table.Lookup[name]
    if r == nil then
      r <- count
      table.insert[name, r]
      count <- count + 1

      if opoidname !== nil then
	const file <- OutStream.toUnix[opoidname, "a"]
	if file == nil then
	  const env : EnvironmentType <- Environment$env
	  env.SemanticError[1, "Can't open op-oid file \"%s\"", {opoidname}]
	else
	  file.putString[name]
	  file.putChar['\n']
	  file.close
	end if
      end if
    end if
  end Lookup

  operation loadGlobals
    var file : InStream
    var name : String
    var root : String

    count <- 0
    primitive "GETROOTDIR" [root] <- []
  
    begin
      file <- InStream.fromUnix[root||"/lib/opoid", "r"]
      failure file <- nil end failure
    end
    if file !== nil then
      loop
	begin
	  name <- file.getString
	  failure
	    name <- nil
	  end failure
	end
	exit when name == nil
	name <- name[0, name.length - 1]
	table.Insert[name, count]
	count <- count + 1
      end loop
      file.close
    end if
    count <- 2000
    initialized <- true
  end loadGlobals

  export operation load[fn : String]
    var file : InStream
    var name : String

    opoidname <- fn || ".opd"
    table.reset

    if ! Environment$env$compilingBuiltins then
      self.loadGlobals
    end if

    begin
      file <- InStream.fromUnix[opoidname, "r"]
      failure file <- nil end failure
    end
    if file !== nil then
      loop
	begin
	  name <- file.getString
	  failure name <- nil end failure
	end
	exit when name == nil
	name <- name[0, name.length - 1]
	table.Insert[name, count]
	count <- count + 1
      end loop
      file.close
    end if
  end load
end OpNameToOID
