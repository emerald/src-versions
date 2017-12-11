const tester <- object tester
  operation foo [x : Any]
    stdout.putstring[nameof x]
    stdout.putchar['\n']
  end foo
  initially
    self.foo[AOpVector]
    self.foo[AOpVectorE]
    self.foo[AParamList]
    self.foo[Type]
    self.foo[Any]
%    self.foo[Array] 	% doesn't currently exist at runtime
    self.foo[Bitchunk]
    self.foo[Boolean]
    self.foo[COpVector]
    self.foo[COpVectorE]
    self.foo[ConcreteType]
    self.foo[Character]
    self.foo[Condition]
    self.foo[Handler]
    self.foo[InterpreterState]
%    self.foo[ImmutableVector] % doesn't currently exist at runtime
    self.foo[InStream]
    self.foo[Integer]
    self.foo[NodeListElement]
    self.foo[None]
    self.foo[Node]
    self.foo[NodeList]
    self.foo[OutStream]
    self.foo[RISC]
    self.foo[Real]
    self.foo[Signature]
    self.foo[String]
    self.foo[Time]
%    self.foo[Unix]		% isn't currently defined
%    self.foo[Vector] 	% doesn't currently exist at runtime
    self.foo[VectorOfChar]
    self.foo[VectorOfInt]
  end initially
end tester
