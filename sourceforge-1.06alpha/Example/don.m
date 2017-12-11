const MyIo <- object MyIo
    var iStream : inStream
    var oStream : outStream
    var c       : Character
    var here    : Node

    %
    % an operation that reads a file and creates a big
    % string that holds the whole file... why?? a good thing
    % to start on...
    %
    export operation readFile [fileName: String] -> [file : String]

	var line : String

	file <- ""
	iStream <- inStream.fromUnix[ fileName, "r" ]
	loop
	    exit when iStream.eos
	    begin
	        line <- iStream.getString
		file <- file.asString || line.asString
	    end
	end loop
    end readFile

    export operation writeFile [ fileName : String, file : String ]

	%  dont do anything right now... just for timing
	%
	%oStream <- outStream.toUnix[ fileName, "w" ]
	%oStream.putString[ file ]

    end writeFile

    export operation nuttin

	%  dont do anything right now... just for timing
	%
	here <- locate self
	here$stdout.PutString[ "oooooooh..... nuttin' \n" ]

    end nuttin

end MyIo


const Main <- object Main

    process
	const home <- locate self
	var fileName : String
	var file     : String
	var there    : Node
	var here     : Node
	var all      : NodeList
	var theElem  : NodeListElement
	var sTime    : Time
	var eTime    : Time
	var diff     : Time

	all <- home.getActiveNodes
	home$stdout.PutString[  (all.upperbound + 1).asString 
				|| " nodes active.\n"]

	for i : Integer <- 0 while i <= all.upperbound by i <- i + 1

	    home$stdout.PutString[ "Set here\n" ]
	    home$stdout.flush

	    here <- all[i]$theNode

	    home$stdout.PutString[ "Locate there \n" ]
	    home$stdout.flush

% BOMBS HERE SECOND TIME THROUGH LOOP

	    there <- locate MyIo

	    home$stdout.PutString[ "Moving from " || there.getName.asString ||
				   " to " || here.getName.asString ]
	    move MyIo to here 
	    home$stdout.PutString[ "\tdone\n"]

	    for j : Integer <- i + 1 while j <= all.upperbound by j <- j + 1

		there <- all[j]$theNode
		sTime <- home.getTimeOfDay

		home$stdout.PutString[ "From " || here.getName.asString ||
				   " to " || there.getName.asString ]
		move MyIo to there

		home$stdout.PutString[ "\tdone\n"]
		home$stdout.PutString[ "From " || there.getName.asString ||
				   " to " || here.getName.asString ]
		move MyIo to here

		home$stdout.PutString[ "\tdone\n"]

		diff <- home.getTimeOfDay - sTime
		diff <- diff/2
		home$stdout.PutString[ here.getName.asString 	||
				       " <-> "			||
				       there.getName.asString	||
				       " : "			||
				       diff.asString 		|| "\n" ]
		home$stdout.flush

	    end for

	end for

    home$stdout.PutString[ "all done\n" ]
    end process

end Main
