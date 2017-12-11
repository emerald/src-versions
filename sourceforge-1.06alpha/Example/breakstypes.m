
const TruthObject:SimiliObject <- immutable object TruthObject
  var myfalse: SimiliObject <- FalseObject

  export operation ProcCall [CallName: ProcName, ArgList: ArgListType]
    StdOut.putString["error in truthobject"]
    returnandfail
  end ProcCall
end TruthObject

const FalseObject:SimiliObject <- immutable object FalseObject
  var mytrue: SimiliObject <- TruthObject

  export operation ProcCall [CallName: ProcName, ArgList: ArgListType]
    StdOut.putString["error in falseobject"]
    returnandfail
  end ProcCall
end FalseObject
