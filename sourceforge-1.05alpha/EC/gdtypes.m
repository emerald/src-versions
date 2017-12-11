const hasIdent <- typeobject hasIdent
  function getID -> [Ident]
end hasIdent

const hasID <- typeobject hasID
  function getID -> [Integer]
end hasID

const hasConforms <- typeobject hasConforms
  op conformsTo[Integer, Tree] -> [Boolean]
  op asType -> [Tree]
end hasConforms

const hasStr <- typeobject hasStr
  function getStr -> [String]
end hasStr

const hasInstCT <- typeobject hasInstCT
  function asString -> [String]
  function getInstCT -> [Tree]
end hasInstCT

const hasInstAT <- typeobject hasInstAT
  function getInstAT -> [Tree]
end hasInstAT

const hasVariableSize <- typeobject hasVariableSize
  function getBrand -> [Character]
  function variableSize -> [Integer]
end hasVariableSize

const hasInstSize <- typeobject hasInstSize
  function getInstanceSize -> [Integer]
end hasInstSize

const hasIDs <- typeobject hasIDs
    function getid -> [Integer]
    function getATOID -> [Integer]
    function getcodeOID -> [Integer]
    function getinstCTOID -> [Integer]
    function getinstATOID -> [Integer]
end hasIDs

const hasThisObject <- typeobject hasThisObject
  function getThisObject -> [Tree]
end hasThisObject

const Attachable <- typeobject Attachable
  operation setIsAttached [Boolean]
end Attachable
const Monitorable <- typeobject Monitorable
  function  getIsMonitored -> [Boolean]
  operation setIsMonitored [Boolean]
end Monitorable
const hasName <- typeobject hasName
  function getName -> [ Ident ]
end hasName
const TreeMaker <- immutable typeobject TreeMaker
  operation create[Integer, Tree, Tree, Tree] -> [Tree]
end TreeMaker
const InvocType <- immutable typeobject InvocType
  operation create[Integer, Tree, Ident, Tree] -> [Tree]
end InvocType
const AtlitType <- immutable typeobject AtlitType
  operation create[Integer, Tree, Tree, Tree] -> [Tree]
end AtlitType

const aoa <- Array.of[Any]
const aoi <- Array.of[Integer]
const aoc <- Array.of[Character]
const aot <- Array.of[Tree]

export hasIdent, hasID, hasConforms, hasStr, hasInstCT, hasInstAT,
       hasVariableSize, hasIDs, hasThisObject, hasInstSize, InvocType,
       AtlitType,
       attachable, monitorable, hasName, TreeMaker, aoa, aoi, aoc, aot
