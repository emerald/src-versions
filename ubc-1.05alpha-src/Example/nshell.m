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

  var currentDir : Directory <- startDir

  function chop[ i: String ] -> [ o: String ]
    o <- i.getSlice[ 0, i.length - 1 ]
  end chop

  process
    var buf, cmd: String
    const stdout <- (locate self).getstdout
    const stdin <- (locate self).getstdin
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
      cmd, buf <- buf.token[" "]
      if cmd == nil or cmd = "" then
      elseif cmd = "exit" then
	exit
      elseif cmd = "mkdir" then
        var name: String
	if buf !== nil then name, buf <- buf.token[" "] end if
	const newDir : Directory <- Directory.create
	newDir.insert[".", newDir]
	newDir.insert["..", currentDir]
	currentDir.insert[name, newDir]
      elseif cmd = "cd" then
        var name: String
	if buf !== nil then name, buf <- buf.token[" "] end if
	const newDir : Any <- currentDir.Lookup[name]
	if newDir == nil then
	  fstdout.printf["%s is not defined\n", {name}]
	elseif typeof newDir *> Directory then
	  currentDir <- view newDir as Directory
	else
	  fstdout.printf["%s is not a directory\n", { name }]
	end if
      elseif cmd = "lookup" then
        var name: String
	if buf !== nil then name, buf <- buf.token[" "] end if
	var answer : Any
	answer <- currentDir.Lookup[name]
	if answer == nil then
	  fstdout.printf["%s is not defined in that directory\n", {name}]
	elseif typeof answer *> String then
	  fstdout.printf["Lookup[%s] -> %s\n", {name, answer}]
	else
	  fstdout.printf["Lookup[%s] -> %s\n", {name, nameof answer}]
	end if
      elseif cmd = "insert" then
        var name, value: String
	if buf !== nil then name, buf <- buf.token[" "] end if
	if buf !== nil then value, buf <- buf.token[" "] end if
	currentDir.Insert[name, value]
      elseif cmd = "rm" then
        var name: String
	if buf !== nil then name, buf <- buf.token[" "] end if
	currentDir.delete[name]
      elseif cmd = "ls" then
	if typeof currentDir *> Directory then
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
    here.Delay[Time.create[0, 10]]
    const rootdir : Directory <- here.getrootdirectory
    const foo <- Shell.create[rootdir]
  end process
end start
% EOF
