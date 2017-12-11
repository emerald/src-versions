export bag

const bag <- immutable object bag
  export function of [etype : type] -> [r : BagCreatorType]
    forall etype
    where 
      BagType <- typeobject BagType
        operation add [etype]
        operation remove [etype]
        operation select -> [etype]
        function empty -> [Boolean]
        function contains [etype] -> [Boolean]
        operation advance -> [etype]
        operation reset_curr
        operation addIfUnique [etype] % Added by Mach
        operation lock                % Added by Mach
        operation unlock              % Added by Mach
      end BagType
    where
      Es <- typeobject Es
        function lowerbound -> [Integer]
        function upperbound -> [Integer]
        function getElement[Integer] -> [etype]
      end Es
    where
      BagCreatorType <- immutable typeobject BagCreatorType
        operation create -> [BagType]
        operation literal[Es] -> [BagType]
        operation singleton [etype] -> [BagType]
        function getSignature -> [Signature]
      end BagCreatorType
    r <- immutable object aBagCreator
      const erec <- class erec
        field prev : erec
        field next : erec
        field value : etype
      end erec

      export function getSignature -> [r : Signature]
        r <- BagType
      end getSignature

      export operation literal[values : Es] -> [r : BagType]
        r <- self.create
        for i : Integer <- values.lowerbound while i <= values.upperbound by i <- i + 1
          r.add[values[i]]
        end for
      end literal


      export operation singleton [v : etype] -> [r : BagType]
        r <- self.create
        r.add[v]
      end singleton

      export operation create -> [r : BagType]
        r <- monitor object aBag                  % Mach added "monitor"
          var waiting : Integer <- 0              % Added by Mach
          const c <- Condition.create             % Added by Mach
          const head : erec <- erec.create
          var curr : erec <- head

          % Mach added the operation "addIfUnique"
          % (which calls no other operations so that 
          % Bag objects can be monitored)
          export operation addIfUnique [v : etype]
            % return if not unique
            for e : erec <- head$next while e !== head by e <- e$next
              if e$value == v then return end if
            end for

            % otherwise add
            const n : erec <- erec.create
            n$next <- head
            n$prev <- head$prev
            head$prev$next <- n
            head$prev <- n
            n$value <- v
          end addIfUnique

          % Mach added the operation "lock"
          % which delays anyone else who wishes
          % to lock the bag
          export operation lock
            waiting <- waiting + 1 
            if waiting > 1 then wait c end if
            curr <- head
          end lock

          % Mach added the operation "unlock"
          % which lets someone else lock and
          % use the bag
          export operation unlock
            waiting <- waiting - 1 
            signal c
          end unlock

          export operation add [v : etype]
            const n : erec <- erec.create
            n$next <- head
            n$prev <- head$prev
            head$prev$next <- n
            head$prev <- n
            n$value <- v
          end add
          export function contains [v : eType] -> [r : Boolean]
            r <- false
            for e : erec <- head$next while e !== head by e <- e$next
              if e$value == v then r <- true return end if
            end for
          end contains
          export operation remove [v : etype]
            for e : erec <- head$next while e !== head by e <- e$next
              if e$value == v then
                e$next$prev <- e$prev
                e$prev$next <- e$next
                return
              end if
            end for
          end remove
          export operation select -> [e : eType]
            e <- head$next$value
          end select
          export operation advance -> [e : etype]
            curr <- curr$next
            e <- curr$value
          end advance
          export operation reset_curr
            curr <- head
          end reset_curr
          export function empty -> [r : Boolean]
            r <- head$next == head
          end empty
          initially
            head$next <- head
            head$prev <- head
          end initially
        end aBag
      end create
    end aBagCreator
  end of
end Bag
