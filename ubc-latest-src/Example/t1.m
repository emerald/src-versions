const Ident <- class Ident 
   field foo : Integer <- 4
   export function asString -> [r : String]
     r <- "abc"
   end asString
end Ident

export Ident
