const search <- object search
  const directions <- {
    { -1,  0, "north" },
    { -1,  1, "northeast" },
    {  0,  1, "east" },
    {  1,  1, "southeast" },
    {  1,  0, "south" },
    {  1, -1, "southwest" },
    {  0, -1, "west" },
    { -1, -1, "northwest" } : ImmutableVector.of[Any] }

    const tableau <- Array.of[String].create[~14]
    var width : Integer <- 0
    var height : Integer <- 0

    operation searchfrom [prow : Integer, pcol : Integer, word : String] -> [dir : String]
      for dx : Integer <- 0 while dx <= directions.upperbound by dx <- dx + 1
	const d <- directions[dx]
	const deltarow : Integer <- view d[0] as Integer
	const deltacol : Integer <- view d[1] as Integer
	var ok : Boolean <- true
	var row : Integer <- prow
	var col : Integer <- pcol


	for i : Integer <- 1 while i < word.length by i <- i + 1
	  const char <- word[i]
	  if 'A' <= char and char <= 'Z' or 'a' <= char and char <= 'z' then
	    row <- row + deltarow
	    col <- col + deltacol
	    ok <- row >= 0 and row < height and
		  col >= 0 and col < width  and
		  tableau[row][col] = char
	    exit when !ok
	  end if
	end for
	if ok then
	  dir <- view d[2] as String
	  return
	end if
      end for
    end searchfrom

    operation readtableau [input : InStream]
      const buffer : VectorOfChar <- VectorOfChar.create[80]
      var c : Character
      var foundend : Boolean <- false
      var first : Character
      var junk : String

      loop
	exit when tableau.empty
	junk <- tableau.removeUpper
      end loop

      width <- 0
      for i : Integer <- 0 while !foundend by i <- i + 1
	for j : Integer <- 0 while true by j <- j + 1
	  c <- input.getChar
	  if c = '\n' then
	    if width = 0 then
	      width <- j
	    elseif j = 0 then
	      foundend <- true
	      height <- i
	      exit
	    elseif width != j then
		stdout.putstring["Line "]
		stdout.putint[i+1, 0]
		stdout.putstring[" is the wrong length\n"]
	    end if
	    tableau.addupper[String.FLiteral[buffer, 0, j]]
	    exit
	  else
	    buffer[j] <- c
	  end if
	end for
      end for
    end readtableau

    operation readfile[file : String]
      const input <- InStream.fromUnix[file, "r"]
      var word : String
      var direction : String
      var first : Character
      var found : Boolean <- false

      if input == nil then
	stdout.putstring["Can't open \""]
	stdout.putstring[file]
	stdout.putstring["\"\n"]
	return
      end if
      self.readtableau[input]
  %    for i : Integer <- 0 while i <= tableau.upperbound by i <- i + 1
  %      stdout.putstring[tableau[i]]
  %      stdout.putstring["\n"]
  %    end for
      loop
	exit when input.eos
	word <- input.getString
	word <- word.getslice[0, word.length - 1]
%	stdout.putstring["Looking for \""]
%	stdout.putstring[word]
%	stdout.putstring["\"\n"]
	found <- false
	first <- word[0]
	for row : Integer <- 0 while row < height and !found by row <- row + 1
	  for col : Integer <- 0 while col < width and !found by col <- col + 1
	    if tableau[row][col] = first then
	      direction <- self.searchfrom[row, col, word]
	      if direction !== nil then
		stdout.putstring["Found \""]
		stdout.putstring[word]
		stdout.putstring["\" row "]
		stdout.putint[row+1, 0]
		stdout.putstring[" column "]
		stdout.putint[col+1, 0]
		stdout.putstring[" going "]
		stdout.putstring[direction]
		stdout.putstring["\n"]
		found <- true
	      end if
	    end if
	  end for
	end for
	if !found then
	  stdout.putstring["Can't find \""]
	  stdout.putstring[word]
	  stdout.putstring["\".\n"]
	end if
      end loop
    end readfile
    initially
      var filename : String
      loop
	stdout.putstring["Filename: "] stdout.flush
	exit when stdin.eos
	filename <- stdin.getString
	filename <- filename.getSlice[0, filename.length - 1]
	self.readfile[filename]
      end loop
    end initially
end search
