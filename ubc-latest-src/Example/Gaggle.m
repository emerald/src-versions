const Gaggle <-
  immutable object Gaggle
    export function of[memberType: type]->[result: gaggleType]
      forall memberType
      suchthat memberType *> typeobject D
        op insert[String, Any]
	op delete[String]
        function lookup[String] -> [Any]
	function list -> [ImmutableVectorOfString]
      end D
      where gaggleType <-
	typeobject gaggleType
	  function getSignature []->[Signature]
	  operation makeGaggle [] ->[gaggleManager]
	end gaggleType
      where gaggleManager <-
	typeobject gaggleManager
	  operation addMember[memberType]->[]
	  function invokee[]->[memberType]
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
		export operation insert[n: String, v: Any]->[]
		  const gid <- self.invokee
		  gid.insert[n, v]
		end insert
		export operation delete[n: String]
		  const gid <- self.invokee
		  gid.delete[n]
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


const test <- 
  object test
  process
    var d: Directory <- Directory.create
    var g: Gaggle.Of[Directory] <-Gaggle.Of[Directory].makeGaggle	
    const home <-locate self
    var v: String
    var n: ImmutableVectorofString<-ImmutableVectorOfString.create[2]
 
    home$stdout.PutString["I am here\n"]	
    g.addMember[d]
    g.insert["maggie", "deepa"]
    g.insert["daddy", "mummy"]
    v<-view g.lookup["maggie"] as String
    home$stdout.PutString["lookup of maggie gives"||v.asString||"\n"]
    n<-g.list
	
    for i: Integer <-0 while i <=1 by i<-i+1
    	home$stdout.PutString["List"||i.asString||n[i].asString||"\n"]
    end for
    home$stdout.PutString["After Delete\n"]
    g.delete["daddy"]	
    v<-view g.lookup["maggie"] as String
    home$stdout.PutString["lookup of daddy gives"||v.asString||"\n"]
  end process
end test  