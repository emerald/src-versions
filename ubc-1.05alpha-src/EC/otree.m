const otree <- class OTree (Tree) []
  const xisImmutable			<- 0
  const xisExported			<- 1
  const xisNotManifest			<- 2
  const xcannotBeConformedTo		<- 3
  const xisVector			<- 4
  const xisTypeVariable			<- 5
% const xresultsDependOnlyOnArgs	<- 6
  const xinExecutableConstruct		<- 7
  const xdependsOnTypeVariable		<- 8
  const xtypesAreAssigned		<- 9
  const xtypesHaveBeenChecked		<- 10
% const xdoesNotDuplicateSelf		<- 11
% const xdoesNotMoveArguments		<- 12
% const xdoLocalCreate			<- 13
  const xhasBeenDesugared		<- 14
% const xDoesNotMoveSelf		<- 15
  const xAlreadyGenerated		<- 16
  const xGenerateOnlyCT			<- 17
  const xQueuedForGeneration		<- 18
  const xIsMonitored			<- 19
  const xMonitorMayBeElided		<- 20
  const xIsPruned			<- 21
  const xknowinstat			<- 22
  const xknowinstct			<- 23

    var f : Integer <- 0

    export operation setF [x : Integer]
      f <- x
    end setF

    export operation setIsImmutable [a : Boolean]
      f <- f.setBit[xisImmutable, a]
    end setIsImmutable
    export function getIsImmutable -> [r : Boolean]
      r <- f.getBit[xisImmutable]
    end getIsImmutable

    export operation setisExported [a : Boolean]
      f <- f.setBit[xisExported, a]
    end setisExported
    export function getisExported -> [r : Boolean]
      r <- f.getBit[xisExported]
    end getisExported

    export operation setIsNotManifest [a : Boolean]
      f <- f.setBit[xisNotManifest, a]
    end setIsNotManifest
    export function getIsNotManifest -> [r : Boolean]
      r <- f.getBit[xisNotManifest]
    end getIsNotManifest

    export operation setCannotBeConformedTo [a : Boolean]
      f <- f.setBit[xcannotBeConformedTo, a]
    end setCannotBeConformedTo
    export function getCannotBeConformedTo -> [r : Boolean]
      r <- f.getBit[xcannotBeConformedTo]
    end getCannotBeConformedTo

    export operation setIsVector [a : Boolean]
      f <- f.setBit[xisVector, a]
    end setIsVector
    export function getIsVector -> [r : Boolean]
      r <- f.getBit[xisVector]
    end getIsVector

    export operation setIsTypeVariable [a : Boolean]
      f <- f.setBit[xisTypeVariable, a]
    end setIsTypeVariable
    export function getIsTypeVariable -> [r : Boolean]
      r <- f.getBit[xisTypeVariable]
    end getIsTypeVariable

%    export operation setResultsDependOnlyOnArgs [a : Boolean]
%      f <- f.setBit[xresultsDependOnlyOnArgs, a]
%    end setResultsDependOnlyOnArgs
%    export function getResultsDependOnlyOnArgs -> [r : Boolean]
%      r <- f.getBit[xresultsDependOnlyOnArgs]
%    end getResultsDependOnlyOnArgs

    export operation setInExecutableConstruct [a : Boolean]
      f <- f.setBit[xinExecutableConstruct, a]
    end setInExecutableConstruct
    export function getInExecutableConstruct -> [r : Boolean]
      r <- f.getBit[xinExecutableConstruct]
    end getInExecutableConstruct

    export operation setDependsOnTypeVariable [a : Boolean]
      f <- f.setBit[xdependsOnTypeVariable, a]
    end setDependsOnTypeVariable
    export function getDependsOnTypeVariable -> [r : Boolean]
      r <- f.getBit[xdependsOnTypeVariable]
    end getDependsOnTypeVariable

    export operation setTypesAreAssigned [a : Boolean]
      f <- f.setBit[xtypesAreAssigned, a]
    end setTypesAreAssigned
    export function getTypesAreAssigned -> [r : Boolean]
      r <- f.getBit[xtypesAreAssigned]
    end getTypesAreAssigned

    export operation setTypesHaveBeenChecked [a : Boolean]
      f <- f.setBit[xtypesHaveBeenChecked, a]
    end setTypesHaveBeenChecked
    export function getTypesHaveBeenChecked -> [r : Boolean]
      r <- f.getBit[xtypesHaveBeenChecked]
    end getTypesHaveBeenChecked

%    export operation setDoesNotDuplicateSelf [a : Boolean]
%      f <- f.setBit[xdoesNotDuplicateSelf, a]
%    end setDoesNotDuplicateSelf
%    export function getDoesNotDuplicateSelf -> [r : Boolean]
%      r <- f.getBit[xdoesNotDuplicateSelf]
%    end getDoesNotDuplicateSelf

%    export operation setDoesNotMoveArguments [a : Boolean]
%      f <- f.setBit[xdoesNotMoveArguments, a]
%    end setDoesNotMoveArguments
%    export function getDoesNotMoveArguments -> [r : Boolean]
%      r <- f.getBit[xdoesNotMoveArguments]
%    end getDoesNotMoveArguments

%    export operation setDoLocalCreate [a : Boolean]
%      f <- f.setBit[xdoLocalCreate, a]
%    end setDoLocalCreate
%    export function getDoLocalCreate -> [r : Boolean]
%      r <- f.getBit[xdoLocalCreate]
%    end getDoLocalCreate

    export operation sethasBeenDesugared [a : Boolean]
      f <- f.setBit[xhasBeenDesugared, a]
    end sethasBeenDesugared
    export function gethasBeenDesugared -> [r : Boolean]
      r <- f.getBit[xhasBeenDesugared]
    end gethasBeenDesugared

%    export operation setDoesNotMoveSelf [a : Boolean]
%      f <- f.setBit[xdoesNotMoveSelf, a]
%    end setDoesNotMoveSelf
%    export function getDoesNotMoveSelf -> [r : Boolean]
%      r <- f.getBit[xdoesNotMoveSelf]
%    end getDoesNotMoveSelf

    export operation setAlreadyGenerated [a : Boolean]
      f <- f.setBit[xalreadyGenerated, a]
    end setAlreadyGenerated
    export function getAlreadyGenerated -> [r : Boolean]
      r <- f.getBit[xalreadyGenerated]
    end getAlreadyGenerated
    
    export operation setGenerateOnlyCT [a : Boolean]
      f <- f.setBit[xGenerateOnlyCT, a]
    end setGenerateOnlyCT
    export function getGenerateOnlyCT -> [r : Boolean]
      r <- f.getBit[xGenerateOnlyCT]
    end getGenerateOnlyCT
    
    export operation setQueuedForGeneration [a : Boolean]
      f <- f.setBit[xQueuedForGeneration, a]
    end setQueuedForGeneration
    export function getQueuedForGeneration -> [r : Boolean]
      r <- f.getBit[xQueuedForGeneration]
    end getQueuedForGeneration
    
    export operation setIsMonitored [a : Boolean]
      f <- f.setBit[xIsMonitored, a]
    end setIsMonitored
    export function getIsMonitored -> [r : Boolean]
      r <- f.getBit[xIsMonitored]
    end getIsMonitored
    
    export operation setMonitorMayBeElided [a : Boolean]
      f <- f.setBit[xMonitorMayBeElided, a]
    end setMonitorMayBeElided
    export function getMonitorMayBeElided -> [r : Boolean]
      r <- f.getBit[xMonitorMayBeElided]
    end getMonitorMayBeElided
    
    export operation setIsPruned [a : Boolean]
      f <- f.setBit[xIsPruned, a]
    end setIsPruned
    export function getIsPruned -> [r : Boolean]
      r <- f.getBit[xIsPruned]
    end getIsPruned
    
    export operation setKnowInstAT [a : Boolean]
      f <- f.setBit[xKnowInstAT, a]
    end setKnowInstAT
    export function getKnowInstAT -> [r : Boolean]
      r <- f.getBit[xKnowInstAT]
    end getKnowInstAT
    
    export operation setKnowInstCT [a : Boolean]
      f <- f.setBit[xKnowInstCT, a]
    end setKnowInstCT
    export function getKnowInstCT -> [r : Boolean]
      r <- f.getBit[xKnowInstCT]
    end getKnowInstCT
    
    export operation printFlags[s : OutStream]
      for i : Integer <- 0 while i <= xQueuedForGeneration by i <- i + 1
	if f.getBit[i] then
	  var bitname : String
	  if i = xisImmutable then
	    bitname <- "isImmutable"
	  elseif i = xisExported then
	    bitname <- "isExported"
	  elseif i = xisNotManifest then
	    bitname <- "isNotManifest"
	  elseif i = xcannotBeConformedTo then
	    bitname <- "cannotBeConformedTo"
	  elseif i = xisVector then
	    bitname <- "isVector"
	  elseif i = xisTypeVariable then
	    bitname <- "isTypeVariable"
%	  elseif i = xresultsDependOnlyOnArgs then
%	    bitname <- "resultsDependOnlyOnArgs"
	  elseif i = xinExecutableConstruct then
	    bitname <- "inExecutableConstruct"
	  elseif i = xdependsOnTypeVariable then
	    bitname <- "dependsOnTypeVariable"
	  elseif i = xtypesAreAssigned then
	    bitname <- "typesAreAssigned"
	  elseif i = xtypesHaveBeenChecked then
	    bitname <- "typesHaveBeenChecked"
%	  elseif i = xdoesNotDuplicateSelf then
%	    bitname <- "doesNotDuplicateSelf"
%	  elseif i = xdoesNotMoveArguments then
%	    bitname <- "doesNotMoveArguments"
%	  elseif i = xdoLocalCreate then
%	    bitname <- "doLocalCreate"
%	  elseif i = xDoesNotMoveSelf then
%	    bitname <- "DoesNotMoveSelf"
	  elseif i = xAlreadyGenerated then
	    bitname <- "AlreadyGenerated"
	  elseif i = xGenerateOnlyCT then
	    bitname <- "GenerateOnlyCT"
	  elseif i = xQueuedForGeneration then
	    bitname <- "QueuedForGeneration"
	  else 
	    bitname <- "illegal flag"
	  end if
	  s.putstring[bitname]
	  s.putchar[' ']
	end if
      end for
    end printFlags
    
    export operation typeCheck 
      if !self$typesHaveBeenChecked then
	self$typesHaveBeenChecked <- true
	var child : Tree
	const limit <- self.upperbound
	var ch : Integer <- 0
	loop
	  exit when ch > limit
	  child <- self[ch]
	  if child !== nil then
	    child.typeCheck
	  end if
	  ch <- ch + 1
	end loop
      end if
    end typeCheck

    export operation flatten [ininvoke : Boolean, indecls : Tree] -> [r : Tree, outdecls : Tree]
      
      r <- self
      outdecls <- indecls
    end flatten

end OTree

export OTree

