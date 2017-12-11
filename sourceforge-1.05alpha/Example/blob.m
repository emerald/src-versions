% AssocArray.m - Brian Edmonds <edmonds@cs.ubc.ca> Sep11/94

const arrayofstring <- Array.of[String]
const arrayofany <- Array.of[Any]
const vectorofstring <- Vector.of[String]
const vectorofany <- Vector.of[Any]

const AssocArray <- immutable object AssocArray

  const vectorSize <- 16

  const AssocArrayType <- typeobject AssocArrayType
    operation setElement[ String, Any ]
    operation deleteElement[ String ]
    function getElement[ String ] -> [ Any ]
    function testKey[ String ] -> [ Boolean ]
    operation getKeys -> [ arrayofstring ]
    operation getValues -> [ arrayofany ]
  end AssocArrayType
  export function getSignature -> [ r: Signature ]
    r <- AssocArrayType
  end getSignature

  export operation create -> [ r: AssocArray ]
    r <- object anAssocArray
      const keyVector <- vectorofstring.create[vectorSize]
      const valueVector <- vectorofany.create[vectorSize+2]

      export operation setElement[ key: String, value: Any ]
	var i: Integer <- 0
	var keyVec: vectorofstring <- keyVector
	var valVec: vectorofany <- valueVector

	% if the key is already present, just overwrite the value
	loop
	  const thekey <- keyVec.getElement[i]
	  if thekey !== nil and thekey = key then
	    valVec.setElement[ i, value ]
	    return
	  end if
	  i <- i + 1
	  if i = vectorSize then
	    exit when valVec.getElement[i] == nil
	    keyVec <- view valVec.getElement[i] as Vectorofstring
	    valVec <- view valVec.getElement[i+1] as Vectorofany
	    i <- 0
	  end if
	end loop

	% find or create a new empty slot for this key
	i <- 0
	keyVec <- keyVector
	valVec <- valueVector
	loop
	  if keyVec.getElement[i] == nil then
	    keyVec.setElement[ i, key ]
	    valVec.setElement[ i, value ]
	    return
	  end if
	  i <- i + 1
	  if i = vectorSize then
	    if valVec.getElement[i] == nil then
	      valVec.setElement[ i, VectorofString.create[vectorSize] ]
	      valVec.setElement[ i+1, VectorofAny.create[vectorSize+2] ]
	    end if
	    keyVec <- view valVec.getElement[i] as vectorofstring
	    valVec <- view valVec.getElement[i+1] as vectorofany
	    i <- 0
	  end if
	end loop
      end setElement

      export operation deleteElement[ key: String ]
	var i: Integer <- 0
	var keyVec: vectorofstring <- keyVector
	var valVec: vectorofany <- valueVector

	% find it and kill it
	loop
	  const thekey <- keyVec.getElement[i]
	  if thekey !== nil and thekey = key then
	    keyVec.setElement[ i, nil ]
	    valVec.setElement[ i, nil ]
	    return
	  end if
	  i <- i + 1
	  if i = vectorSize then
	    if valVec.getElement[i] == nil then
	      return
	    end if
	    keyVec <- view valVec.getElement[i] as vectorofstring
	    valVec <- view valVec.getElement[i+1] as vectorofany
	    i <- 0
	  end if
	end loop
      end deleteElement

      export function getElement[ key: String ] -> [ value: Any ]
	var i: Integer <- 0
	var keyVec: vectorofstring <- keyVector
	var valVec: vectorofany <- valueVector

	% find it and return it
	value <- nil
	loop
	  const thekey <- keyVec.getElement[i]
	  if thekey !== nil and thekey = key then
	    value <- valVec.getElement[i]
	    return
	  end if
	  i <- i + 1
	  if i = vectorSize then
	    if valVec.getElement[i] == nil then
	      return
	    end if
	    keyVec <- view valVec.getElement[i] as vectorofstring
	    valVec <- view valVec.getElement[i+1] as vectorofany
	    i <- 0
	  end if
	end loop
      end getElement

      export function testKey[ key: String ] -> [ keyPresent: Boolean ]
	var i: Integer <- 0
	var keyVec: vectorofstring <- keyVector
	var valVec: vectorofany <- valueVector

	% find it and return it
	keyPresent <- false
	loop
	  const thekey <- keyVec.getElement[i]
	  if thekey !== nil and thekey = key then
	    keyPresent <- true
	    return
	  end if
	  i <- i + 1
	  if i = vectorSize then
	    if valVec.getElement[i] == nil then
	      return
	    end if
	    keyVec <- view valVec.getElement[i] as vectorofstring
	    valVec <- view valVec.getElement[i+1] as vectorofany
	    i <- 0
	  end if
	end loop
      end testKey

      export operation getKeys -> [ keys: arrayofstring ]
	var i: Integer <- 0
	var keyVec: vectorofstring <- keyVector
	var valVec: vectorofany <- valueVector

	% build the array of keys
	keys <- ArrayofString.empty
	loop
	  if keyVec.getElement[i] !== nil then
	    keys.addUpper[ keyVec.getElement[i] ]
	  end if
	  i <- i + 1
	  if i = vectorSize then
	    if valVec.getElement[i] == nil then
	      return
	    end if
	    keyVec <- view valVec.getElement[i] as vectorofstring
	    valVec <- view valVec.getElement[i+1] as vectorofany
	    i <- 0
	  end if
	end loop
      end getKeys

      export operation getValues -> [ values: arrayofany ]
	var i: Integer <- 0
	var keyVec: vectorofstring <- keyVector
	var valVec: vectorofany <- valueVector

	% build the array of keys
	values <- ArrayofAny.empty
	loop
	  if keyVec.getElement[i] !== nil then
	    values.addUpper[ valVec.getElement[i] ]
	  end if
	  i <- i + 1
	  if i = vectorSize then
	    if valVec.getElement[i] == nil then
	      return
	    end if
	    keyVec <- view valVec.getElement[i] as vectorofstring
	    valVec <- view valVec.getElement[i+1] as vectorofany
	    i <- 0
	  end if
	end loop
      end getValues

    end anAssocArray
  end create

end AssocArray
export AssocArray

% EOF
% Types.m - Brian Edmonds <edmonds@cs.ubc.ca> Sep11/94

const MudObject <- typeobject MudObject
  operation setShort [ String ] -> [ Boolean ]
  operation setLong [ String ] -> [ Boolean ]
  function queryShort -> [ String ]
  function queryLong -> [ String ]
end MudObject
export MudObject

const EnvironmentObject <- typeobject EnvironmentObject
  function get -> [ MudContainer ]
  operation set[ MudContainer ] -> [ Boolean ]
end EnvironmentObject
export EnvironmentObject

const MovableObject <- typeobject MovableObject
  function getEnvironment -> [ EnvironmentObject ]
end MovableObject
export MovableObject

const MudContainer <- typeobject MudContainer
  operation receiveObject[ MovableObject, Boolean ] -> [ Boolean ]
  operation releaseObject[ MovableObject, Boolean ] -> [ Boolean ]
end MudContainer
export MudContainer

const CommandObject <- typeobject CommandObject
  operation command [ Any, String, String ] -> [ Boolean ]
end CommandObject
export CommandObject

const MudRoom <- typeobject MudRoom
  operation setShort [ String ] -> [ Boolean ]
  operation setLong [ String ] -> [ Boolean ]
  function queryShort -> [ String ]
  function queryLong -> [ String ]
  operation receiveObject[ MovableObject, Boolean ] -> [ Boolean ]
  operation releaseObject[ MovableObject, Boolean ] -> [ Boolean ]
  operation command [ Any, String, String ] -> [ Boolean ]
  operation addExit [ String, MudRoom ] -> [ Boolean ]
  operation removeExit [ String ] -> [ Boolean ]
  function asString -> [ String ]
end MudRoom
export MudRoom

% EOF
% EnvironmentLogic.m - Brian Edmonds <edmonds@cs.ubc.ca> Sep13/94

const EnvironmentLogic <- immutable object EnvironmentLogic

  export function getSignature -> [ sig: Signature ]
    sig <- EnvironmentObject
  end getSignature

  export operation create[ bakaguy: MovableObject, mobile: Boolean ]
			-> [ r: EnvironmentObject ]
    r <- object anEnvironmentLogic
      var env: MudContainer <- nil

      export function get -> [ r: MudContainer ]
	r <- env
      end get

      export operation set[ dest: MudContainer ] -> [ r: Boolean ]
	if ! mobile and env !== nil then
	  r <- false
	  return
	end if
	if env !== nil and ! env.releaseObject[ bakaguy, false ] then
	  r <- false
	elseif ! dest.receiveObject[ bakaguy, false ] then
	  r <- false
	else
	  if env !== nil then
	    env.releaseObject[ bakaguy, true ]
	  end if
	  dest.receiveObject[ bakaguy, true ]
	  env <- dest
	  r <- true
	end if

	failure
	  r <- false
	end failure
      end set

    end anEnvironmentLogic
  end create

end EnvironmentLogic
export EnvironmentLogic

% EOF
% Efun.m - Brian Edmonds <edmonds@cs.ubc.ca> Sep11/94

const Efun <- object Efun

  % write a string to the current user's screen
  export function write [ o : Any, s : String ] -> [ r : Boolean ]
    stdout.putstring[ s ]
    r <- true
  end write

  % accept a command from the current user
  export operation command[ o: Any, s: String ] -> [ r: Boolean ]
    var verb: String
    var args: String
    var i: Integer <- 0
    var j: Integer

    % snip the verb from the command
    loop
      var c: Character <- s.getElement[i]
      exit when c = ' ' or c = '\n'
      i <- i + 1
    end loop
    j <- i
    loop
      var c: Character <- s.getElement[j]
      exit when j = s.length - 1 or c != ' ' and c != '\n'
      j <- j + 1
    end loop
    verb <- s.getSlice[ 0, i ]
    if j = s.length - 1 then
      args <- ""
    else
      args <- s.getSlice[ j, s.length - j - 1 ]
    end if

    % check in the object's environment
    begin
      loop
	const ob <- view o as MovableObject
	const env <- view ob$environment.get as MudRoom
	if env.command[ ob, verb, args ] then
	  r <- true
	  return
	end if
	exit
      end loop

      failure
	% this takes care of our environment not defining command(3)
      end failure
    end

    r <- false
  end command

  initially
    stdout.putString [ "Welcome to Emerald Mud!\n" ]
  end initially

end Efun
export Efun

% EOF
% Room.m - Brian Edmonds <edmonds@cs.ubc.ca> Sep11/94

const Room <- immutable object Room

  % set up the type signature
  export function getSignature -> [ r : Signature ]
    r <- MudRoom
  end getSignature

  % clone a new generic room
  export operation create -> [ ob : MudRoom ]
    ob <- object aRoom
%      const field ident: Integer <- Efun.getIdent[ self ]
      var short: String <- nil
      var long: String <- nil
      const field exits: AssocArray <- AssocArray.create
      const inventory <- ArrayofAny.empty

      % a short, one line description of the room
      export operation setShort [ s : String ] -> [ r : Boolean ]
	r <- false
	if short == nil then
	  short <- s
	  r <- true
	end if
      end setShort
      export function queryShort -> [ r : String ]
        r <- short
      end queryShort

      % a longer, more detailed description of the room
      export operation setLong [ s : String ] -> [ r : Boolean ]
	r <- false
	if long == nil then
	  long <- s
	  r <- true
	end if
      end setLong
      export function queryLong -> [ r : String ]
        r <- long
      end queryLong

      export operation receiveObject[ o:MovableObject, justDoIt:Boolean ]
			-> [ r:Boolean ]
%	r <- false
%	if justDoIt then
%	  for i: Integer <- inventory.lowerbound
%		while i < inventory.upperbound by i <- i + 1
%	    if inventory.getElement[i] == o then return end if
%	  end for
%	  inventory.addUpper[ o ]
	  r <- true
%	end if
      end receiveObject

      export operation releaseObject[ o:MovableObject, justDoIt:Boolean ]
			-> [ r:Boolean ]
	r <- true
%	if justDoIt then
%	  for i: Integer <- inventory.lowerbound
%		while i < inventory.upperbound by i <- i + 1
%	    if inventory.getElement[i] == o then return end if
%	  end for
%	  inventory.addUpper[ o ]
%	  r <- true
%	end if
      end releaseObject

      export operation command[ o:Any, verb:String, args:String ]
			-> [ r:Boolean ]
	const ob <- view o as MovableObject
	if verb = "look" and args.length = 0 then
	  const env <- view ob$environment.get as MudRoom
	  Efun.write[ o, env.queryLong ]
	  r <- true
	elseif exits.testKey[verb] then
	  const d <- view exits.getElement[verb] as MudContainer
	  r <- ob$environment.set[d]
	else
	  r <- false
	end if

	failure
	  r <- false
	end failure
      end command

      export operation addExit[ d: String, o: MudRoom ] -> [ r: Boolean ]
	exits.setElement[ d, o ]
	r <- exits.testKey[d]
      end addExit
      export operation removeExit[ d: String ] -> [ r: Boolean ]
	exits.deleteElement[d]
	r <- ! exits.testkey[d]
      end removeExit

      export function asString -> [ buf: String ]
	const xds <- exits.getKeys
	buf <- "[[ " || nameof self || " ]]\n"
	buf <- buf || "short => " || short || "\n"
	buf <- buf || "long <<EOT\n" || long || "EOT\n"
	buf <- buf || "Exits:\n"
	for i: Integer <- 0 while ! xds.empty by i <- i + 1
	  const x <- xds.removeLower
	  const d <- view exits.getElement[x] as MudRoom
	  buf <- buf || "  " || x || " => " || d.queryShort || "\n"
	end for
      end asString

    end aRoom
  end create

end Room
export Room

% EOF
% User.m - Brian Edmonds <edmonds@cs.ubc.ca> Sep11/94

const User <- immutable object User

  % set up the type signature
  export function getSignature -> [ r : Signature ]
    r <- MovableObject
  end getSignature

  % clone us a new object
  export operation clone -> [ ob : MovableObject ]
    ob <- object aUser
      const field environment: EnvironmentObject
			<- EnvironmentLogic.create[ self, true ]

      process
	var inbuf: String
	loop
	  Efun.write[ self, "> " ]
	  exit when stdin.eos
	  inbuf <- stdin.getString
	  exit when inbuf = "quit\n"
	  if ! Efun.command[ self, inbuf ] then
	    Efun.write[ self, "What?\n" ]
	  end if
	end loop
      end process

    end aUser
  end clone

end User
export User

% EOF
% Weaver.m - Brian Edmonds <edmonds@cs.ubc.ca> Sep11.94

const Weaver <- object Weaver

  initially
    stdout.putString[ "The Weaver moves upon the Loom...\n" ]
  end initially

  process
    const theVoid: MudRoom <- Room.create
    const theHub: MudRoom <- Room.create
    const theSide: MudRoom <- Room.create
    var doof: MovableObject
    var dummy: Boolean

    stdout.putString[ "Weaver: Creating the void...\n" ]
    dummy <- theVoid.setShort[ "The Void" ]
    dummy <- theVoid.setLong[ "This is the void.  It's quite dull.\n" ]
    dummy <- theVoid.addExit[ "hub", theHub ]

    stdout.putString[ "Weaver: Creating the hub...\n" ]
    dummy <- theHub.setShort[ "The Centre of the Universe" ]
    dummy <- theHub.setLong[
"This is the centre of the Universe.  It's quite a happening place.\n" ]
    dummy <- theHub.addExit[ "side", theSide ]

    stdout.putString[ "Weaver: Creating the burbs...\n" ]
    dummy <- theSide.setShort[ "The Side of the Universe" ]
    dummy <- theSide.setLong[
"Some middle of nowhere place out in the 'burbs of the universe.\n" ]
    dummy <- theSide.addExit[ "hub", theHub ]

    stdout.putString[ "Weaver: Creating the console user...\n" ]
    doof <- User.clone
    dummy <- doof$environment.set[ theVoid ]

    stdout.putString[ theVoid.asString ]
    stdout.putString[ theHub.asString ]
    stdout.putString[ theSide.asString ]

    stdout.putString[ "Weaver: done\n" ]

  end process
end Weaver

% EOF
