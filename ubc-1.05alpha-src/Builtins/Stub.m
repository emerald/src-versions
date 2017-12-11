export Stub to "Builtins"

const Stub <- immutable object Stub builtin 0x1025
  const StubType <- typeobject StubType builtin 0x1625
  end StubType

  export function getSignature -> [result : Signature]
    result <- StubType
  end getSignature

  export operation create -> [r : StubType]
    r <- object aStub builtin 0x1425
      var pad : Integer
      process
      end process
    end aStub
  end create
end Stub
