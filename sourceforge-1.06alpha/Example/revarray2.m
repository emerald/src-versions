const rev <- immutable object rev
   export operation reverse[list: x, res: y]
     forall t
     where x <- typeobject x
       operation removeLower -> [t]
       operation empty -> [Boolean]
     end x
     where y <- typeobject y
       operation addUpper [t]
     end y

     loop
       exit when list.empty         
       res.addUpper[list.removeLower]
     end loop
   end reverse
end rev

const driver <- object driver
  process
    const a <- Array.of[Integer].literal[{ 1, 2, 3 }]
    const b <- Array.of[Integer].empty

    rev.reverse[a, b]
  end process
end driver
