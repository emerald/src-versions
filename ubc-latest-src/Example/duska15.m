% cpu load monitor portion of the sysmon application
% one group with one object roaming between systems

const main <- object main
  initially
    const x <- xcpu.create
  end initially
end main

% xforms portion
const xcpu <- class xcpu 
  process
    self.creategcpu
  end process

  export operation creategcpu
    const g <- gcpu.create[self]
  end creategcpu

  export operation nodeStatusReport [n: Node, name: String, load: Real]
    (locate self).getStdOut.putString["Load on Node " || name || " is " || load.asString || "\n"]
  end nodeStatusReport
end xcpu


% app portion
const gcpu <- class gcpu [x: xcpu]
  % active nodes 
  var activeNodes: GList.of[nodeNode, Node] <- GList.of[nodeNode, Node].create

  export operation nodeUpDown[n: Node, up: Boolean]
    if up then
      const name: String <- n.getName || ":" || (n.getLNN/0x10000).asString
      const nn: nodeNode <- nodeNode.create[n, name]
      activeNodes.add[nn]
    else
      const nn: nodeNode <- activeNodes.find[n]
      activeNodes.remove[nn]
    end if
  end nodeUpDown

  process
    var nnl: Vector.of[nodeNode] <- activeNodes.list
    var currNN: nodeNode <- nil
    const delay: Time <- Time.create[1, 0]
    var i: Integer <- 0
    
    loop
      currNN <- nnl.getElement[i]
      move self to currNN.getNode
      if (locate self) == currNN.getNode then
        % measure cpu load
        begin
          x.nodeStatusReport[currNN.getNode, currNN.getName, 0.0]
          failure
          end failure
        end
      end if
      i <- i + 1
      if i > nnl.upperBound then 
        i <- 0 
      end if
      (locate self).delay[delay]
    end loop
  end process

  initially
    const nl <- (locate self).getActiveNodes
    var i: Integer
    for ( i <- 0 : i <= nl.upperBound : i <- i + 1 )
      self.nodeUpDown[nl.getElement[i].getTheNode, true]
    end for
  end initially

end gcpu



% keep track of active nodes and names
const nodeNode <- class nodeNode [n: Node, name: String]
  var next: nodeNode <- nil

  export operation getName -> [n: String]
    n <- name
  end getName

  export operation getNode -> [on: Node]
    on <- n
  end getNode

  export operation = [on: Node] -> [b: Boolean]
    b <- on == n
  end =

  export operation getComparator -> [on: Node]
    on <- n
  end getComparator

  export operation clone -> [nn: nodeNode]
    nn <- nodeNode.create[n, name]
  end clone
  
  export operation getNext -> [n: nodeNode]
    n <- next
  end getNext

  export operation setNext [n: nodeNode]
    next <- n
  end setNext
end nodeNode


% list template
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
            if self.findInternal [e.getComparator] !== nil then
              (locate self).getStdOut.putString["GList: " || "add - attempt to add already existing node\n"]
              return
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
              (locate self).getStdOut.putString["GList: " || "remove - attempt to remove non existent node\n"]
              return
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
            r <- self.findInternal[c]
          end find
 
          operation findInternal [c: cType] -> [r : eType]
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
              move currentRecord to n
              currentRecord <- currentRecord.getNext
            end loop
            move self to n
          end moveTo
	end aGList
      end create
    end aGListCreator
  end of
end GList
