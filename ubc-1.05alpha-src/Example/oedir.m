const myDirectoryCreator <- immutable object oneEntryDirectoryCreator
  export operation Empty -> [result : Directory]
    result <- monitor object oneEntryDirectory
      var name : String <- ""
      var value : Any <- nil
      export operation Insert[n : String, o : Any]
	name <- n
	value <- o
      end Insert
      export function Lookup[n : String] -> [o : Any]
	if n = name then
	  o <- value
	else
	  o <- nil
	end if
      end Lookup
      export operation Delete[n : String]
	if n = name then
	  name <- ""
	  value <- nil
	end if
      end Delete
      export function List -> [r : ImmutableVectorOfString]
	if name = "" then
	  r <- ImmutableVectorOfString.Literal[{  : String }]
	else
	  r <- ImmutableVectorOfString.Literal[{ name : String }]
	end if
      end List
    end oneEntryDirectory
  end Empty
end oneEntryDirectoryCreator
