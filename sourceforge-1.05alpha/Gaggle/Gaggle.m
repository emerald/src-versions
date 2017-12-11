%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%			THE BASE GAGGLE CLASS                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Every subclass of this class, must declare a class const named memberType  %
% that is the type of the elements of the Gaggle.                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

const Gaggle <- immutable object Gaggle builtin 0x1055
  const memberType <- Any
  const GaggleType <- immutable typeobject GaggleType builtin 0x1655
  end GaggleType

  export function getSignature -> [r : Signature]
    r <- GaggleType
  end getSignature

  export operation create -> [r : GaggleType]
    r <- immutable object aGaggle builtin 0x1455
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
    end aGaggle
  end create
end Gaggle  
