%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Group.m - objects and classes to support group service, interface is given
%           in class Group
% Brad Duska
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Group.m - immutable interface object, dispatches calls to GManager
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
const Group <- immutable class Group builtin 0x102b
  % precondition - GRep exists in at least one node if the gid hasn't failed
  var id: gid  

  initially
    GDebug.out1["Group", "initially"]
    const gm: GManager <- GUtilities.getGM[locate self]
    const newGRep: GRep <- gm.createGRep[nil]
    
    id <- newGRep.getGID
  end initially

  export operation addMember [o: Any]  -> [r: Boolean]
    GDebug.out1["Group", "addMember"]
    r <- false

    if o == nil then
      GDebug.out2["Group", "addMember - o is nil"]
      return
    end if
 
    const n: Node <- locate o
    if n == nil then
      GDebug.out2["Group", "addMember - o has failed"]
      return
    end if

    var gm: GManager <- nil
    var gr: GRep <- nil
    var v: Vector.of[GElectionNode] <- nil
    begin
      gm <- GUtilities.getGM[n]
      gr <- gm.findGRep[id]
      if gr == nil then
        v <- gm.listNodes
      end if
      unavailable
        GDebug.out2["Group", "addMember - remote GManager has failed"]
        return
      end unavailable
    end

    if gr == nil then
      % look for gid globally
      var i: Integer <- 0
      var otherGRep: GRep <- gr
      for (i <- 0 : i <= v.upperBound : i <- i + 1 )
        begin
          otherGRep <- (view v.getElement[i].getUserData as GManager).findGRep[id]
          if otherGRep !== nil then
            exit
          end if
          unavailable
            GDebug.out2["Group", "addMember - attempted to call a dead node"]
          end unavailable
        end
      end for

      if otherGRep == nil then
        GDebug.out2["Group", "addMember - gid has failed"]
        return 
      end if

      % gid not active on n yet
      begin
        gr <- gm.createGRep[otherGRep]
        unavailable
          GDebug.out2["GRep", "addMember - remote GManager has failed"]
          return
        end unavailable
      end 
    end if

    % make sure object is not immutable
    if (typeof o).getIsImmutable then
      GDebug.out2["Group", "addMember - object is immutable"]
      r <- true
      return
    end if 

    begin
      r <- gr.addMember[o, true]
      unavailable
        GDebug.out2["Group", "addMember - remote GRep has failed"]
      end unavailable
    end
  end addMember

  export operation removeMember [o: Any] -> [r: Boolean]
    GDebug.out1["Group", "removeMember"]
    r <- false

    if o == nil then
      GDebug.out2["Group", "removeMember - o is nil"]
      return
    end if
 
    const n: Node <- locate o
    if n == nil then
      GDebug.out2["Group", "removeMember - o has failed"]
      return
    end if

    var gm: GManager <- nil
    var gr: GRep <- nil
    begin
      gm <- GUtilities.getGM[n]
      gr <- gm.findGRep[id]
      unavailable
        GDebug.out2["Group", "removeMember - remote GManager has failed"]
        return
      end unavailable
    end

    if gr == nil then
      % gr should exist if not failed
      GDebug.out2["Group", "removeMember - gid has failed or o not member"]
      return
    end if

    % make sure object is not immutable
    if (typeof o).getIsImmutable then
      GDebug.out2["Group", "removeMember - object is immutable"]
      r <- true
      return
    end if 

    begin
      r <- gr.removeMember[o, true]
      unavailable
        GDebug.out2["Group", "removeMember - remote GRep has failed"]
      end unavailable
    end
  end removeMember

  export operation listMembers -> [l: Vector.of[Any]]
    GDebug.out1["Group", "listMembers"]
    l <- nil

    var gm: GManager <- GUtilities.getGM[locate self]
    var v: Vector.of[GElectionNode] <- gm.listNodes

    var i: Integer <- 0
    var gr: GRep <- nil
    var success: Boolean <- false
    for (i <- 0 : i <= v.upperBound : i <- i + 1 )
      begin
        gr <- (view v.getElement[i].getUserData as GManager).findGRep[id]
        if gr !== nil then
          l <- gr.listMembers
          success <- true
        end if
        if success then return end if
        unavailable
          GDebug.out2["Group",  "listMembers - attempted to call a dead node"]
        end unavailable
      end
    end for
  end listMembers

  export operation listNodes -> [l: Vector.of[Node]]
    GDebug.out1["Group", "listNodes"]
    l <- nil

    var gm: GManager <- GUtilities.getGM[locate self]
    var v: Vector.of[GElectionNode] <- gm.listNodes

    var i: Integer <- 0
    var gr: GRep <- nil
    var success: Boolean <- false
    for (i <- 0 : i <= v.upperBound : i <- i + 1 )
      begin
        gr <- (view v.getElement[i].getUserData as GManager).findGRep[id]
        if gr !== nil then
          l <- gr.listNodes
          success <- true
        end if
        if success then return end if
        unavailable
          GDebug.out2["Group",  "listNodes - attempted to call a dead node"]
        end unavailable
      end
    end for
  end listNodes 

  export operation addGListener [l: GListener] -> [r: Boolean]
    GDebug.out1["Group", "addGListener"]
    r <- false

    if l == nil then
      GDebug.out2["Group", "addGListener - l is nil"]
      return
    end if
 
    const n: Node <- locate l
    if n == nil then
      GDebug.out2["Group", "addGListener - l has failed"]
      return
    end if

    var gm: GManager <- nil
    var gr: GRep <- nil
    var v: Vector.of[GElectionNode] <- nil
    begin
      gm <- GUtilities.getGM[n]
      gr <- gm.findGRep[id]
      if gr == nil then
        v <- gm.listNodes
      end if
      unavailable
        GDebug.out2["Group", "addGListener - remote GManager has failed"]
        return
      end unavailable
    end

    if gr == nil then
      % look for gid globally
      var i: Integer <- 0
      var otherGRep: GRep <- gr
      for (i <- 0 : i <= v.upperBound : i <- i + 1 )
        begin
          otherGRep <- (view v.getElement[i].getUserData as GManager).findGRep[id]
          if otherGRep !== nil then
            exit
          end if
          unavailable
            GDebug.out2["Group", "addGListener - attempted to call a dead node"]
          end unavailable
        end
      end for

      if otherGRep == nil then
        GDebug.out2["Group", "addGListener - gid has failed"]
        return 
      end if

      % gid not active on n yet
      begin
        gr <- gm.createGRep[otherGRep]
        unavailable
          GDebug.out2["GRep", "addGListener - remote GManager has failed"]
          return
        end unavailable
      end 
    end if

    begin
      r <- gr.addGListener[l, true]
      unavailable
        GDebug.out2["Group", "addGListener - remote GRep has failed"]
      end unavailable
    end
  end addGListener

  export operation removeGListener [l: GListener] -> [r: Boolean]
    GDebug.out1["Group", "removeGListener"]
    r <- false

    if l == nil then
      GDebug.out2["Group", "removeGListener - l is nil"]
      return
    end if
 
    const n: Node <- locate l
    if n == nil then
      GDebug.out2["Group", "removeGListener - l has failed"]
      return
    end if

    var gm: GManager <- nil
    var gr: GRep <- nil
    begin
      gm <- GUtilities.getGM[n]
      gr <- gm.findGRep[id]
      unavailable
        GDebug.out2["Group", "removeGListener - remote GManager has failed"]
        return
      end unavailable
    end

    if gr == nil then
      % gr should exist if not failed
      GDebug.out2["Group", "removeGListener - gid has failed or l not member"]
      return
    end if

    % make sure object is not immutable
    if (typeof l).getIsImmutable then
      GDebug.out2["Group", "removeMember - object is immutable"]
      r <- true
      return
    end if 

    begin
      r <- gr.removeGListener[l, true]
      unavailable
        GDebug.out2["Group", "removeGListener - remote GRep has failed"]
      end unavailable
    end
  end removeGListener

  export operation listGListeners -> [l: Vector.of[GListener]]
    GDebug.out1["Group", "listGListeners"]
    l <- nil

    var gm: GManager <- GUtilities.getGM[locate self]
    var v: Vector.of[GElectionNode] <- gm.listNodes

    var i: Integer <- 0
    var gr: GRep <- nil
    var success: Boolean <- false
    for (i <- 0 : i <= v.upperBound : i <- i + 1 )
      begin
        gr <- (view v.getElement[i].getUserData as GManager).findGRep[id]
        if gr !== nil then
          l <- gr.listGListeners
          success <- true
        end if
        if success then return end if
        unavailable
          GDebug.out2["Group",  "listGListeners - attempted to call a dead node"]
        end unavailable
      end
    end for
  end listGListeners

  export operation moveAll [n: Node] -> [r: Boolean]
    GDebug.out1["Group", "moveAll"]
    r <- true

    const v: Vector.of[Any] <- self.listMembers    
    if v !== nil then
      var i : Integer <- 0
      for ( i <- 0 : i <= v.upperBound : i <- i + 1 )
        begin
          move v.getElement[i] to n
          failure
            r <- false
          end failure
        end 
      end for
    end if
  end moveAll

  export operation fixAll [n: Node] -> [r: Boolean]
    GDebug.out1["Group", "fixAll"]
    r <- true

    const v: Vector.of[Any] <- self.listMembers    
    if v !== nil then
      var i : Integer <- 0
      for ( i <- 0 : i <= v.upperBound : i <- i + 1 )
        begin
          fix v.getElement[i] at n
          failure
            r <- false
          end failure
        end 
      end for
    end if
  end fixAll

  export operation refixAll [n: Node] -> [r: Boolean]
    GDebug.out1["Group", "refixAll"]
    r <- true

    const v: Vector.of[Any] <- self.listMembers    
    if v !== nil then
      var i : Integer <- 0
      for ( i <- 0 : i <= v.upperBound : i <- i + 1 )
        begin
          refix v.getElement[i] at n
          failure
            r <- false
          end failure
        end 
      end for
    end if
  end refixAll

  export operation unfixAll -> [r: Boolean]
    GDebug.out1["Group", "unfixAll"]
    r <- true

    const v: Vector.of[Any] <- self.listMembers    
    if v !== nil then
      var i : Integer <- 0
      for ( i <- 0 : i <= v.upperBound : i <- i + 1 )
        begin
          unfix v.getElement[i]
          failure
            r <- false
          end failure
        end 
      end for
    end if
  end unfixAll
end Group


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GListener.m - type listeners must adhere to
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
const GListener <- typeobject GListener builtin 0x102c
  operation groupUnavailable[i: Integer]
end GListener


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GID - unique identifier for each distributed group
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
const gid <- immutable class gid [value: Integer]
  export function = [g: gid] -> [b: Boolean]
    GDebug.out1["GID", "="]
    b <- value = g.getValue
  end =

  export function != [g: gid] -> [b: Boolean]
    GDebug.out1["GID", "!="]
    b <- ! self.=[g]
  end !=

  export function asString -> [s: String]
    GDebug.out1["GID", "asString"]
    s <- value.asString
  end asString

  export operation getValue -> [i: Integer]
    GDebug.out1["GID", "getValue"]
    i <- value
  end getValue
end gid  


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GManager - exists on nodes where there is group service activity 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
const GManager <- class GManager builtin 0x102d
  % all GReps on this node
  var repList: GList.of[GRep, gid] <- nil

  % next GID, used by coordinator
  field GIDCounter: GCounter <- nil

  % used to maintain coordinator
  var election: GElection <- nil  

  % locks for synchronization on nodedown
  var locks: GLocks <- nil

  % hash tables for fast lookup of members and listeners
  field memberHash : GHashTable <- nil
  field listenerHash : GHashTable <- nil  

  %%%%%%%%%%%%%%%%%%
  % initialization %     
  %%%%%%%%%%%%%%%%%%
  % -only initialize active GManagers
  % -should be called (at least) once for each GManager

  const initialized <- monitor object initialized
    const waitUntilReady: Condition <- Condition.create
    var count: Integer <- 0
    var ready: boolean <- false

    export operation startReady -> [b: Boolean]
      if !ready then
        if count = 0 then
          % I am the first initializer
          count <- count + 1
          b <- false
        else
          % I am a later initializer
          wait waitUntilReady
          b <- true
        end if
      else
        b <- true
      end if
    end startReady

    export operation doneReady  
      ready <- true
      loop
        exit when awaiting waitUntilReady = 0
        signal waitUntilReady
      end loop
    end doneReady

    export operation queryReady -> [b: Boolean]
      b <- ready
    end queryReady
  end initialized

  export operation initialize
    GDebug.out1["GManager", "initialize"]

    if initialized.startReady then
      return
    end if

    locks <- GLocks.create
    repList <- GList.of[GRep, gid].create
    memberHash <- GHashTable.create[101]
    listenerHash <- GHashTable.create[47]  

    % search for any preexisting GManagers
    const n: Node <- locate self
    const nl: ImmutableVector.of[NodeListElement] <- n.getActiveNodes
    var contactGM: GManager <- nil
    var coordinatorGM: GManager <- nil
    var i: Integer <- 0

    for ( i <- 0 : i <= nl.upperBound : i <- i + 1 )
      contactGM <- view nl.getElement[i].getTheNode.getGManager as GManager
      if contactGM !== nil and nl.getElement[i].getTheNode !== n then
        % found one
        coordinatorGM <- contactGM.getCoordinator
        if coordinatorGM !== nil then
          exit
        end if
      end if
    end for

    if coordinatorGM == nil then
      election <- GElection.create[nil, self]
      GIDCounter <- GCounter.create[1]
    else
      election <- GElection.create[coordinatorGM.getGElection, self]
    end if

    initialized.doneReady
  end initialize

  export operation getCoordinator -> [gmc: Gmanager]
    if !initialized.queryReady then
      gmc <- nil
      return
    end if

    gmc <- view election.getCoordinator.getUserData as GManager
  end getCoordinator

  export operation getGElection -> [ge: GElection]
    GDebug.out1["GManager", "getGElection"]
    ge <- election
  end getGElection

  %%%%%%%%%%%%%%%%%%%
  % upcalls from VM %
  %%%%%%%%%%%%%%%%%%%
  export operation nodeDown [n: Node]
    GDebug.out1["GManager", "nodeDown"]
    if !initialized.queryReady then
      return
    end if

    const gm: GManager <- GUtilities.getGM[locate self]

    const nodeDownThread <- object nodeDownThread
      process
        locks.writeLock[locate self]
        const oldCoordinator: GManager <- gm.getCoordinator
        const failedGENode: GElectionNode <- election.nodeDown[n]
        const newCoordinator: GManager <- gm.getCoordinator

        if failedGENode == nil then
          GDebug.out3["Node down - Node without GManager failing - ignoring"]
          locks.writeUnlock[locate self]
          return
        end if

        if oldCoordinator !== newCoordinator and gm == newCoordinator then
          % I am the new coordinator
          GDebug.out3["Node down - I am the new GManager coordinator"]
    
          % initialize GIDCounter
          const v: Vector.of[GElectionNode] <- election.list
          var i: Integer
          var highestGID: Integer <- 0
          var currentGID: Integer <- 0
          for (i <- 0 : i <= v.upperBound : i <- i + 1)
            begin
              currentGID <- (view v.getElement[i].getUserData as GManager).findHighestGID
              if currentGID > highestGID then
                highestGID <- currentGID 
              end if
              unavailable
                GDebug.out2["GManager", "nodeDown - attempted to call dead node"]
              end unavailable
            end
          end for 
          gm.setGIDCounter[GCounter.create[highestGID + 1]]
        else
          if gm !== newCoordinator then
            GDebug.out3["Node down - I am not the new GManager coordinator"]
          else 
            GDebug.out3["Node down - I am still the GManager coordinator"]
          end if
        end if
        locks.writeUnlock[locate self]
        
        % inform all GReps of failure of node
        const r: Vector.of[GRep] <- repList.list
        var j: Integer
        for (j <- 0 : j <= r.upperBound : j <- j + 1 ) 
          r.getElement[j].nodeDown[n]
        end for
      end process
    end nodeDownThread
  end nodeDown

  export operation moveMemberStart [o: Any, n: Node]
    GDebug.out1["GManager", "moveMemberStart"]

    const localGM: GManager <- GUtilities.getGM[locate self]
 
    const moveMemberStartThread <- object moveMemberStartThread
      process
        % on move of Group member, GReps have to agree
      end process
    end moveMemberStartThread  
  end moveMemberStart

  export operation moveMemberDone [o: Any, n: Node]
    % clean up from move of members
  end moveMemberDone

  export operation moveListenerStart [o: Any, n: Node]
    GDebug.out1["GManager", "moveListenerStart"]

    const localGM: GManager <- GUtilities.getGM[locate self]
 
    const moveListenerStartThread <- object moveListenerStartThread
      process
        % on move of listener, GReps have to agree
      end process
    end moveListenerStartThread  
  end moveListenerStart

  export operation moveListenerDone [o: Any, n: Node]
    % clean up from move of listeners
  end moveListenerDone

  export operation findHighestGID -> [i: Integer]
    GDebug.out1["GManager", "findHighestGID"]
    const v: Vector.of[GRep] <- repList.list

    i <- 0
    var j: Integer
    for (j <- 0 : j <= v.upperBound : j <- j + 1)
      if v.getElement[j].getGID.getValue > i then
        i <- v.getElement[j].getGID.getValue
      end if
    end for
  end findHighestGID

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % calls for GRepList maintenance %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  export operation findGRep[g: GID] -> [gr: GRep]
    GDebug.out1["GManager", "findGRep"]
    gr <- repList.find[g]
  end findGRep

  export operation createGRep [otherGRep: GRep] -> [newGRep: GRep]
    GDebug.out1["GManager", "createGRep"]
    var gd: GID <- nil
    if otherGRep == nil then
      gd <- GUtilities.getGM[locate self].newGID
    else
      gd <- otherGRep.getGID
    end if
    newGRep <- GRep.create[gd, otherGRep, self]
    repList.add[newGRep]
    GDebug.out3["new GRep created for gid " || gd.asString]
  end createGRep

  export operation removeGRep[gr: GRep]
    GDebug.out1["GManager", "removeGRep"]
    repList.remove[gr]
  end removeGRep

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % calls from immutable group interface %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  export operation newGID -> [g: gid]
    GDebug.out1["GManager", "newGID"]
    locks.readLock
    if GUtilities.getGM[locate self].getCoordinator == self then
      g <- GID.create[GIDCounter.getNext]
    else
      var success: Boolean <- false
      loop
        exit when success
        begin
          g <- self.getCoordinator.newGID
          success <- true
          unavailable
            GDebug.out2["GManager", "newGID - coordinator failure"]
            % give nodeDown thread a chance to continue
            locks.readUnlock
            locks.readLock
          end unavailable
        end
      end loop
    end if
    locks.readUnlock
  end newGID
  
  export operation listNodes -> [v: Vector.of[GElectionNode]]
    v <- election.list
  end listNodes
end GManager


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRep - 
%  local state (defined, members, listeners, membersAndListeners, failed)
%  other GReps for this GID, their node and their state
%  locks for this gid if coordinator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
const GRep <- class GRep [g: gid, gr: GRep, gm: GManager]

  %%%%%%%%
  % data %
  %%%%%%%%
  % all members of this GID
  field members: GArray.of[Any] <- GArray.of[Any].create
  % no of members on this node
  var localMembers: Integer <- 0

  % all listeners for this GID
  field listeners: GArray.of[GListener] <- GArray.of[GListener].create
  % no of listeners on this node
  var localListeners: Integer <- 0  

  % used to maintain coordinator, and GRepNodes
  var election: GElection <- nil

  % locks used by coordinator for synchronziation
  var locks: GLocks <- nil

  % true if this node holds the gid's write lock
  var writeLockHolder: Boolean <- false

  var next: GRep <- nil

  %%%%%%%%%%%%%
  % initially %
  %%%%%%%%%%%%%
  initially
    if gr == nil then
      % I am the first GRep for this gid
      const grn: GRepNode <- GRepNode.create[self]
      election <- GElection.create[nil, grn]
      locks <- GLocks.create
    else
      begin
        % joining a pre-existing set of GReps
        const grn: GRepNode <- GRepNode.create[self]
        const grc: GRep <- gr.getCoordinator
        var i: Integer <- 0

        grc.getLocks.writeLock[locate self]
        writeLockHolder <- true

        % copy election data
        election <- GElection.create[grc.getGElection, grn]

        % copy members
        const m: Vector.of[Any] <- grc.getMembers.list
        for ( i <- 0 : i <= m.upperBound : i <- i + 1 )
          members.add[m.getElement[i]]
        end for

        % copy listeners
        const l: Vector.of[GListener] <- grc.getListeners.list
        for ( i <- 0 : i <= l.upperBound : i <- i + 1)
          listeners.add[l.getElement[i]]
        end for

        writeLockHolder <- false
        grc.getLocks.writeUnlock[locate self]
        unavailable
          % failure on startup, just give up??
          GDebug.out3["GRep", "initially - unable to start cleanly"]
          assert false
        end unavailable
      end
    end if
  end initially

  %%%%%%%%%%%%
  % nodeDown %
  %%%%%%%%%%%%
  export operation nodeDown [n: Node]
    const oldCoordinator: GRep <- self.getCoordinator
    const failedGENode: GElectionNode <- election.nodeDown[n]
    const newCoordinator: GRep <- self.getCoordinator

    if failedGENode == nil then
      GDebug.out3["Node down - Node without gid " || g.asString || " failing - ignoring"]
      return
    end if

    if oldCoordinator !== newCoordinator and self == newCoordinator then
      % I am the new coordinator
      GDebug.out3["Node down - I am the new coordinator for gid " || g.asString]
      locks <- GLocks.create
    else 
      if self !== newCoordinator then
        GDebug.out3["Node down - I am not the new coordinator for gid " || g.asString]
      else
        GDebug.out3["Node down - I am still the coordinator for gid " || g.asString]
      end if
    end if
  end nodeDown

  %%%%%%%%
  % gets %
  %%%%%%%%
  export operation getGID -> [r: gid]
    GDebug.out1["GRep", "getGID"]
    r <- g
  end getGID

  export operation getCoordinator -> [grc: GRep]
    const grn: GRepNode <- view election.getCoordinator.getUserData as GRepNode
    grc <- grn.getGRep
  end getCoordinator

  export operation getGElection -> [ge: GElection]
    ge <- election
  end getGElection

  export operation getLocks -> [l: GLocks]
    l <- locks
  end getLocks

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % implementation of Group calls %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  export operation addMember [o: Any, root: Boolean] -> [b: Boolean]
    GDebug.out1["GRep", "addMember"]
    b <- false
    
    if root then 
      % make sure object not already in group
      if GUtilities.groupMember[o] then
        GDebug.out2["GRep", "addMember - object is already in a group"]
        return
      end if
      
      % mark object as group member
      GUtilities.setGroupMember[o, true]

      % acquire write lock
      self.acquireLock[false]

      % inform all nodes of new member
      const v: Vector.of[GElectionNode] <- election.list
      var i: Integer <- 0
      for ( i <- 0 : i <= v.upperBound : i <- i + 1 ) 
        const gr: GRep <- (view v.getElement[i].getUserData as GRepNode).getGRep
        if gr == self then
          members.add[o]
          localMembers <- localMembers + 1
          gm.getMemberHash.Insert[o, self]
        else
          begin
            b <- gr.addMember[o, false]
            unavailable
              GDebug.out2["GRep", "addMember - unavailable on other GRep"]
            end unavailable
          end
        end if
      end for
      b <- true

      % free write lock
      self.freeLock[false]
    else
      members.add[o]
    end if
  end addMember

  export operation removeMember [o: Any, root: Boolean] -> [b: Boolean]
    GDebug.out1["GRep", "removeMember"]
    b <- false
    
    if root then 
      % make sure object is already in a group
      if !GUtilities.groupMember[o] then
        GDebug.out2["GRep", "removeMember - object is not in a group"]
        return
      end if
      
      % acquire write lock
      self.acquireLock[false]
      
      % ensure object is in this group
      if members.find[o] == nil then
        GDebug.out2["GRep", "removeMember - object is not in this group"]
      else
        % mark object as not a group member
        GUtilities.setGroupMember[o, false]

        % inform all nodes of removed member
        const v: Vector.of[GElectionNode] <- election.list
        var i: Integer <- 0
        for ( i <- 0 : i <= v.upperBound : i <- i + 1 ) 
          const gr: GRep <- (view v.getElement[i].getUserData as GRepNode).getGRep
          if gr == self then
            members.remove[o]
            localMembers <- localMembers - 1
            gm.getMemberHash.Remove[o]
          else
            begin
              b <- gr.removeMember[o, false]
              unavailable
                GDebug.out2["GRep", "removeMember - unavailable on other GRep"]
              end unavailable
            end
          end if
        end for
        b <- true
      end if

      % free write lock
      self.freeLock[false]
    else
      members.remove[o]
    end if
  end removeMember

  export operation listMembers -> [o: Vector.of[Any]]
    GDebug.out1["GRep", "listMembers"]
    self.acquireLock[true]
    o <- members.list
    self.freeLock[true]
  end listMembers

  export operation listNodes -> [o: Vector.of[Node]]
    GDebug.out1["GRep", "listNodes"]
    self.acquireLock[true]
    const v: Vector.of[GElectionNode] <- election.list
    self.freeLock[true]

    o <- Vector.of[Node].create[v.upperBound + 1]
    var i: Integer <- 0
    for ( i <- 0 : i <= o.upperBound : i <- i + 1 )
      o.setElement[i, v.getElement[i].getNode]
    end for
  end listNodes

  export operation addGListener [l: GListener, root: Boolean] -> [b: Boolean]
    GDebug.out1["GRep", "addGListener"]
    b <- false
    
    if root then 
      % make sure object not already a glistener
      if GUtilities.groupListener[l] then
        GDebug.out2["GRep", "addGListener - object is already a listener"]
        return
      end if
      
      % mark object as group listener
      GUtilities.setGroupListener[l, true]

      % acquire write lock
      self.acquireLock[false]

      % inform all nodes of new listener
      const v: Vector.of[GElectionNode] <- election.list
      var i: Integer <- 0
      for ( i <- 0 : i <= v.upperBound : i <- i + 1 ) 
        const gr: GRep <- (view v.getElement[i].getUserData as GRepNode).getGRep
        if gr == self then
          listeners.add[l]
          localListeners <- localListeners + 1
          gm.getListenerHash.Insert[l, self]
        else
          begin
            b <- gr.addGListener[l, false]
            unavailable
              GDebug.out2["GRep", "addGListener - unavailable on other GRep"]
            end unavailable
          end
        end if
      end for
      b <- true

      % free write lock
      self.freeLock[false]
    else
      listeners.add[l]
    end if
  end addGListener

  export operation removeGListener [l: GListener, root: Boolean] -> [b: Boolean]
    GDebug.out1["GRep", "removeGListener"]
    b <- false
    
    if root then 
      % make sure object is already in a group
      if !GUtilities.groupListener[l] then
        GDebug.out2["GRep", "removeGListner - object is not a group listener"]
        return
      end if
      
      % acquire write lock
      self.acquireLock[false]
      
      % ensure object is a listener for this group
      if listeners.find[l] == nil then
        GDebug.out2["GRep", "removeGListener - object is not a listener for this group"]
      else
        % mark object as not a group listener
        GUtilities.setGroupListener[l, false]

        % inform all nodes of removed member
        const v: Vector.of[GElectionNode] <- election.list
        var i: Integer <- 0
        for ( i <- 0 : i <= v.upperBound : i <- i + 1 ) 
          const gr: GRep <- (view v.getElement[i].getUserData as GRepNode).getGRep
          if gr == self then
            listeners.remove[l]
            localListeners <- localListeners - 1
            gm.getListenerHash.Remove[l]
          else
            begin
              b <- gr.removeGListener[l, false]
              unavailable
                GDebug.out2["GRep", "removeGListener - unavailable on other GRep"]
              end unavailable
            end
          end if
        end for
        b <- true
      end if

      % free write lock
      self.freeLock[false]
    else
      listeners.remove[l]
    end if
  end removeGListener

  export operation listGListeners -> [l: Vector.of[GListener]]
    GDebug.out1["GRep", "listGListeners"]    
    self.acquireLock[true]
    l <- listeners.list
    self.freeLock[true]
  end listGListeners

  %%%%%%%%%%%%%%%%
  % misc helpers %
  %%%%%%%%%%%%%%%%
  operation acquireLock [read: Boolean]
    var success: Boolean <- false
    loop
      begin
        exit when success
        if read then
          self.getCoordinator.getLocks.readLock
        else
          self.getCoordinator.getLocks.writeLock[locate self]
          writeLockHolder <- true
        end if
        success <- true
        unavailable
          GDebug.out2["GRep", "acquireLock - coordinator failure"]
        end unavailable
      end
    end loop
  end acquireLock

  operation freeLock [read: Boolean]
    begin 
      if read then
        self.getCoordinator.getLocks.readUnlock
      else
        writeLockHolder <- false
        self.getCoordinator.getLocks.writeUnlock[locate self]
      end if
      unavailable
        GDebug.out2["GRep", "freeLock - coordinator failure"]
      end unavailable
    end
  end freeLock

  %%%%%%%%%%%%%%%
  % GList calls %
  %%%%%%%%%%%%%%%
  export operation = [og: Any] -> [b: Boolean]
    GDebug.out1["GRep", "="]
    if typeof og *> gid then
      b <- g = (view og as gid)
    else
      GDebug.out3["GRep", "= - comparator is not gid type"]
      assert false
    end if
  end =

  export operation getComparator -> [gd: gid]
    GDebug.out1["GRep", "getComparator"]
    gd <- g
  end getComparator

  export operation clone -> [newG: GRep]
    GDebug.out3["GRep", "clone - not implemented"]
    % not implemented
    assert false
  end clone

  export operation moveTo [n: node]
    GDebug.out3["GRep", "moveTo - not implemented"]
    % not implemented
    assert false
  end moveTo

  export operation getNext -> [g: GRep]
    GDebug.out1["GRep", "getNext"]
    g <- next
  end getNext

  export operation setNext [g: GRep]
    GDebug.out1["GRep", "setNext"]
    next <- g
  end setNext
end GRep


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRepNode - stores GReps and their state
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
const GRepNode <- class GRepNode [gr: GRep]
  const DEFINED: Integer <- 0
  const MEMBERS: Integer <- 1
  const LISTENERS: Integer <- 2
  const MEMBERS_AND_LISTENERS <- 3

  var state: Integer <- DEFINED
   
  export operation getGRep -> [g: GRep]
    g <- gr
  end getGRep

  export operation getState -> [s: Integer]
    s <- state
  end getState

  export operation setState [s: Integer]
    state <- s
  end setState

  export operation clone -> [g: Any]
    g <- GRepNode.create[gr]
    (view g as GRepNode).setState[state]
  end clone

  export operation moveTo [n: Node]
    % move self to n
  end moveTo
end GRepNode


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUtilities - utilities
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
const GUtilities <- immutable class GUtilities
  class export operation setGroupMember [o: Any, b: Boolean]
    if b then
      primitive "NCCALL" "GROUP" "SETMEMBER" [] <- [o] 
    else
      primitive "NCCALL" "GROUP" "CLEARMEMBER" [] <- [o] 
    end if
  end setGroupMember

  class export operation groupMember [o: Any] -> [b: Boolean]
    primitive "NCCALL" "GROUP" "QUERYMEMBER" [b] <- [o] 
  end groupMember

  class export operation setGroupListener [o: Any, b: Boolean]
    if b then
      primitive "NCCALL" "GROUP" "SETLISTENER" [] <- [o] 
    else
      primitive "NCCALL" "GROUP" "CLEARLISTENER" [] <- [o] 
    end if
  end setGroupListener

  class export operation groupListener [o: Any] -> [b: Boolean]
    primitive "NCCALL" "GROUP" "QUERYLISTENER" [b] <- [o] 
  end groupListener

  class export operation markUnavailable [o: Any] 
    primitive "NCCALL" "GROUP" "MARKUNAVAILABLE" [] <- [o] 
  end markUnavailable

  class export operation getGM [n: Node] -> [gm: GManager]
    begin
      gm <- view n.getGManager as GManager
      gm.initialize
      unavailable
        GDebug.out2["GUtilities", "getGM - unable to create remote GManager"]
        assert false
      end unavailable
    end
  end getGM
end GUtilities


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Exports 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
export Group to "Builtins"
export GListener to "Builtins"
export GManager to "Builtins"


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EOF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
