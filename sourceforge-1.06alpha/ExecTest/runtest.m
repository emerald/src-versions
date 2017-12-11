export runtest

const runtest <- immutable object runtest
  const runTestType <- typeobject runTestType
    operation finish [Boolean]
    operation done
    operation check  [Boolean, String]
  end runTestType
  export function getSignature -> [r : Signature]
    r <- runTestType
  end getSignature
  export operation create [in : InStream, out : OutStream, testName : String] -> [r : runTestType]
    r <- object aRunTest
      var firstCheckMessagePrinted : Boolean <- false
      var success : Boolean <- true
      export operation finish [result : Boolean]
	if testname !== nil then
	  if firstCheckMessagePrinted then
	    out.PutString["Test \""]
	    out.PutString[testname]
	    out.PutString["\""]
	  end if
	  if result then
	    out.PutString[" completed successfully.\^J"]
	  else
	    out.PutString[" failed.\^J"]
	  end if
	end if
      end finish
      export operation check [b : Boolean, test : String]
	success <- success & b
	if ! b then
	  if ! firstCheckMessagePrinted then
	    out.PutString["\^J"]
	    firstCheckMessagePrinted <- true
	  end if
	  out.PutString["  Test \""]
	  out.PutString[test]
	  out.PutString["\" failed.\^J"]
	end if
      end check
      function getSuccess -> [r : Boolean]
	r <- success
      end getSuccess
      initially
	if testname !== nil then
	  out.PutString["Test \""]
	  out.PutString[testname]
	  out.PutString["\" starting ..."]
	  out.flush
	end if
      end initially
      export operation done 
	self.finish[self.getSuccess[]]
      end done
    end aRunTest
  end create
end runtest

const voi <- Vector.of[Integer]
const ivoi<- ImmutableVector.of[Integer]
const aoi <- Array.of[Integer]
const aoa <- Array.of[Any]
const voc <- Vector.of[Character]
const ivoc<- ImmutableVector.of[Character]
