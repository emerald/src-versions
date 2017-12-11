const test <- object test
  process
    const gNodeList: GNList <- GNList.create

    const nl: NodeList <- (locate self).getActiveNodes
    if nl.upperBound > 0 then
      const n: Node <- nl.getElement[1].getTheNode
      const testNode: GNode <- GNode.create[nil, 1]
      testNode.moveTo[n]
    end if
  end process
end test

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GNode - info for each node
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
const GNode <- monitor class GNode 
  [nod: Node, id: Integer]
  var next: GNode <- nil

  export operation getNode -> [n: Node]
    n <- nod
  end getNode

  export operation getID -> [i: Integer]
    i <- id
  end getID

  export operation = [n: Node] -> [b: Boolean]
%  export operation = [n: Any] -> [b: Boolean]
    if typeof n *> Node then
      b <- (view n as Node) == nod
    else
      assert false
    end if
  end =

  export operation getComparator -> [n: Node] 
    n <- nod
  end getComparator

  export operation clone -> [g: GNode]
    g <- GNode.create[nod, id]
  end clone

  export operation moveTo [n: Node]
    move self to n
  end moveTo

  export operation getNext -> [g: GNode]
    g <- next
  end getNext

  export operation setNext [g: GNode]
    next <- g
  end setNext
end GNode


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GList - list template
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
const GNList <- immutable object aGListCreator
      const thisGListCreator <- self

      const GListType <- typeobject GListType
          operation add [GNode]
          operation remove [GNode]
          operation find [Node] -> [GNode]
          operation list -> [Vector.of[GNode]]
          operation clone -> [GListType]
          operation moveTo [Node]
      end GListType

      export function getSignature -> [r : Signature]
	r <- GListType
      end getSignature

      export operation create -> [r : GListType]
	r <- monitor object aGList
          var dataHead: GNode <- nil
          var dataTail: GNode <- nil

          export operation add [e : GNode]
            if self.findInternal [e.getComparator] !== nil then
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

          export operation remove [e : GNode]
            var currentRecord: GNode <- dataHead
            var previousRecord: GNode <- nil
        
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

          export operation find [c : Node] -> [r : GNode]
            r <- self.findInternal[c]
          end find
 
          operation findInternal [c: Node] -> [r : GNode]
            var currentRecord: GNode <- dataHead
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
        
          export operation list -> [v : Vector.of[GNode]]
            var count: Integer <- 0
            var currentRecord: GNode <- dataHead
        
            % determine how many elements
            loop
              exit when currentRecord == nil
              count <- count + 1
              currentRecord <- currentRecord.getNext
            end loop
                
            % create and fill vector
            v <- Vector.of[GNode].create[count]
            currentRecord <- dataHead
            var i: Integer <- 0
            loop
              exit when currentRecord == nil
              v.setElement[i, currentRecord]
              i <- i + 1
              currentRecord <- currentRecord.getNext
            end loop
          end list

b          export operation clone -> [l : GListType]
            var currentRecord: GNode <- dataHead
            l <- thisGListCreator.create
        
            loop
              exit when currentRecord == nil
              l.add[currentRecord.clone]
              currentRecord <- currentRecord.getNext
            end loop
          end clone
        
          export operation moveTo [n : Node]
            var currentRecord: GNode <- dataHead
        
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
