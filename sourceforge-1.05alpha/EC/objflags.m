const objectflags <- class objectflags
  const x <- BitChunk.create[4]

  initially
    x[0,32] <- 0
  end initially

  export operation setIsImmutable [a : Boolean]
    x[0, 1] <- a.ord
  end setIsImmutable
  export function getIsImmutable -> [r : Boolean]
    r <- x[0, 1] == 1
  end getIsImmutable

  export operation setIsManifest [a : Boolean]
    x[1, 1] <- a.ord
  end setIsManifest
  export function getIsManifest -> [r : Boolean]
    r <- x[1, 1] == 1
  end getIsManifest

  export operation setIsNotManifest [a : Boolean]
    x[2, 1] <- a.ord
  end setIsNotManifest
  export function getIsNotManifest -> [r : Boolean]
    r <- x[2, 1] == 1
  end getIsNotManifest

  export operation setCannotBeConformedTo [a : Boolean]
    x[3, 1] <- a.ord
  end setCannotBeConformedTo
  export function getCannotBeConformedTo -> [r : Boolean]
    r <- x[3, 1] == 1
  end getCannotBeConformedTo
  
  export operation setIsVector [a : Boolean]
    x[4, 1] <- a.ord
  end setIsVector
  export function getIsVector -> [r : Boolean]
    r <- x[4, 1] == 1
  end getIsVector

  export operation setIsTypeVariable [a : Boolean]
    x[5, 1] <- a.ord
  end setIsTypeVariable
  export function getIsTypeVariable -> [r : Boolean]
    r <- x[5, 1] == 1
  end getIsTypeVariable

  export operation setResultsDependOnlyOnArgs [a : Boolean]
    x[6, 1] <- a.ord
  end setResultsDependOnlyOnArgs
  export function getResultsDependOnlyOnArgs -> [r : Boolean]
    r <- x[6, 1] == 1
  end getResultsDependOnlyOnArgs

  export operation setInExecutableConstruct [a : Boolean]
    x[7, 1] <- a.ord
  end setInExecutableConstruct
  export function getInExecutableConstruct -> [r : Boolean]
    r <- x[7, 1] == 1
  end getInExecutableConstruct

  export operation setDependsOnTypeVariable [a : Boolean]
    x[8, 1] <- a.ord
  end setDependsOnTypeVariable
  export function getDependsOnTypeVariable -> [r : Boolean]
    r <- x[8, 1] == 1
  end getDependsOnTypeVariable

  export operation setTypesAreAssigned [a : Boolean]
    x[9, 1] <- a.ord
  end setTypesAreAssigned
  export function getTypesAreAssigned -> [r : Boolean]
    r <- x[9, 1] == 1
  end getTypesAreAssigned

  export operation setTypesHaveBeenChecked [a : Boolean]
    x[10, 1] <- a.ord
  end setTypesHaveBeenChecked
  export function getTypesHaveBeenChecked -> [r : Boolean]
    r <- x[10, 1] == 1
  end getTypesHaveBeenChecked

  export operation setDoesNotDuplicateSelf [a : Boolean]
    x[11, 1] <- a.ord
  end setDoesNotDuplicateSelf
  export function getDoesNotDuplicateSelf -> [r : Boolean]
    r <- x[11, 1] == 1
  end getDoesNotDuplicateSelf

  export operation setDoesNotMoveArguments [a : Boolean]
    x[12, 1] <- a.ord
  end setDoesNotMoveArguments
  export function getDoesNotMoveArguments -> [r : Boolean]
    r <- x[12, 1] == 1
  end getDoesNotMoveArguments

  export operation setDoLocalCreate [a : Boolean]
    x[13, 1] <- a.ord
  end setDoLocalCreate
  export function getDoLocalCreate -> [r : Boolean]
    r <- x[13, 1] == 1
  end getDoLocalCreate

  export operation setTypeDependsOnTypeVariable [a : Boolean]
    x[14, 1] <- a.ord
  end setTypeDependsOnTypeVariable
  export function getTypeDependsOnTypeVariable -> [r : Boolean]
    r <- x[14, 1] == 1
  end getTypeDependsOnTypeVariable

  export operation setDoesNotMoveSelf [a : Boolean]
    x[15, 1] <- a.ord
  end setDoesNotMoveSelf
  export function getDoesNotMoveSelf -> [r : Boolean]
    r <- x[15, 1] == 1
  end getDoesNotMoveSelf

  export operation setAlreadyGenerated [a : Boolean]
    x[16, 1] <- a.ord
  end setAlreadyGenerated
  export function getAlreadyGenerated -> [r : Boolean]
    r <- x[16, 1] == 1
  end getAlreadyGenerated

end objectflags

export ObjectFlags

