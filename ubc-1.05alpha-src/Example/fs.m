% An Emerald file system shell implementing
%	
%	mkdir name
%	cd name
%	insert name string
%	lookup name
%	rm name

export Shell
const Shell <- class Shell[startDir : Directory]

  const prompt : String <- "-- "
  var reMkdir, reCd, reInsert, reLookup, reRm : Any
  const mkdir <- "^mkdir ([-a-z0-9.]+)$"
  const cd <- "^cd ([-a-z0-9.]+)$"
  const insert <- "^insert ([-a-z0-9.]+) ([-a-z0-9.]+)$"
  const lookup <- "^lookup ([-a-z0-9.]+)$"
  const rm <- "^rm ([-a-z0-9.]+)$"

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
  
  initially
    primitive "NCCALL" "REGEXP" "REG_COMP" [ reMkdir ] <- [ mkdir ]
    primitive "NCCALL" "REGEXP" "REG_COMP" [ reCd ] <- [ cd ]
    primitive "NCCALL" "REGEXP" "REG_COMP" [ reInsert ] <- [ insert ]
    primitive "NCCALL" "REGEXP" "REG_COMP" [ reLookup ] <- [ lookup ]
    primitive "NCCALL" "REGEXP" "REG_COMP" [ reRm ] <- [ rm ]
  end initially
  
  process
    var buf: String
    const stdout <- (locate 1).getstdout
    const stdin <- (locate 1).getstdin
    const fstdout : FormattedOutput <- FormattedOutput.create[stdout]

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
	  currentDir <- newDir
	else
	  fstdout.printf["%s is not a directory\n", { name }]
	endif
      elseif self.isLookup[ buf ] then
        var name: String
        primitive "NCCALL" "REGEXP" "REG_SUB" [ name ] <- [ reLookup, first ]
	const newDir : Map <- Map.create
	newDir.insert[".", newDir]
	newDir.insert["..", currentDir]
	currentDir.insert[name, newDir]
      elseif self.isInsert[ buf ] then
        var name: String
        primitive "NCCALL" "REGEXP" "REG_SUB" [ name ] <- [ reInsert, first ]
	const newDir : Map <- Map.create
	newDir.insert[".", newDir]
	newDir.insert["..", currentDir]
	currentDir.insert[name, newDir]
      elseif self.isRm[ buf ] then
        var name: String
        primitive "NCCALL" "REGEXP" "REG_SUB" [ name ] <- [ reRm, first ]
	const newDir : Map <- Map.create
	newDir.insert[".", newDir]
	newDir.insert["..", currentDir]
	currentDir.insert[name, newDir]
      else
        stdout.putString[ "Confarbulation error.\n" ]
      end if
    end loop
  end process
end shell

% EOF
