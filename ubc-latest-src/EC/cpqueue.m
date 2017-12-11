const RISCP <- typeobject RISCP
  function getElement [Integer] -> [CPAble]
  function upperbound -> [Integer]
  function lowerbound -> [Integer]
end RISCP

const CPQueue <- typeobject CPQueue
  function  getElement [Integer] -> [CPAble]
  operation setElement [Integer, CPAble]
  function  upperbound -> [Integer]
  function  lowerbound -> [Integer]
  function  getElement [Integer, Integer] -> [CPQueue]
  operation setElement [Integer, Integer, RISCP]
  operation slideTo [Integer]
  operation addUpper[CPAble]
  operation removeUpper -> [CPAble]
  operation addLower [CPAble]
  operation removeLower -> [CPAble]
  function  empty -> [Boolean]
  operation catenate [RISCP] -> [CPQueue]
end CPQueue

const CPAble <- typeobject CPAble
  operation fetchIndex -> [Integer]
  operation getIndex[Integer, CPQueue]
  operation cpoint [OutStream]
end CPAble

export CPQueue, CPAble

