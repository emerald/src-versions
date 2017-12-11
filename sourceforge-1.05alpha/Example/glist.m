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
          attached var dataHead: eType <- nil
          attached var dataTail: eType <- nil

          export operation add [e : eType]
            if self.findInternal [e.getComparator] !== nil then
              %GDebug.out3["GList", "add - attempt to add already existing node"]
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
              %GDebug.out3["GList", "remove - attempt to remove non existent node"]
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
	    move self to n
          end moveTo
	end aGList
      end create
    end aGListCreator
  end of
end GList

const ListElement <- class ListElement[pvalue : Integer]
  attached field next : ListElement <- nil
  field value : Integer <- pvalue

  export operation clone -> [r : ListElement]
    r <- ListElement.create[value]
  end clone
  
  export operation getComparator -> [r : Integer]
    r <- value
  end getComparator

  export operation = [v : Integer] -> [r : Boolean]
    r <- v = value
  end =
end ListElement

const Kilroy <- object Kilroy
  process
    const home <- locate self
    var there :     Node
    var all : NodeList

    const l <- GList.of[ListELement, Integer].create
    l.add[ListElement.create[1]]
    l.add[ListElement.create[2]]
    l.add[ListElement.create[3]]
    l.add[ListElement.create[4]]

    home$stdout.PutString["Starting on " || home$name || "\n"]
    all <- home.getActiveNodes
    home$stdout.PutString[(all.upperbound + 1).asString || " nodes active.\n"]
    var i : Integer <- 0
    loop
      there <- all[i]$theNode
      home$stdout.PutString["Moving the list to node " || i.asString || ".\n"]
      l.moveTo[there]
      i <- i + 1
      if i > all.upperbound then i <- 0 end if
      home.Delay[Time.create[2, 0]]
    end loop
  end process
end Kilroy
