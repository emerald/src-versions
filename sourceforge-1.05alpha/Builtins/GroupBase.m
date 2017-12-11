%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GroupBase.m - useful objects and classes to support group service in Group.m
% Brad Duska
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GLocks - multiple readers, single writer 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
const GLocks <- monitor class GLocks
  var read: Condition <- Condition.create
  var write: Condition <- Condition.create
  var writeCount: Integer <- 0
  var readCount: Integer <- 0
  var writeHolder: Node <- nil

  export operation writeLock [n: Node]
    GDebug.out1["GLocks", "writeLock"]
    writeCount <- writeCount + 1
    if writeCount > 1 or readCount > 0 then
      % already a writer or readers, wait until they are done
      wait write
    end if
    writeHolder <- n
  end writeLock

  export operation writeUnlock [n: Node]
    GDebug.out1["GLocks", "writeUnlock"]
    writeCount <- writeCount - 1
    if n !== writeHolder then
      GDebug.out3["GLocks", "writeUnlock - non lock holder"]
      assert false
    end if
    writeHolder <- nil
    if awaiting write > 0 then
      % other writers, start one
      signal write
    else
      % only readers, start all
      loop
        exit when awaiting read = 0
        signal read
      end loop
    end if
  end writeUnlock

  export operation getWriteHolder -> [n: Node]
    n <- writeHolder
  end getWriteHolder

  export operation readLock
    GDebug.out1["GLocks", "readLock"]
    readCount <- readCount + 1
    if writeCount > 0 then
      % wait until writer(s) done
      wait read
    end if
  end readLock

  export operation readUnlock
    GDebug.out1["GLocks", "readUnlock"]
    readCount <- readCount - 1
    if readCount = 0 then
      % last reader, signal a writer
      signal write
    end if
  end readUnlock
end GLocks


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GCounter - ensures discrete access to counter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
const GCounter <- monitor class GCounter [count: Integer]
  export operation getNext -> [i: Integer]
    i <- count
    count <- count + 1
  end getNext
end GCounter


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GElection - supports elections
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
const GElection <- class GElection 
  [otherGE: GElection, userData: Any]

  % all GElectionNodes
  var gENodeList: GList.of[GElectionNode, Node] <- nil

  % current coordinator
  var coordinator: GElectionCoordinator <- GElectionCoordinator.create

  % next GElection ID, used by coordinator
  var GElectionIDCounter: GCounter <- nil

  initially 
    const n <- locate self

    if otherGE == nil then
      GDebug.out1["GElection", "initially - first GElection"]
      % I am the first GElection, and therefore coordinator
     
      % initialize counter
      GElectionIDCounter <- GCounter.create[1]

      % build node list
      gENodeList <- GList.of[GElectionNode, Node].create
      gENodeList.add[GElectionNode.create[n , self, GElectionIDCounter.getNext, userData]]

      % set coordinator
      coordinator.setCoordinator[gENodeList, n]
    else
      GDebug.out1["GElection", "initially - found other GElection"]
      % I am not the first GElection, get info from coordinator

      begin
        const gECoordinator: GElection <- otherGE.getCoordinator.getGElection
        % build node list
        gENodeList <- gECoordinator.newGElection[n, self, userData]
        gENodeList.moveTo[n]
        move gENodeList to n

        % set coordinator
        coordinator.setCoordinator[gENodeList, locate gECoordinator]

        unavailable
          % failure on startup, just give up
          GDebug.out3["GElection", "initialize - unable to start cleanly"]
          assert false
        end unavailable
      end
    end if
  end initially

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % calls from non-GElection objects %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  export operation getCoordinator -> [n: GElectionNode]
    n <- coordinator.getCoordinator
  end getCoordinator

  export operation list -> [v: Vector.of[GElectionNode]]
    v <- gENodeList.list
  end list

  export operation nodeDown [n: Node] -> [gn: GElectionNode]
    var ngn: GElectionNode <- nil

    % update node list
    gn <- gENodeList.find[n]
    if gn == nil then
      GDebug.out1["GElection", "nodeDown - node without GElection failed, ignoring"]
      return
    end if
    gENodeList.remove[gn] 
        
    if gn.getGElection == coordinator.getCoordinator.getGElection then
      % coordinator has failed
      GDebug.out1["GElection", "nodeDown - picking new coordinator"] 
  
      % pick new coordinator
      ngn <- self.findhighestGElectionID
      coordinator.setCoordinator[gENodeList, ngn.getNode]
        
      if coordinator.getCoordinator.getGElection == self then
        % I am the new coordinator
        GDebug.out1["GElection", "nodeDown - I am the new coordinator"]
    
        % initialize GManagerID counter
        GElectionIDCounter <- GCounter.create[ngn.getID + 1]
      end if
    end if
  end nodeDown

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % calls from other GElection objects %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  export operation newGElection[n: Node, g: GElection, userData: Any] -> [gnl: GList.of[GElectionNode, Node]]
    GDebug.out1["GElection", "newGElection - n g u"]
    self.verifyCoordinator

    % inform all nodes of new GElection
    const v: Vector.of[GElectionNode] <- gENodeList.list
    const newID: Integer <- GElectionIDCounter.getNext
    const tempGENode: GElectionNode <- GElectionNode.create[n, g, i, userData]
    var i: Integer
    for (i <- 0 : i <= v.upperBound : i <- i + 1)
      begin
        const newGENode: GElectionNode <- tempGENode.clone
        v.getElement[i].getGElection.newGElection[self, newGENode]
        unavailable
          GDebug.out2["GElection", "newGElection - attempted to call dead node"]
        end unavailable
      end
    end for 
    gnl <- gENodeList.clone
  end newGElection

  export operation newGElection[cgm: GElection, newGENode: GElectionNode]
    GDebug.out1["GElection", "newGElection - c n"]
    self.verifyCoordinatorCalling[cgm]

    move newGENode to locate self
    newGENode.moveTo[locate self]        
    gENodeList.add[newGENode]
  end newGElection

  export operation findhighestGElectionID -> [g: GElectionNode]
    GDebug.out1["GElection", "findhighestGElectionID"]
    const l: Vector.of[GElectionNode] <- gENodeList.list
    var highestGElectionID: Integer
    g <- nil

    g <- l.getElement[0]
    highestGElectionID <- l.getElement[0].getID

    var i: Integer <- 0
    for ( i <- 1 : i <= l.upperbound : i <- I + 1)
      if l.getElement[i].getID > highestGElectionID then
        g <- l.getElement[i] 
        highestGElectionID <- l.getElement[i].getID
      end if 
    end for
  end findhighestGElectionID

  operation verifyCoordinator 
    if coordinator.getCoordinator.getGElection !== self then
      GDebug.out3["GElection", "verifyCoordinator - not coordinator"]
      assert false
    end if
  end verifyCoordinator

  operation verifyCoordinatorCalling[cge: GElection]
    if coordinator.getCoordinator.getGElection !== cge then
      GDebug.out3["GElection", "verifyCoordinatorCalling - non coordinator making coordinator call"]
      assert false
    end if      
  end verifyCoordinatorCalling
end GElection
   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GElectionNode - information for each node in a GElection list
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
const GElectionNode <- monitor class GElectionNode
  [n: Node, ge: GElection, id: Integer, userData: Any]

  const GUserComplex <- typeobject GUserComplex
    operation clone -> [Any]
    operation moveTo [Node]
  end GUserComplex

  var next: GElectionNode <- nil

  export operation getNode -> [o: Node]
    o <- n
  end getNode

  export operation getGElection -> [o: GElection]
    o <- ge
  end getGElection

  export operation getID -> [o: Integer]
    o <- id
  end getID

  export operation getUserData -> [o: Any]
    o <- userData
  end getUserData

  export operation = [o: Any] -> [b: Boolean]
    if typeof o *> Node then
      b <- (view o as Node) == n
    else
      GDebug.out3["GElectionNode", "= - comparator is not Node type"]
      assert false
    end if
  end =

  export operation getComparator -> [o: Node] 
    o <- n
  end getComparator

  export operation clone -> [o: GElectionNode]
    if typeof userData *> GUserComplex then
      o <- GElectionNode.create[n, ge, id, (view userData as GUserComplex).clone]
    else
      o <- GElectionNode.create[n, ge, id, userData]
    end if
  end clone

  export operation moveTo [n: Node]
    if typeof userData *> GUserComplex then
      (view userData as GUserComplex).moveTo[n]
      move userData to n
    end if
    % move self to n
  end moveTo

  export operation getNext -> [o: GElectionNode]
    o <- next
  end getNext

  export operation setNext [o: GElectionNode]
    next <- o
  end setNext
end GElectionNode


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GElectionCoordinator - maintains current coordinator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
const GElectionCoordinator <- monitor class GElectionCoordinator
  var currentCoordinator: GElectionNode <- nil

  export operation getCoordinator -> [g: GElectionNode]
    GDebug.out1["GElectionCoordinator", "getCoordinator"]
    if currentCoordinator == nil then
      GDebug.out3["GElectionCoordinator", "getCoordinator - current coordinator is nil"]
      assert false
    end if

    g <- currentCoordinator
  end getCoordinator

  export operation setCoordinator [nl: GList.of[GElectionNode, Node], n: Node]
    GDebug.out1["GElectionCoordinator", "setCoordinator"]
    currentCoordinator <- nl.find[n]
    if currentCoordinator == nil then
      GDebug.out3["GElectionCoordinator", "initialize - current coordinator is nil"]
      assert false
    end if
  end setCoordinator
end GElectionCoordinator


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GHashTable - hashes from type Any to type Any
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
const GHashTable <- monitor class GHashTable [size : Integer]
  const voa <- Vector.of[Any]

  var currentsize : Integer <- size
  var keys   : voa <- voa.create[currentsize]
  var values : voa <- voa.create[currentsize]
  var count  : Integer <- 0
  var limit  : Integer <- (currentsize * 4) / 5

  export operation Insert [a : Any, r : Any]
    count <- count + 1
    if count > limit then self.enlarge end if
    self.iInsert[a, r]
  end Insert

  export function Lookup [a : Any] -> [r : Any]
    var s: Integer <- 0
    primitive "GETIDSEQ" [s] <- [a]

    var h : Integer <- s.hash # currentsize
    loop
      const k : Any <- keys[h]
      if k == nil then
        return
      elseif k == a then
        r <- values[h]
	return
      end if
      h <- h + 1
      if h >= currentsize then h <- 0 end if
    end loop
  end Lookup

  export operation Remove[a : Any]
    var s: Integer <- 0
    primitive "GETIDSEQ" [s] <- [a]
    const hash : Integer <- s.hash # currentsize

    % look up a
    var h : Integer <- hash
    loop
      exit when keys[h] == a
      if keys[h] == nil then
        GDebug.out3["GHashTable", "Remove - attempting to remove non-existent item"]
        assert false
      end if
      h <- h + 1
      if h >= currentsize then h <- 0 end if
    end loop

    % set hash slot to nil
    keys[h] <- nil
    values[h] <- nil

    % move all keys/values that hash to the same slot down
    var next : Integer <- 0
    var nexthash : Integer <- 0

    next <- h + 1
    if next >= currentsize then next <- 0 end if
    if keys[next] !== nil then
      const n <- keys[next]
      primitive "GETIDSEQ" [s] <- [n]
      nexthash <- s.hash # currentsize
    end if

    loop 
      exit when keys[next] == nil or hash != nexthash
      % found one that hashes to same spot, move it down
      keys[h] <- keys[next]
      values[h] <- values[next]
      keys[next] <- nil
      values[next] <- nil

      h <- h + 1
      if h >= currentsize then h <- 0 end if
      next <- h + 1
      if next >= currentsize then next <- 0 end if
      if keys[next] !== nil then
        const n <- keys[next]
        primitive "GETIDSEQ" [s] <- [n]
        nexthash <- s.hash # currentsize
      end if
    end loop
  end Remove

  export operation reset
    for i : Integer <- 0 while i < currentsize by i <- i + 1
      keys[i] <- nil
      values[i] <- nil
    end for
    count <- 0
  end reset

  operation iInsert [a : Any, r : Any]
    var s: Integer <- 0
    primitive "GETIDSEQ" [s] <- [a]
    const first <- s.hash # currentsize

    var h : Integer <- first
    loop
      const k : Any <- keys[h]
      if k == nil then
        keys[h] <- a
        values[h] <- r
        return
      elseif k == a then
        GDebug.out3["GHashTable", "iInsert - attempting to insert same item twice"]
        assert false
      end if
      h <- h + 1
      if h >= currentsize then h <- 0 end if
      exit when h = first
    end loop
  end iInsert

  operation enlarge
    const oldvalues <- values
    const oldkeys   <- keys
    const oldsize   <- currentsize

    currentsize <- currentsize * 2 + 1
    limit <- (currentsize * 4) / 5
    values <- voa.create[currentsize]
    keys   <- voa.create[currentsize]

    for i : Integer <- 0 while i < oldsize by i <- i + 1
      const k : Any <- oldkeys[i]
      if k !== nil then
	self.iInsert[k, oldvalues[i]]
      end if
    end for
  end enlarge
end GHashTable


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GList - list template
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
const GList <- immutable object GList
  export function of [eType : Type, cType : Type] -> [r : GListCreatorType]
    % eType is type of element, cType is type of items compared

    forall cType

    suchthat
      eType *> 
        typeobject eType
          operation = [cType] -> [Boolean]
          operation getComparator -> [cType]
          operation clone -> [eType]
          operation moveTo [Node]
          operation getNext -> [eType]
          operation setNext [eType]
        end eType

    where 
      GListType <- typeobject GListType
        operation add [eType]
        operation remove [eType]
        operation find [cType] -> [eType]
        operation list -> [Vector.of[eType]]
        operation clone -> [GListType]
        operation moveTo [Node]
      end GListType

    where
      GListCreatorType <- immutable typeobject GListCreatorType
	operation create -> [GListType]
	function getSignature -> [Signature]
      end GListCreatorType

    r <- immutable object aGListCreator
      const thisGListCreator: GListCreatorType <- self

      export function getSignature -> [r : Signature]
	r <- GListType
      end getSignature

      export operation create -> [r : GListType]
	r <- monitor object aGList
          var dataHead: eType <- nil
          var dataTail: eType <- nil

          export operation add [e : eType]
            GDebug.out1["GList", "add"]
            if self.findInternal [e.getComparator] !== nil then
              GDebug.out3["GList", "add - attempt to add already existing node"]
              assert false
            else
              if dataHead == nil then
                % adding first
                dataHead <- e
                dataTail <- e
              else
                % add at end
                dataTail.setNext[e]
                dataTail <- e
              end if
            end if
          end add

          export operation remove [e : eType]
            GDebug.out1["GList", "remove"]
            var currentRecord: eType <- dataHead
            var previousRecord: eType <- nil
        
            loop
              % find current and previous record
              exit when currentRecord == nil
              if currentRecord == e then
                exit
              end if 
              previousRecord <- currentRecord
              currentRecord <- currentRecord.getNext
            end loop
        
            if currentRecord == nil then
              GDebug.out3["GList", "remove - attempt to remove non existent node"]
              assert false
            elseif previousRecord == nil then
              % deleting first record
              dataHead <- dataHead.getNext
              if currentRecord == dataTail then
                % deleting only record
                dataTail <- nil
              end if
            elseif currentRecord == dataTail then
              % deleting last record of many
              previousRecord.setNext[nil]
              dataTail <- previousRecord
            else
              % deleting record in middle
              previousRecord.setNext[currentRecord.getNext]
            end if
          end remove

          export operation find [c : cType] -> [r : eType]
            GDebug.out1["GList", "find"]
            r <- self.findInternal[c]
          end find
 
          operation findInternal [c: cType] -> [r : eType]
            GDebug.out1["GList", "findInternal"]
            var currentRecord: eType <- dataHead
            r <- nil
        
            loop
              exit when currentRecord == nil
              if currentRecord = c then
                r <- currentRecord
                return
              end if 
              currentRecord <- currentRecord.getNext
            end loop
          end findInternal
        
          export operation list -> [v : Vector.of[eType]]
            GDebug.out1["GList", "list"]
            var count: Integer <- 0
            var currentRecord: eType <- dataHead
        
            % determine how many elements
            loop
              exit when currentRecord == nil
              count <- count + 1
              currentRecord <- currentRecord.getNext
            end loop
                
            % create and fill vector
            v <- Vector.of[eType].create[count]
            currentRecord <- dataHead
            var i: Integer <- 0
            loop
              exit when currentRecord == nil
              v.setElement[i, currentRecord]
              i <- i + 1
              currentRecord <- currentRecord.getNext
            end loop
          end list

          export operation clone -> [l : GListType]
            GDebug.out1["GList", "clone"]
            var currentRecord: eType <- dataHead
            l <- thisGListCreator.create
        
            loop
              exit when currentRecord == nil
              l.add[currentRecord.clone]
              currentRecord <- currentRecord.getNext
            end loop
          end clone
        
          export operation moveTo [n : Node]
            var currentRecord: eType <- dataHead
        
            loop
              exit when currentRecord == nil
              currentRecord.moveTo[n]
              move currentRecord to n
              currentRecord <- currentRecord.getNext
            end loop
            % move self to n
          end moveTo
	end aGList
      end create
    end aGListCreator
  end of
end GList


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GArray - array template
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
const GArray <- immutable object GArray
  export function of [etype : type] -> [r : GArrayCreatorType]
    suchthat
      etype *> 
        typeobject eType
        end eType

    where 
      GArrayType <- typeobject GArrayType
          operation add [eType]
          operation remove [eType]
          operation find [eType] -> [Integer]
          operation list -> [Vector.of[eType]]
          operation clone -> [GArrayType]
          operation moveTo [Node]
      end GArrayType

    where
      GArrayCreatorType <- immutable typeobject GArrayCreatorType
	operation create -> [GArrayType]
	function getSignature -> [Signature]
      end GArrayCreatorType


    r <- immutable object aGArrayCreator
      const thisGArrayCreator: GArrayCreatorType <- self

      export function getSignature -> [r : Signature]
	r <- GArrayType
      end getSignature

      export operation create -> [r : GArrayType]
	r <- monitor object aGArray
          var data: Array.of[eType] <- Array.of[eType].empty

          export operation add [e : eType]
            GDebug.out1["GArray", "add"]
            if self.findInternal[e] != -1 then
              GDebug.out3["GArray", "add - attempting to add already existing item"]
              assert false
            end if
            data.addUpper[e]
          end add

          export operation remove [e : eType]
            GDebug.out1["GArray", "remove"]
            var index: Integer <- self.findInternal[e]
            if index = -1 then
              GDebug.out3["GArray", "remove - attempting to remove nonexistent item"]
              assert false
            end if
            data.setElement[index, data.getElement[data.upperBound]]
            const removedMember: Any <- data.removeUpper
          end remove

          export operation find [e : eType] -> [i : Integer]
            GDebug.out1["GArray", "find"]
            i <- self.findInternal[e]
          end find
 
          operation findInternal [e: eType] -> [i : Integer]
            GDebug.out1["GArray", "findInternal"]
            i <- -1
            var j: Integer <- 0
            for (j <- data.lowerBound : j <= data.upperBound : j <- j + 1)
              if data.getElement[j] == e then
                i <- j
                return
              end if
            end for 
          end findInternal
        
          export operation list -> [v : Vector.of[eType]]
            GDebug.out1["GArray", "list"]
            v <- Vector.of[eType].create[data.upperBound + 1 - data.lowerBound]
            var i: Integer
            for (i <- data.lowerBound : i <= data.upperBound : i <- i + 1)
              v.setElement[i - data.lowerBound, data.getElement[i]]
            end for 
          end list

          export operation clone -> [l : GArrayType]
            GDebug.out1["GArray", "clone"]
            l <- thisGArrayCreator.create
            var i: Integer
            for (i <- data.lowerBound : i <= data.upperBound : i <- i + 1)
              l.add[data.getElement[i + data.lowerBound]]
            end for
          end clone
        
          export operation moveTo [n : Node]
            GDebug.out1["GArray", "moveTo"]
            % don't move elements
            % move self to n
          end moveTo
	end aGArray
      end create
    end aGArrayCreator
  end of
end GArray


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GDebug - Output functions for debugging
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
const GDebug <- immutable class GDebug
  % appout - messages always output by applications
  % out1 - least important messages
  % out2 - somewhat important messages
  % out3 - most important messages

  class const print1: boolean <- false
  class const header1: String <- "   # "
  class const print2: boolean <- true
  class const header2: String <- "  ## "
  class const print3: boolean <- true
  class const header3: String <- " ### "

  class export operation appout [location: String, message: String]
      (locate self)$stdout.PutString[location || ": " || message || "\n"]
  end appout

  class export operation appout [message: String]
      (locate self)$stdout.PutString[message || "\n"]
  end appout

  class export operation out1 [location: String, message: String]
    if print1 then
      (locate self)$stdout.PutString[header1 || location || ": " || message || "\n"]
    end if 
  end out1

  class export operation out1 [message: String]
    if print1 then
      (locate self)$stdout.PutString[header1 || message || "\n"]
    end if
  end out1

  class export operation out2 [location: String, message: String]
    if print2 then
      (locate self)$stdout.PutString[header2 || location || ": " || message || "\n"]
    end if 
  end out2

  class export operation out2 [message: String]
    if print2 then
      (locate self)$stdout.PutString[header2 || message || "\n"]
    end if
  end out2

  class export operation out3 [location: String, message: String]
    if print3 then
      (locate self)$stdout.PutString[header3 || location || ": " || message || "\n"]
    end if 
  end out3

  class export operation out3 [message: String]
    if print3 then
      (locate self)$stdout.PutString[header3 || message || "\n"]
    end if
  end out3
end GDebug
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Exports 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
export GLocks
export GCounter
export GElection
export GElectionNode
export GElectionCoordinator
export GHashTable
export GList
export GArray
export GDebug


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EOF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





