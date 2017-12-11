const SimiliObject <- typeobject SimiliObject
  op ProcCall[ProcName, ArgListType]
end SimiliObject

const ProcName <- typeobject ProcName
  op getName -> [String]
end ProcName

const ArgListType <- typeobject ArgListType
  op getList -> [String]
end ArgListType

export SimiliObject, ProcName, ArgListType
