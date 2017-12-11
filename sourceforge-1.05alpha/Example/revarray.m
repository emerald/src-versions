const rev <- immutable object rev
   export function reverse[list: array.of[t]] -> [res: array.of[t]]
     forall t

     res <- array.of[t].Create[0]

     loop
       exit when list.empty         
       res.addUpper[list.removeLower]
     end loop
   end reverse
   export function reverse2[t : Type, list: array.of[t]] -> [res: array.of[t]]
     forall t

     res <- array.of[t].Create[0]

     loop
       exit when list.empty         
       res.addUpper[list.removeLower]
     end loop
   end reverse2
end rev

const driver <- object driver
  const a <- Array.of[Integer].literal[{ 1, 2, 3 }]
%  const b <- rev.reverse[a]
  const b <- rev.reverse2[Integer, a]
end driver
