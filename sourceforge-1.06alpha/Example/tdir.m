% An Emerald file system shell implementing
%	
%	mkdir name
%	cd name
%	insert name string
%	lookup name
%	rm name
%	ls

export Shell
const Shell <- class Shell[startDir : Directory]

  const prompt : String <- "-- "
  var reMkdir, reCd, reInsert, reLookup, reRm, reLs : Integer
  const mkdir <- "^mkdir ([-a-zA-Z0-9.]+)$"
  const cd <- "^cd ([-a-zA-Z0-9.]+)$"
  const insert <- "^insert ([-a-zA-Z0-9.]+) ([-a-zA-Z0-9.]+)$"
  const lookup <- "^lookup ([-a-zA-Z0-9.]+)$"
  const rm <- "^rm ([-a-zA-Z0-9.]+)$"
  const ls <- "^ls$"

  const first <- "\\1"
  const second <- "\\2"

  var currentDir : Directory <- startDir

  function chop[ i: String ] -> [ o: String ]
    o <- i.getSlice[ 0, i.length - 1 ]
  end chop

  operation isMkdir[ buf: String ] -> [ b: Boolean ]
    primitive "NCCALL" "REGEXP" "REG_EXEC" [ b ] <- [ reMkdir, buf ]
  end isMkdir
  
  operation isCd[ buf: String ] -> [ b: Boolean ]
    primitive "NCCALL" "REGEXP" "REG_EXEC" [ b ] <- [ reCd, buf ]
  end isCd
  
  operation isInsert[ buf: String ] -> [ b: Boolean ]
    primitive "NCCALL" "REGEXP" "REG_EXEC" [ b ] <- [ reInsert, buf ]
  end isInsert
  
  operation isLookup[ buf: String ] -> [ b: Boolean ]
    primitive "NCCALL" "REGEXP" "REG_EXEC" [ b ] <- [ reLookup, buf ]
  end isLookup
  
  operation isRm[ buf: String ] -> [ b: Boolean ]
    primitive "NCCALL" "REGEXP" "REG_EXEC" [ b ] <- [ reRm, buf ]
  end isRm
  
  operation isLs[ buf: String ] -> [ b: Boolean ]
    primitive "NCCALL" "REGEXP" "REG_EXEC" [ b ] <- [ reLs, buf ]
  end isLs
  
  initially
    primitive "NCCALL" "REGEXP" "REG_COMP" [ reMkdir ] <- [ mkdir ]
    primitive "NCCALL" "REGEXP" "REG_COMP" [ reCd ] <- [ cd ]
    primitive "NCCALL" "REGEXP" "REG_COMP" [ reInsert ] <- [ insert ]
    primitive "NCCALL" "REGEXP" "REG_COMP" [ reLookup ] <- [ lookup ]
    primitive "NCCALL" "REGEXP" "REG_COMP" [ reRm ] <- [ rm ]
    primitive "NCCALL" "REGEXP" "REG_COMP" [ reLs ] <- [ ls ]
  end initially
  
  process
    var buf: String
    const stdout <- (locate 1).getstdout
    const stdin <- (locate 1).getstdin
    const fstdout : FormattedOutput <- FormattedOutput.toStream[stdout]

    if currentDir.lookup["."] !== currentDir then
      currentDir.insert[".", currentDir]
    end if
    % This one is questionable, but we should make sure .. in the root
    % points somewhere 
    if currentDir.lookup[".."] == nil then
      currentDir.insert["..", currentDir]
    end if
    loop
      stdout.putString[ prompt ] stdout.flush
      exit when stdin.eos
      buf <- self.chop[ stdin.getString ]
      exit when buf = "exit"
      if buf = "" then
      elseif self.isMkdir[ buf ] then
        var name: String
        primitive "NCCALL" "REGEXP" "REG_SUB" [ name ] <- [ reMkdir, first ]
	const newDir : Map <- Map.create
	newDir.insert[".", newDir]
	newDir.insert["..", currentDir]
	currentDir.insert[name, newDir]
      elseif self.isCd[ buf ] then
        var name: String
        primitive "NCCALL" "REGEXP" "REG_SUB" [ name ] <- [ reCd, first ]
	const newDir : Any <- currentDir.Lookup[name]
	if newDir == nil then
	  fstdout.printf["%s is not defined\n", {name}]
	elseif typeof newDir *> Directory then
	  currentDir <- view newDir as Directory
	else
	  fstdout.printf["%s is not a directory\n", { name }]
	end if
      elseif self.isLookup[ buf ] then
        var name: String
        primitive "NCCALL" "REGEXP" "REG_SUB" [ name ] <- [ reLookup, first ]
	var answer : Any
	answer <- currentDir.Lookup[name]
	if answer == nil then
	  fstdout.printf["%s is not defined in that directory\n", {name}]
	elseif typeof answer *> String then
	  fstdout.printf["Lookup[%s] -> %s\n", {name, answer}]
	else
	  fstdout.printf["Lookup[%s] -> %s\n", {name, nameof answer}]
	end if
      elseif self.isInsert[ buf ] then
        var name, value: String
        primitive "NCCALL" "REGEXP" "REG_SUB" [ name ] <- [ reInsert, first ]
        primitive "NCCALL" "REGEXP" "REG_SUB" [ value ] <- [ reInsert, second ]
	currentDir.Insert[name, value]
      elseif self.isRm[ buf ] then
        var name: String
        primitive "NCCALL" "REGEXP" "REG_SUB" [ name ] <- [ reRm, first ]
	currentDir.delete[name]
      elseif self.isLs[ buf ] then
	if typeof currentDir *> Map then
	  const names : ImmutableVectorofString <- currentDir.list
	  for i : Integer <- 0 while i <= names.upperbound by i <- i + 1
	    const value : Any <- currentDir.Lookup[names[i]]
	    if value == nil then
	      fstdout.printf["%s -> nil\n", { names[i]}]
	    elseif typeof value *> String then
	      fstdout.printf["%s -> %s\n", { names[i], value}]
	    else
	      fstdout.printf["%s -> %s\n", { names[i], nameof value}]
	    end if
	  end for
	else
	  fstdout.printf["Can't ls directories like this one\n", nil]
	end if
      else
        stdout.putString[ "Confarbulation error.\n" ]
      end if
    end loop
  end process
end shell

const start <- object start
  process
    const here <- (locate 1)
    here.Delay[Time.create[2, 0]]
    const all <- here.getActiveNodes
    var rootdir : Directory
    for i : Integer <- all.lowerbound while i <= all.upperbound by i <- i + 1
      const thenode <- all[i].getthenode
      if thenode.getrootdirectory !== nil then
	rootdir <- thenode.getrootdirectory
      end if
    end for
    if rootdir !== nil then
      const foo <- Shell.create[rootdir]
    end if
  end process
end start
% EOF
