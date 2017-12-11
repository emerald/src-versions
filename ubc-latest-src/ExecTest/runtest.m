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
  export operation create [cin : InStream, cout : OutStream, testName : String] -> [r : runTestType]
    r <- object aRunTest
      var firstCheckMessagePrinted : Boolean <- false
      var success : Boolean <- true
      export operation finish [result : Boolean]
	if testname !== nil then
	  if firstCheckMessagePrinted then
	    cout.PutString["Test \""]
	    cout.PutString[testname]
	    cout.PutString["\""]
	  end if
	  if result then
	    cout.PutString[" completed successfully.\^J"]
	  else
	    cout.PutString[" failed.\^J"]
	  end if
	end if
      end finish
      export operation check [b : Boolean, test : String]
	success <- success & b
	if ! b then
	  if ! firstCheckMessagePrinted then
	    cout.PutString["\^J"]
	    firstCheckMessagePrinted <- true
	  end if
	  cout.PutString["  Test \""]
	  cout.PutString[test]
	  cout.PutString["\" failed.\^J"]
	end if
      end check
      function getSuccess -> [r : Boolean]
	r <- success
      end getSuccess
      initially
	if testname !== nil then
	  cout.PutString["Test \""]
	  cout.PutString[testname]
	  cout.PutString["\" starting ..."]
	  cout.flush
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
