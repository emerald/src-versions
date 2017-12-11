const ttype <- object ttype
  const myTest <- runtest.create[stdin, stdout, "ttype"]
  initially
    % each test looks like myTest.check[<boolean expression>, "<same exp>"]
    var a : type
    a <- type
    myTest.check[a *> type, "a *> type"]
    myTest.check[typeof a.getSignature *> type, "typeof a.getSignature *> type"]
    myTest.check[typeof a.getSignature *> Signature, "typeof a.getSignature *> Signature"]
    myTest.check[typeof a.getSignature.getSignature *> type, "typeof a.getSignature.getSignature *> type"]
    myTest.check[typeof a.getSignature.getSignature *> Signature, "typeof a.getSignature.getSignature *> Signature"]
    myTest.check[typeof typeobject x op y end x *> Signature, "typeof typeobject x op y end x *> Signature"]
    myTest.check[typeof typeobject x op y end x *> type, "typeof typeobject x op y end x *> type"]
    myTest.check[Signature *> Signature, "Signature *> Signature"]
    myTest.check[Signature *> type, "Signature *> type"]
    myTest.check[Signature.getSignature *> Signature, "Signature.getSignature *> Signature"]
    myTest.check[Signature.getSignature *> type, "Signature.getSignature *> type"]
    myTest.check[typeof 3 *> Integer, "typeof 3 *> Integer"]
    myTest.check[Integer *> typeof 3, "Integer *> typeof 3"]
    myTest.check[typeof "abc" *> String, "typeof \"abc\" *> String"]
    myTest.check[String *> typeof "abc", "String *> typeof \"abc\""]
    myTest.check[typeof 2.3 *> Real, "typeof 2.3 *> Real"]
    myTest.check[Real *> typeof 2.3, "Real *> typeof 2.3"]
    myTest.check[typeof { 3, 4 } *> Immutablevector.of[Integer], "typeof { 3, 4 } *> Immutablevector.of[Integer]"]
    myTest.check[Immutablevector.of[Integer] *> typeof { 3, 4 } , "Immutablevector.of[Integer] *> typeof { 3, 4 } "]
    myTest.check[ImmutableVector.of[Integer] *> ImmutableVector.of[Integer], "ImmutableVector.of[Integer] *> ImmutableVector.of[Integer]"]
    myTest.check[Vector.of[Integer] *> VectorOfInt, "Vector.of[Integer] *> VectorOfInt"]
    myTest.check[VectorOfInt *> Vector.of[Integer], "VectorOfInt *> Vector.of[Integer]"]
    myTest.check[! (typeof 3 *> String), "! (typeof 3 *> String)"]
    myTest.check[! (typeof 2.3 *> Integer), "! (typeof 2.3 *> Integer)"]
    myTest.check[! (ImmutableVector.of[Character] *> String), "! (ImmutableVector.of[Character] *> String)"]
    myTest.check[! (String *> ImmutableVector.of[Character]), "! (String *> ImmutableVector.of[Character])"]
    myTest.check[None *> Integer, "None *> Integer"]
    myTest.check[None *> Any, "None *> Any"]
    myTest.check[None *> None, "None *> None"]
    myTest.check[!(String *> None), "!(String *> None)"]
    const faker <- immutable typeobject t
      function getElement[Integer] -> [Character]
      function upperbound -> [Integer]
      function lowerbound -> [Integer]
      function getSlice[Integer, Integer] -> [t]
      function getElement[Integer, Integer] -> [t]
      operation catenate[t] -> [t]
    end t
    myTest.check[!(faker *> ImmutableVector.of[Character]), "!(faker *> ImmutableVector.of[Character])"]
    myTest.check[!(ImmutableVector.of[Character] *> faker), "!(ImmutableVector.of[Character] *> faker)"]
    myTest.done
  end initially
end ttype
