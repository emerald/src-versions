const Gaggle <- class Gaggle
   export function of[memberType: type]->[result: gaggleType]
   where gaggleType <-
        typeobject gaggleType
          function getSignature []->[Signature]
          operation makeGaggle [] ->[gaggleManager]
   	end gaggleType
   result <-
        immutable object gaggleCons
	   export function getSignature[]->[s:Signature]
      		s <- gaggleManager
           end getSignature
           export operation makeGaggle [] -> [aGaggleManager:gaggleManager]
      		aGaggleManager <-
                    immutable object manager
	               initially
                          primitive self var "CREATEGAGGLE" [] <- []
                       end initially
	               export operation addMember[newMember: memberType]->[]
                          primitive self var "ADDTOGAGGLE" [] <- [newMember]
	               end addMember
                       export operation invokee [] -> [gaggleInvokee: memberType]
	                  primitive self var "GETGAGGLEMEMBER" [gaggleInvokee] <- []
                       end invokee
                       export operation invokee[i: Integer]->[gaggleInvokee:memberType]
	                     primitive self var "GETGAGGLEELEMENT" [gaggleInvokee]<-[i]
	               end invokee 
                    end manager
           end makeGaggle
	end gaggleCons
    end of
end Gaggle

const DirectoryGaggle <- immutable object DirectoryGaggle
    const BaseGaggle<-Gaggle.of[Directory]
    export operation create[]->[g:DirectoryGaggleType]	
      where gaggleType <-
	typeobject gaggleType
	  function getSignature []->[Signature]
	  operation makeGaggle [] ->[gaggleManager]
	end gaggleType
      where gaggleManager <-
	typeobject gaggleManager
	  operation addMember[memberType]->[]
	  function invokee[]->[memberType]
	  function getInvokee[i: Integer]->[memberType]
	  operation insert[n: String, v: Any]->[]
	  operation delete[n: String]
          function lookup[n: String]->[v:Any]
	  function list[] -> [n: ImmutableVectorOfString]
	end gaggleManager
      
      result <-
	immutable object gaggleCons
	  export function getSignature[]->[s:Signature]
	    s <- gaggleManager
	  end getSignature
	  export operation makeGaggle [] -> [aGaggleManager:gaggleManager]
	    aGaggleManager <-
	      immutable object manager
	        initially
		  primitive self var "CREATEGAGGLE" [] <- []
		end initially
		export operation addMember[newMember: memberType]->[]
		  primitive self var "ADDTOGAGGLE" [] <- [newMember]
		end addMember
		export operation invokee [] -> [gaggleInvokee: memberType]
		  primitive self var "GETGAGGLEMEMBER" [gaggleInvokee] <- []
		end invokee
		export operation getInvokee[i: Integer]->[gaggleInvokee:memberType]
		  primitive self var "GETGAGGLEELEMENT" [gaggleInvokee]<-[i]
		end getInvokee 
		export operation insert[n: String, v: Any]->[]
		  var size: Integer
		  primitive self var "GETGAGGLESIZE"[size]<-[]
		  for i : Integer <- 0 while i < size by i <- i + 1
		  	const gid <- self.getInvokee[i]
		  	gid.insert[n, v]
		  end for
		end insert
		export operation delete[n: String]
		  var size: Integer
		  primitive self var "GETGAGGLESIZE"[size]<-[]
		  for i : Integer <- 0 while i < size by i <- i + 1
		  	const gid <- self.getInvokee[i]
			gid.delete[n]
		  end for
		end delete
		export function lookup[n: String]->[v:Any]
	          const gid <- self.invokee
		  v<- gid.lookup[n]
		end lookup
		export function list[] -> [n: ImmutableVectorOfString]
		  const gid <- self.invokee
		  n<- gid.list 
		end list		
              end manager
    	  end makeGaggle
      end gaggleCons
    end of
  end Gaggle


