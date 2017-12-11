%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%			THE BASE GAGGLE CLASS                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

const Gaggle <- immutable class Gaggle 
  class const memberType <- Any
  
  initially
    primitive self var "CREATEGAGGLE" [] <- []
  end initially
  
  operation addMember[newMember: memberType]->[]
    primitive self var "ADDTOGAGGLE" [] <- [newMember]
  end addMember
  
  operation invokee [] -> [gaggleInvokee: memberType]
    primitive self var "GETGAGGLEMEMBER" [gaggleInvokee] <- []
  end invokee
  
  operation invokee[i: Integer]->[gaggleInvokee:memberType]
    primitive self var "GETGAGGLEELEMENT" [gaggleInvokee]<-[i]
  end invokee 

  operation lowerbound -> [ind: Integer]
    primitive self var "GETGAGGLESIZE"[ind]<-[]
    if ind == 0 then
      ind <- -1
    else
      ind <- 0
    end if
  end lowerbound

  operation upperbound -> [ind: Integer]
    primitive self var "GETGAGGLESIZE"[ind]<-[]
    ind <- ind - 1
  end upperbound

  operation getElement[ind: Integer]->[gaggleInvokee: memberType]
    gaggleInvokee <- self.invokee[ind]
  end getElement

end Gaggle  


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	         THE DIRECTORY OBJECT WITH LOCKING                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

const L_Directory <- immutable object L_Directory
  
  const L_DirectoryType <- typeobject L_DirectoryType 
    operation insert [String, Any]
    function  lookup [String] 		-> [Any]
    operation delete [String]
    function  list 			-> [ImmutableVectorOfString]
    function  lock 			-> [res: Integer]
    operation release 		
    function  islocked 			-> [res: Integer]
    function  ping 			-> [res: Integer]
  end L_DirectoryType

  export function getSignature -> [ r : Signature ]
    r <- L_DirectoryType
  end getSignature

  export operation create -> [r : L_DirectoryType]
    r <- monitor object aUnixDirectory 
      var canread   : Boolean <- True   % lock variable
      var timer     : Any     <- nil    % for timer thread
      var waitTime  : Integer <- 0
      var allocsize : Integer <- 4
      var size : Integer <- 0
      attached var names : VectorOfString <- VectorOfString.create[allocsize]
      attached var values : VectorOfAny <- VectorOfAny.create[allocsize]      
      
      function find [n : String, insert : Boolean] -> [mid : Integer]
	var lwb, upb, i : Integer
	var found : Boolean <- false
	lwb <- 0
	upb <- size - 1

	loop
	  mid <- (lwb + upb) / 2
	  exit when lwb > upb
	  const aname <- names[mid]
	  if aname = n then
	    found <- true
	    exit
	  elseif aname < n then
	    lwb <- mid + 1
	  else
	    upb <- mid - 1
	  end if
	end loop
	if !found and insert then

	  % Think about growing the vectors
	  if size = allocsize then
	    if allocsize < 128 then
	      allocsize <- allocsize * 2
	    else
	      allocsize <- allocsize + 128
	    end if
	    const oldnames <- names
	    const oldvalues <- values
	    names <- VectorOfString.create[allocsize]
	    values <- VectorOfAny.create[allocsize]
	    i <- 0
	    loop
	      exit when i = size
	      names[i] <- oldnames[i]
	      values[i] <- oldvalues[i]
	      i <- i + 1
	    end loop
	  end if
	    
	  i <- size
	  loop
	    exit when i <= lwb
	    names[i] <- names[i - 1]
	    values[i] <- values[i - 1]
	    i <- i - 1
	  end loop
	  names[i] <- n
	  values[i] <- nil
	  mid <- i
	  size <- size + 1
	end if
      end find

      export operation insert [n : String, v : Any]
	const index <- self.find[n, true]
	assert names[index] = n
	values[index] <- v
      end insert

      export operation delete [n : String]
	var index : Integer <- self.find[n, false]
	if index < size and names[index] = n then
	  size <- size - 1
	  loop
	    exit when index >= size
	    names[index] <- names[index + 1]
	    values[index] <- values[index + 1]
	    index <- index + 1
	  end loop
	end if
      end delete

      export function lookup [n : String] -> [v : Any]
	const index <- self.find[n, false]
	if index < size and names[index] = n then
	  v <- values[index]
	end if
      end lookup

      export function list -> [n : ImmutableVectorOfString]
	n <- ImmutableVectorOfString.Literal[names, size]
      end list
      
      export function lock [] ->[res: Integer]
	if canread = True  then
	  canread<-False
	  if timer == nil then
	    timer <- self.startTimer[]
          else
	    waitTime<-0
          end if
	  res <- 1
	else
	  res <- 0
        end if
      end lock
      
      export operation release [] -> []
	canread<-True
      end release
      
      export function islocked [] -> [res: Integer] 
	if canread = True then
	  res <- 0
	else
	  res <- 1
	end if
      end islocked

      export function ping[]->[res: Integer]
	waitTime <- waitTime+1
	if canread =True then
	  res    <- 1
	  timer  <- nil
	elseif waitTime == 2 then
	  canread <- True
	  timer  <- nil
          res    <- 1
	else
          res<-0
      	end if
      end ping
      
      operation startTimer[]->[a : Any]
	a <- object timerThread
	   process
	     loop
	       (locate self).delay[Time.create[10, 0]]
               exit when aUnixDirectory.ping=1	
	     end loop
	   end process
	end timerThread
      end startTimer
    
    end aUnixDirectory
  end create
end L_Directory


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		      THE STRONG DIRECTORY GAGGLE                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

const DirectoryGaggle <- immutable class DirectoryGaggle (Gaggle) 
  
  class const memberType <- L_Directory
  
  export operation instantiate[newMember: L_Directory]
    var size: Integer
    
    primitive self var "GETGAGGLESIZE"[size]<-[]
    if size = 0 then
      self.addMember[newMember]
    else
      const n <- self.list
      for i: Integer <-0 while i <= n.upperBound by i <- i+1
        newMember.insert[n[i], self.lookup[n[i]]]
      end for
      self.addMember[newMember]	
    end if
  end instantiate

  export operation lock
    var size: Integer
    primitive self var "GETGAGGLESIZE"[size]<-[]
    
    for i : Integer <- 0 while i < size by i <- i + 1
      var gotLock : Integer <-0
      var waitTime: Integer <-0
         
      const gid <- self.invokee[i]
      loop
	begin
          gotLock<-gid.lock[]
	  unavailable
	    gotLock <- 1  
	    (locate self)$stdout.PutString["Gaggle Member cannot be locked 
            probably because of the failure of its server \n"]
	  end unavailable
	end
	exit when ((gotLock=1)or(waitTime>100000))
	waitTime<-waitTime+1
      end loop
      if gotLock != 1 then
	for j: Integer <-0 while j < i by j <- j+1
	  const mid <- self.invokee[j]
	  begin
            mid.release[]
            unavailable
              (locate self)$stdout.PutString["Gaggle Member cannot be locked 
              probably because of the failure of its server \n"]
            end unavailable
          end
        end for
        i <- -1
      end if
   end for
 end lock
  
  export operation insert[n: String, v: Any]->[]
    var size: Integer
    primitive self var "GETGAGGLESIZE"[size]<-[]
    
    self.lock[]
    for i : Integer <- 0 while i < size by i <- i + 1
      const gid <- self.invokee[i]
      begin
        gid.insert[n, v]
        gid.release[]
        unavailable
	  (locate self)$stdout.PutString["Gaggle Member cannot be updated 
          probably because of the failure of its server \n"]
        end unavailable
      end
    end for
  end insert
  
  export operation delete[n: String]
    var size: Integer
    primitive self var "GETGAGGLESIZE"[size]<-[]
    
    self.lock[]
    
    for i : Integer <- 0 while i < size by i <- i + 1
      const gid <- self.invokee[i] 
      begin
	gid.delete[n]
      	gid.release[]
        unavailable
	  (locate self)$stdout.PutString["Gaggle Member cannot be updated 
           probably because of the failure of its server \n"]
        end unavailable
      end
    end for
  end delete
  
  export function lookup[n: String]->[v:Any]
    var size, j: Integer
    var s: String
    
    primitive self var "GETGAGGLESIZE"[size]<-[]
    const check <- Array.of[Any].create[size]
    
    for i : Integer <- 0 while i < size by i <- i + 1
      const gid <- self.invokee[i]
      begin
        check[i]  <- gid.lookup[n]
        unavailable
	  (locate self)$stdout.PutString["Gaggle Member cannot be accessed 
          probably because of the failure of its server \n"]
          check[i] <- nil
        end unavailable
      end 
    end for
     
    j<-0
    loop
      v <- check[j]
      j <- j+1
      exit when ((v !== nil) or (j >= size))
    end loop		
    
    if (v !== nil) then
      for i: Integer <- 0 while i < size by i <- i+1
      	if (check[i] !== nil) then
          if ((view check[i] as String) != (view v as String)) then
	    (locate self)$stdout.PutString["Lookup of "||n||" differs among 
             the replications\n"]
	    (locate self)$stdout.PutString["Hence returning one possible 
             lookup value\n"]
	  end if
        else
          (locate self)$stdout.PutString["Lookup of "||n||" differs among 
           the replications\n"]
	  (locate self)$stdout.PutString["Hence returning one possible 
           lookup value\n"]
        end if
      end for
    end if
  end lookup
   
  export function list[] -> [n: ImmutableVectorOfString]
    const gid <- self.invokee
    begin
      n<- gid.list 
      unavailable
        var size: Integer
        var success: Integer 
        primitive self var "GETGAGGLESIZE"[size]<-[]
        loop
	  success <- 1
	  size <- size-1
	  const goid <- self.invokee[size]
	  begin
	    n <- goid.list
	    unavailable
	      success <- 0
	    end unavailable
	  end
	  exit when ((success = 1)or (size = 0))
        end loop	
      end unavailable
    end
  end list

end DirectoryGaggle


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		              Starting Code                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

const start <- object start
  process
    var g     : DirectoryGaggle <- DirectoryGaggle.create 
    var there : Node
    var all   : NodeList
 
    all <- (locate self).getActiveNodes
    for i: Integer <- 0 while i <= all.upperbound by i <- i+1
      const form <- testx.create[g, all[i]$theNode, i]
    end for
  end process
end start	
	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              XForms Interface with Handlers to invoke operations           %
%                         on the DirectoryGaggle  g                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
const testx <- class testx[g: DirectoryGaggle, there: Node, id: Integer]
  process
    move self to there	
    (locate self)$stdout.PutString["hi there\n"]
    var myxf    : XForms <- XForms.create
    var browse  : Browser
    var myinput : Input
    const myform     <- Form.create[myxf, fl_up_box, 500, 500]
  
    const insertform <- Form.create[myxf, fl_up_box, 150, 100]
    const deleteform <- Form.create[myxf, fl_up_box, 150, 50]
    const lookupform <- Form.create[myxf, fl_up_box, 150, 50]

    browse <- Browser.create[myxf, fl_normal_browser, 10, 120, 300, 280, ""]
    browse.setFontSize[FL_MEDIUM_FONT]
    myform.add[browse]
    
  
    const handleadd <- object handleadd
      var number : Integer <- 1
      export operation CallBack [f  : XFormObject]
        var a : L_Directory <- L_Directory.create
	g.instantiate[a]
	browse.addLine["Gaggle Member:: " || number.asString||" is added\n"]
	number <- number + 1
      end CallBack
    end handleadd 

    const handlequit <- object handlequit
      export operation CallBack [f : XFormObject]
	myform.hide
	myxf.die
      end CallBack
    end handlequit 

    const handleinput <- object handleinput
      var name: String
      var value: String
      var num: Integer<-0
      export operation text [s : String]
     	if num=0 then
	  name<-s
	  num<-num+1
	else
	  value<-s
	  num<-num+1
	end if
	if num=2 then
          g.insert[name, value]
	  browse.addLine["Name: "||name||", Value: "||value||" added\n"]
	  num<-0
	end if
      end text
    end handleinput

    const handleinsertinput <- object handleinsertinput
      field nameinput : Input
      field valueinput : Input

      var name : String
      var value : String
      export operation CallBack [f : XFormObject]
	if f == nameinput then
          name <- nameinput.getInput
	elseif f == valueinput then
	  value <- valueinput.getinput
	  nameinput.clear
	  valueinput.clear
          insertform.hide
	  g.insert[name, value]
	end if
      end CallBack
    end handleinsertinput

    const handledeleteinput <- object handledeleteinput
       export operation CallBack [f : XFormObject]
          var str : String
	  const fin <- view f as Input
	  str <- fin.getInput
	  fin.clear
          deleteform.hide
	  g.delete[str]
	  Browse.addLine[str||" is deleted from the replicated directories 
	  if it exists\n"]
       end CallBack
    end handledeleteinput
    
    const handlelookupinput <- object handlelookupinput
       export operation CallBack [f : XFormObject]
          var val, name : String
	  var tmp       : Any
	  const fin <- view f as Input
          name <- fin.getInput
	  fin.clear
          lookupform.hide
	  tmp <- g.lookup[name]
	  if tmp !== nil then		
	    val<-view tmp as String
	    browse.addLine["Lookup of "||name||" is "||val||"\n"]
	  else
	    browse.addLine["Lookup of "||name||" was not successful\n"]	
	  end if	
       end CallBack
    end handlelookupinput
    
    const handleinsert <- object handleinsert
      export operation CallBack [f : XFormObject] 
	insertform.show[fl_place_free, fl_transient, "Insert"]
      end CallBack
    end handleinsert
    
    const handledelete <- object handledelete
      export operation CallBack [f : XFormObject]
	deleteform.show[fl_place_free, fl_transient, "Delete"]
      end CallBack
    end handledelete

    const handlelookup <- object handlelookup
      export operation CallBack [f : XFormObject]
	lookupform.show[fl_place_free, fl_transient, "Lookup"]
      end CallBack
    end handlelookup
	

    const handlelist <- object handlelist
      export operation CallBack [f : XFormObject]
	var n: ImmutableVectorofString<-ImmutableVectorOfString.create[5]
        n <- g.list
	if n.upperBound >= 0 then
          browse.addLine["***List of Names***\n"]
          for i: Integer <- 0 while i <= n.upperBound by i<-i+1
            browse.addLine[(i+1).asString||" "||n[i].asString||"\n"]
          end for
        else
          browse.addLine["***No data in replicated directories***\n"]
        end if
      end CallBack
    end handlelist

    myform.add[lightbutton.create[myxf, fl_normal_button, 10, 50, 100, 30, "Add a member", handleadd]]
    myform.add[lightbutton.create[myxf, fl_normal_button, 200, 50, 50, 30, "Quit", handlequit]]
    myform.add[lightbutton.create[myxf, fl_normal_button, 350, 120, 60, 30, "Insert", handleinsert]]
    myform.add[lightbutton.create[myxf, fl_normal_button, 350, 160, 60, 30, "Delete", handledelete]]
    myform.add[lightbutton.create[myxf, fl_normal_button, 350, 200, 60, 30, "Lookup", handlelookup]]
    myform.add[lightbutton.create[myxf, fl_normal_button, 350, 240, 60, 30, "List", handlelist]]
   
    const insertnameinput <- Input.create[myxf, fl_normal_input, 50, 10, 100, 30, "Name: ", handleInsertInput]
    const insertvalueinput <- Input.create[myxf, fl_normal_input, 50, 50, 100, 30, "Value: ", handleInsertInput]
    insertnameinput.setScroll[false]
    insertvalueinput.setScroll[false]
    insertform.add[insertnameinput]
    insertform.add[insertvalueinput]
    handleInsertInput$nameinput <- insertnameinput
    handleInsertInput$valueinput <- insertvalueinput
  
    const deleteinput <- Input.create[myxf, fl_normal_input, 50, 10, 100, 30, "Name: ", handleDeleteInput] 
    deleteinput.setScroll[false]
    deleteform.add[deleteinput]
    
    const lookupinput <- Input.create[myxf, fl_normal_input, 50, 10, 100, 30, "Name: ", handleLookupInput] 
    lookupinput.setScroll[false]
    lookupform.add[lookupinput]


    myform.show[fl_place_free, fl_fullborder, "The Gaggle Manager"||id.asString]
    myxf.go
  end process
end testx









