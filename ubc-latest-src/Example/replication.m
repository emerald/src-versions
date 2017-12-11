 
export ReplicationWorker
const ReplicationWorker <- immutable object ReplicationWorker
 export function of [rtype : type] -> [r : ReplicationWorkerCreatorType]
   suchthat rtype *> typeobject Replicable
     function cloneMe[] -> [clone : rtype]
     operation primaryCopyUpdated[primaryCopy : rtype]
     operation replicaUpdated[replica : rtype]
     function !=[o: rtype] -> [boolean]
     function isPrimaryCopy[] -> [boolean]
     operation setIsPrimaryCopy[]
     operation writeStatus[]
   end Replicable
   where
   ReplicationWorkerType <- typeobject ReplicationWorkerType
     operation writeStatus[]
   end ReplicationWorkerType

   where
     ReplicationWorkerCreatorType <- immutable typeobject ReplicationWorkerCreatorType
       operation create -> [ReplicationWorkerType]
       function getSignature -> [Signature]
     end ReplicationWorkerCreatorType


  r <- class aReplicationWorkerCreator
    var otherWorkers : Map.of[Integer, ReplicationWorkerType]
    initially
    end initially
    export operation writeStatus[]
    end writeStatus
  end aReplicationWorkerCreator

  end of
end ReplicationWorker
