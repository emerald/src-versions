
const driver <- object driver
  const myCompiler : Compiler <- Compiler.create
  const separators <- " \n\r\t"
  var ins : InStream
  var outs : OutStream

  operation reportTime [startTime : Time]
    const endTime : Time <- (locate 1).getTimeOfDay
    const elapsed : Time <- endTime - startTime
    outs.putString["Elapsed time = "]
    outs.putString[elapsed.asString]
    outs.putString[" seconds\n"]
  end reportTime

  operation exists [name : String] -> [exists : Boolean]
    var inf : InStream
    inf <- InStream.fromUnix[name, "r"]
    inf.close
    exists <- true
    failure
      exists <- false
    end failure
  end exists

  operation loadDefaultEnvironment
    %
    % Try to find the user's standard compilation environment.  
    % 1. If EMENV is set in the environment, then use it
    % 2. If .emenv exists in the current directory, then use it.
    % 3. If .emenv exists in the home directory, then use it.
    % 4. Load nothing
    var envname, home : String
    primitive "NCCALL" "MISK" "UGETENV" [envname] <- ["EMENV"]
    primitive "NCCALL" "MISK" "UGETENV" [home] <- ["HOME"]

    if envname !== nil and envname != "" then
      myCompiler.load[envname]
    elseif self.exists[".emenv"] then
      myCompiler.load[".emenv"]
    elseif home !== nil and self.exists[home || "/.emenv"] then
      myCompiler.load[home||"/.emenv"]
    end if
  end loadDefaultEnvironment

  operation doit
    var input : String
    var first, second, third : String
    var inputfile : InStream <- ins
    const fstdout : FormattedOutput <- FormattedOutput.ToStream[outs]
    const inputFiles <- Array.of[InStream].create[~8]
    const here <- locate 1
    var reportTimes : Boolean <- false
    var dieOnError : Boolean <- false
    var startTime : Time

    myCompiler.setup[outs]

    self.loadDefaultEnvironment
    loop
      if inputfile == ins and ins.isatty then
	outs.putString["Command: "]
	outs.flush
      end if
      if inputfile.eos then
	if inputFiles.upperbound >= 0 then
	  inputfile.close
	  inputFile <- inputFiles.removeUpper
	else
	  exit
	end if
      else
	input <- inputfile.getString
	first, input <- input.token[separators]
	second <- nil
	third <- nil

	if first == nil then
	  % do nothing
	elseif first = "q" or first = "quit" or first = "exit" then 
	  exit
	elseif first = "checkpoint" then
	  var a : Any <- self
	  if input !== nil then second, input <- input.token[separators] end if
	  if second == nil then
	    fstdout.printf["Checkpoint requires a file name\n", nil]
	  else
	    fstdout.printf["Checkpointing to \"%s\" ...", {second}];
	    fstdout.flush
	    primitive var "CHECKPOINT" [] <- [a, second]
	    fstdout.printf["done.\n", nil];
	  end if
	elseif first = "set" or first = "unset" then
	  const value <- first = "set"
	  if input !== nil then second, input <- input.token[separators] end if
	  if second == nil then
	    fstdout.printf["%s requires a variable name\n", {first}]
	  elseif second = "reporttimes" then
	    reporttimes <- value
	  elseif second = "dieonerror" then
	    dieOnError <- value
	  else
	    myCompiler.option[second, value]
	  end if
	elseif first = "load" then
	  if input !== nil then second, input <- input.token[separators] end if
	  myCompiler.load[second]
	elseif first = "source" then
	  if input !== nil then second, input <- input.token[separators] end if
	  var thefile : InStream
	  begin
	    thefile <- InStream.fromUnix[second, "r"]
	    failure thefile <- nil end failure
	  end
	  if thefile == nil then
	    fstdout.printf["Can't open \"%s\"\n", {second}]
	  else
	    inputFiles.addUpper[inputfile]
	    inputfile <- thefile
	  end if
	elseif first = "eval" then
	  if reportTimes then startTime <- here.getTimeOfDay end if
	  if input !== nil then second, input <- input.token["\n\r"] end if
	  if second == nil then
	    fstdout.printf["eval needs an argument", nil]
	  else
	    myCompiler.eval["const t <- " || second]
	    if reportTimes then self.reportTime[startTime] end if
	  end if
	elseif first = "evals" then
	  if reportTimes then startTime <- here.getTimeOfDay end if
	  if input !== nil then second, input <- input.token["\n\r"] end if
	  if second == nil then
	    fstdout.printf["evals needs an argument", nil]
	  else
	    myCompiler.eval["const t <- object t initially " || second || " end initially end t"]
	    if reportTimes then self.reportTime[startTime] end if
	  end if
	elseif first = "break" then
	  assert false
	elseif first = "gcollect" then
	  primitive "GCOLLECT" [] <- []
	elseif first = "mkdir" then
	  myCompiler$env$externalDirectory <- object aDirectory
	    const aos <- Array.of[String]
	    const names <- aos.empty
	    const vals : aoa  <- aoa.empty
	    
	    export operation list -> [allNames : ImmutableVectorOfString]
	      allNames <- ImmutableVectorofString.literal[names]
	    end list

	    export operation insert [name : String, val : Any]
	      var loc : Integer
	      if name == nil then return end if
	      for i : Integer <- 0 while i <= names.upperbound by i <- i + 1
		if names[i] == nil then
		  if loc == nil then loc <- i end if
		elseif names[i] = name then
		  vals[i] <- val
		  return
		end if
	      end for
	      if loc == nil then
		names.addUpper[name]
		vals.addUpper[val]
	      else
		names[loc] <- name
		vals[loc] <- val
	      end if
	    end insert
	    export operation condinsert[name : String, old : Any, val : Any]  -> [now : Any]
	      assert false
	    end condinsert
	    export function lookup[name : String] -> [val : Any]
	      for i : Integer <- 0 while i <= names.upperbound by i <- i + 1
		const n <- names[i]
		if n !== nil and n = name then
		  val <- vals[i]
		  return
		end if
	      end for
	    end lookup
	    export operation delete[name : String]
	      for i : Integer <- 0 while i <= names.upperbound by i <- i + 1
		const n <- names[i]
		if n !== nil and names[i] = name then
		  names[i] <- nil
		  vals[i] <- nil
		  return
		end if
	      end for
	    end delete
	  end aDirectory
	elseif first = "add" then
	  if input !== nil then second, input <- input.token[separators] end if
	  if input !== nil then third,  input <- input.token[separators] end if
	  if second == nil or third == nil then
	    fstdout.printf["add requires two arguments\n", nil]
	  elseif myCompiler$env$externalDirectory == nil then
	    fstdout.printf["No directory defined\n", nil]
	  else
	    myCompiler$env$externalDirectory.insert[second, third]
	  end if
	elseif first = "lookup" then
	  if input !== nil then second, input <- input.token[separators] end if
	  if second == nil then
	    fstdout.printf["lookup requires one argument\n", nil]
	  elseif myCompiler$env$externalDirectory == nil then
	    fstdout.printf["No directory defined\n", nil]
	  else
	    const answer : Any <- myCompiler$env$externalDirectory.lookup[second]
	    fstdout.printf["lookup[%s] -> \"%s\"\n", {second, answer}]
	  end if
	elseif first = "delete" then
	  if input !== nil then second, input <- input.token[separators] end if
	  if second == nil then
	    fstdout.printf["delete requires one argument\n", nil]
	  elseif myCompiler$env$externalDirectory == nil then
	    fstdout.printf["No directory defined\n", nil]
	  else
	    myCompiler$env$externalDirectory.delete[second]
	  end if
	else
	  if input !== nil then second, input <- input.token[separators] end if
	  if second == nil then
	    if reportTimes then startTime <- here.getTimeOfDay end if
	    myCompiler.compile[first]
	    if dieOnError and myCompiler$env$nErrors > 0 then
	      var exitStatus : Integer <- 1
	      primitive "NCCALL" "MISK" "UEXIT" [] <- [exitStatus]
	    end if
	    if reportTimes then self.reportTime[startTime] end if
	  else
	    fstdout.printf["Invalid command \"%s\"\n", {first}]
	  end if
	end if
      end if
    end loop
  end doit

  initially
    ins <- stdin
    outs <- stdout
  end initially

  recovery
    primitive "SYS" "GETSTDIN" 0 [ins] <- []
    primitive "SYS" "GETSTDOUT" 0 [outs] <- []
    nextoid.reset
  end recovery
  
  process
    self.doit
  end process
end driver
